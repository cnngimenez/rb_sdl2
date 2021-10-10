module RbSDL2
  class Surface
    require_relative 'ref_count_pointer'

    class SurfacePointer < RefCountPointer
      class << self
        def release(ptr)
          # 備考：SDL では参照カウンターを操作する際にロックを行っていない。
          #
          # SDL_Surface ポインターの参照カウンターの扱いでは SDL_DONTFREE フラグを考慮する必要がある。
          # SDL_DONTFREE フラグが設定されていると SDL_FreeSurface を呼び出しても参照カウントが減少しない。
          # SDL_DONTFREE フラグの状態に関わらず Ruby 側ではポインターを正しく扱えるので参照カウントを増減する。
          # 備考：Window から SDL_Surface ポインターを取り出す際にこのフラグが設定されている。
          st = entity_class.new(ptr)
          if st[:flags] & ::SDL2::SDL_DONTFREE != 0
            st[:refcount] -= 1
            # SDL_DONTFREE が設定されているので参照カウントの値によらず SDL_FreeSurface を呼び出さない。
            # スレッドでの競合によりポインターを開放されない可能性（＝メモリーリーク）はある。
            # 具体的にはこのセクションを実行中に SDL_EventPump が実行され、ウィンドウのリサイズ・イベントが発生
            # したときに起きる。この競合が起きないようにアプリケーションを実装する必要がある。
          else
            ::SDL2.SDL_FreeSurface(ptr)
          end
        end

        def entity_class = ::SDL2::SDL_Surface
      end
    end

    require_relative 'pixel_format_enum'

    class << self
      # 変換ができない場合はエラーを発生させる。
      # 変換先がインデックスカラー（INDEX8）の時は期待する変換は行われない。
      def convert(surface, new_format)
        ptr = SurfacePointer.new(
          ::SDL2.SDL_ConvertSurfaceFormat(surface, PixelFormatEnum.to_num(new_format), 0))
        raise RbSDL2Error if ptr.null?
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end

      require_relative 'rw_ops'

      def load(file) = RWOps.new(file, "rb") { |rw| load_rw(rw) }

      # load_rw は与えられたオブジェクトをオートクローズしません。
      def load_rw(rw)
        ptr = SurfacePointer.new(::SDL2.SDL_LoadBMP_RW(rw, 0))
        raise RbSDL2Error if ptr.null?
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end

      def new(w, h, format)
        ptr = SurfacePointer.new(
          ::SDL2.SDL_CreateRGBSurfaceWithFormat(0, w, h, 0, PixelFormatEnum.to_num(format)))
        raise RbSDL2Error if ptr.null?
        super(ptr)
      end

      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, SurfacePointer.to_ptr(ptr))
        obj
      end

      def yuv_conversion_mode_name
        case ::SDL2.SDL_GetYUVConversionMode
        when ::SDL2::SDL_YUV_CONVERSION_JPEG then "JPEG"
        when ::SDL2::SDL_YUV_CONVERSION_BT601 then "BT601"
        when ::SDL2::SDL_YUV_CONVERSION_BT709 then "BT709"
        when ::SDL2::SDL_YUV_CONVERSION_AUTOMATIC then "AUTOMATIC"
        else ""
        end
      end

      def yuv_conversion_mode=(mode)
        ::SDL2.SDL_SetYUVConversionMode(mode)
      end
    end

    def initialize(ptr)
      @st = ::SDL2::SDL_Surface.new(ptr)
    end

    def ==(other)
      other.respond_to?(:to_ptr) && to_ptr == other.to_ptr
    end

    def alpha_mod
      alpha = ::FFI::MemoryPointer.new(:uint8)
      num = ::SDL2.SDL_GetSurfaceAlphaMod(self, alpha)
      raise RbSDL2Error if num < 0
      alpha.read_uint8
    end

    def alpha_mod=(alpha)
      num = ::SDL2.SDL_SetSurfaceAlphaMod(self, alpha)
      raise RbSDL2Error if num < 0
    end

    def blend_mode
      blend = ::FFI::MemoryPointer.new(:int)
      err = ::SDL2.SDL_GetSurfaceBlendMode(self, blend)
      raise RbSDL2Error if err < 0
      blend.read_int
    end

    require_relative 'surface/blend_mode'
    include BlendMode

    def blend_mode_name = BlendMode.to_name(blend_mode)

    def blend_mode=(blend)
      err = ::SDL2.SDL_SetSurfaceBlendMode(self, BlendMode.to_num(blend))
      raise RbSDL2Error if err < 0
    end

    def blit(other, from: nil, to: nil, scale: false)
      from &&= Rect.new(*from)
      to &&= Rect.new(*to)
      err = if scale
              ::SDL2.SDL_UpperBlitScaled(other, from, self, to)
            else
              ::SDL2.SDL_UpperBlit(other, from, self, to)
            end
      raise RbSDL2Error if err < 0
    end

    def bounds = [0, 0, w, h]

    def bytesize = pitch * height

    def clip
      rect = Rect.new
      ::SDL2.SDL_GetClipRect(self, rect)
      rect.to_a
    end

    # nil の場合はサーフェィス全域がクリップになる。
    def clip=(rect)
      rect &&= Rect.new(*rect)
      bool = ::SDL2.SDL_SetClipRect(self, rect)
      raise "out of bounds" if bool == ::SDL2::SDL_FALSE
    end

    def clear(color = [0, 0, 0, 0]) = fill(bounds, color)

    def color_key
      return unless color_key?
      key = ::FFI::MemoryPointer.new(:uint32)
      err = ::SDL2.SDL_GetColorKey(self, key)
      return RbSDL2Error if err < 0
      pixel_format.unpack_color(key.read_uint32)
    end

    def color_key=(color)
      err = if color
              ::SDL2.SDL_SetColorKey(self, ::SDL2::SDL_TRUE, pixel_format.pack_color(color))
            else
              ::SDL2.SDL_SetColorKey(self, ::SDL2::SDL_FALSE, 0)
            end
      raise RbSDL2Error if err < 0
    end

    def color_key? = ::SDL2.SDL_HasColorKey(self) == ::SDL2::SDL_TRUE

    def color_mod
      rgb = Array.new(3) { ::FFI::MemoryPointer.new(:uint8) }
      err = ::SDL2.SDL_GetSurfaceColorMod(self, *rgb)
      raise RbSDL2Error if err < 0
      rgb.map(&:read_uint8)
    end

    def color_mod=(color)
      r, g, b = color
      err = ::SDL2.SDL_SetSurfaceColorMod(self, r, g, b)
      raise RbSDL2Error if err < 0
    end

    def convert(new_format = format) = Surface.convert(self, new_format)

    def fill(rect = clip, color = [0, 0, 0, 0])
      err = ::SDL2.SDL_FillRect(self, Rect.new(*rect), pixel_format.pack_color(color))
      raise RbSDL2Error if err < 0
    end

    def height = @st[:h]

    alias h height

    def pitch = @st[:pitch]

    require_relative 'surface/pixel_format'

    def pixel_format
      # SDL_Surface の format メンバーは読み取り専用である。作成時の値が不変であることを前提としている。
      @pixel_format ||= PixelFormat.to_ptr(@st[:format])
    end

    require 'forwardable'
    extend Forwardable
    def_delegators :pixel_format, *%i(bits_per_pixel bpp format palette palette=)

    require_relative 'pixel_format_enum'
    include PixelFormatEnum

    def rle=(bool)
      err = ::SDL2.SDL_SetSurfaceRLE(self, bool ? 1 : 0)
      raise RbSDL2Error if err < 0
    end

    def rle? = ::SDL2.SDL_HasSurfaceRLE(self) == ::SDL2::SDL_TRUE

    require_relative 'rw_ops'

    def save(file) = RWOps.new(file, "wb") { |rw| save_rw(rw); nil }

    # save_rw は与えられたオブジェクトをオートクローズしません。
    def save_rw(rw)
      err = ::SDL2.SDL_SaveBMP_RW(rw, 0)
      raise RbSDL2Error if err < 0
      rw
    end

    def size = [width, height]

    def synchronize
      ::SDL2.SDL_LockSurface(self)
      yield(self)
    ensure
      ::SDL2.SDL_UnlockSurface(self)
    end

    def to_ptr = @st.to_ptr

    def width = @st[:w]

    alias w width
  end
end
