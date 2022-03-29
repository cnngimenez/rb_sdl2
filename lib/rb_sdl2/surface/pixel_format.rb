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
        # アプリケーションが PixelFormat を作成する必要がないためコンストラクターを実装しない。
        # FFI::AutoPointer によるポインター管理を行っているのは Surface 側で PixelFormat を公開しているため。
      end

      def initialize(ptr)
        @st = ::SDL::PixelFormat.new(PixelFormatPointer.to_ptr(ptr))
      end

      def ==(other)
        other.respond_to?(:to_ptr) && other.to_ptr == to_ptr
      end

      def a_mask = @st[:Amask]

      def b_mask = @st[:Bmask]

      def g_mask = @st[:Gmask]

      def r_mask = @st[:Rmask]

      def a_mask? = @st[:Amask] > 0

      def bits_per_pixel = @st[:BitsPerPixel]
      alias bpp bits_per_pixel

      def bytes_per_pixel = @st[:BytesPerPixel]

      def format = @st[:format]

      require_relative '../pixel_format_enum'
      include PixelFormatEnum

      # indexed format のときはパレット番号を戻す。
      def pack_color(color)
        r, g, b, a = color
        if a_mask?
          ::SDL.MapRGBA(self, r, g, b, a || ::SDL::ALPHA_OPAQUE)
        else
          ::SDL.MapRGB(self, r, g, b)
        end
      end

      require_relative '../palette'

      # パレットがある場合は Palette インスタンスを戻します。ない場合は nil を戻します。
      def palette
        Palette.to_ptr(@st[:palette]) unless @st[:palette].null?
      end

      def palette=(pal)
        # SDL_SetPixelFormatPalette() はパレット・ポインターが NULL かどうかチェックしていない。
        if Palette === pal && !pal.to_ptr.null?
          err = ::SDL.SetPixelFormatPalette(self, pal)
          raise RbSDL2Error if err < 0
        else
          raise ArgumentError, "pointer is NULL"
        end
      end

      def palette? = !@st[:palette].null?

      def to_ptr = @st.to_ptr

      # indexed format のときはパレット番号を引数へ与える。
      def unpack_pixel(num)
        color = Array.new(a_mask? ? 4 : 3) { ::FFI::MemoryPointer.new(:uint8) }
        if a_mask?
          ::SDL.GetRGBA(num, self, *color)
        else
          ::SDL.GetRGB(num, self, *color)
        end
        color.map(&:read_uint8)
      end
    end
  end
end
