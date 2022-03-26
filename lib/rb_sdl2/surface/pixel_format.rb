module RbSDL2
  class Surface
    class PixelFormat
      require_relative '../ref_count_pointer'

      class PixelFormatPointer < RefCountPointer
        class << self
          def release(ptr) = ::SDL.FreeFormat(ptr)

          def entity_class = ::SDL::PixelFormat
        end
      end

      class << self
        require_relative '../pixel_format_enum'

        def new(format)
          ptr = PixelFormatPointer.new(::SDL::AllocFormat(PixelFormatEnum.to_num(format)))
          raise RbSDL2Error if ptr.null?
          super(ptr)
        end

        def to_ptr(ptr)
          obj = allocate
          obj.__send__(:initialize, PixelFormatPointer.to_ptr(ptr))
          obj
        end
      end

      def initialize(ptr)
        @st = ::SDL::PixelFormat.new(ptr)
      end

      def ==(other)
        other.respond_to?(:to_ptr) && to_ptr == other.to_ptr
      end

      def alpha_mask? = @st[:Amask] > 0

      def bits_per_pixel = @st[:BitsPerPixel]
      alias bpp bits_per_pixel

      def bytes_per_pixel = @st[:BytesPerPixel]

      def format = @st[:format]

      require_relative '../pixel_format_enum'
      include PixelFormatEnum

      # indexed format のときはパレット番号を戻す。
      def pack_color(color)
        r, g, b, a = color
        if alpha_mask?
          ::SDL.MapRGBA(self, r, g, b, a || ::SDL::ALPHA_OPAQUE)
        else
          ::SDL.MapRGB(self, r, g, b)
        end
      end

      require_relative '../palette'

      def palette
        # パレットは参照カウンターで生存の保証がある。
        # Ruby 側がパレットを保持している限り同一アドレスに違うパレットが作成されることはない。
        # SDL では PixelFormat の palette メンバーは（行儀よく SetPixelFormatPalette を使う場合は）
        # 後から NULL に書き換わることはない。
        (ptr = @st[:palette]) == @palette&.to_ptr ? @palette : @palette = Palette.to_ptr(ptr)
      end

      def palette=(pal)
        err = ::SDL.SetPixelFormatPalette(self, pal)
        raise RbSDL2Error if err < 0
        @palette = nil
      end

      def to_ptr = @st.to_ptr

      # indexed format のときはパレット番号を引数へ与える。
      def unpack_color(pixel)
        if alpha_mask?
          ::SDL.GetRGBA(pixel, self, *Array.new(4) { ::FFI::MemoryPointer.new(:uint8) })
        else
          ::SDL.GetRGB(pixel, self, *Array.new(3) { ::FFI::MemoryPointer.new(:uint8) })
        end
        color.map(&:read_uint8)
      end
    end
  end
end
