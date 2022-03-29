module RbSDL2
  class Surface
    require_relative 'ref_count_pointer'

    class SurfacePointer < RefCountPointer
      class << self
        def release(ptr)
          # 備考：SDL では参照カウンターを操作する際にロックを行っていない。
          #
          # Surface ポインターの参照カウンターの扱いでは DONTFREE フラグを考慮する必要がある。
          # DONTFREE フラグが設定されていると FreeSurface を呼び出しても参照カウントが減少しない。
          # DONTFREE フラグの状態に関わらず Ruby 側ではポインターを正しく扱えるので参照カウントを増減する。
          # 備考：Window から Surface ポインターを取り出す際にこのフラグが設定されている。
          unless ptr.null?
            st = entity_class.new(ptr)
            if st[:flags] & ::SDL::DONTFREE != 0
              st[:refcount] -= 1
              # DONTFREE が設定されているので参照カウントの値によらず FreeSurface を呼び出さない。
              # スレッドでの競合によりポインターを開放されない可能性（＝メモリーリーク）はある。
              # 具体的にはこのセクションを実行中に EventPump が実行され、ウィンドウのリサイズ・イベントが発生
              # したときに起きる。この競合が起きないようにアプリケーションを実装する必要がある。
            else
              ::SDL.FreeSurface(ptr)
            end
          end
        end

        def entity_class = ::SDL::Surface
      end
    end

    require_relative 'pixel_format_enum'

    class << self
      # 指定した Surface オブジェクトを基に指定した画像フォーマットの新しい Surface オブジェクトを柵瀬します。
      # surface へ変換元の Surface オブジェクトを与えます。
      # new_format へ変換先の画像フォーマット(PixelFormatEnumの名前か番号)を与えます。
      # 変換ができない場合は例外（RbSDL2::RbSDL2Error）を発生させます。
      # INDEX1*, INDEX4*, ARGB2101010、FOURCC系への変換はできません。
      # 変換先がインデックスカラー（INDEX8）の時は例外は発生しませんが期待する変換は行われません。
      # その時はサーフェィス全面がインデックス番号０で埋められています。
      def convert(surface, new_format)
        ptr = SurfacePointer.new(
          ::SDL.ConvertSurfaceFormat(surface, PixelFormatEnum.to_num(new_format), 0))
        raise RbSDL2Error if ptr.null?
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end

      require_relative 'rw_ops'

      # ファイルから画像を読み込み新たな Surface オブジェクトを生成します。
      # file へ読み込む画像ファイルのパスを与えます。
      # 対応する画像は BMP 形式のみです。
      # 読み込みができない場合は例外（RbSDL2::RbSDL2Error）を発生させます。
      # インデックスカラー（2色、16色）は INDEX8 フォーマットとして読み込まれます。
      def load(file) = RWOps.new(file, "rb") { |rw| load_rw(rw) }

      # RWOps から画像を読み込み新たな Surface オブジェクトを生成します。
      # rw へ RbSDL2::RWOps オブジェクトか RWOps ポインターを与えます。
      # 読み込みができない場合は例外（RbSDL2::RbSDL2Error）を発生させます。
      # このメソッドは与えられたオブジェクトをクローズしません。
      def load_rw(rw)
        ptr = SurfacePointer.new(::SDL.LoadBMP_RW(rw, 0))
        raise RbSDL2Error if ptr.null?
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end

      # 新しい Surface オブジェクトを生成します。
      # w は画像の幅ピクセル数
      # h は画像の縦ピクセル数
      # format は画像フォーマットのを表すシンボルを与えます。
      # format へ FOURCC 系の画像フォーマットを与えた場合は例外を戻します。
      def new(w, h, format)
        ptr = SurfacePointer.new(
          ::SDL.CreateRGBSurfaceWithFormat(0, w, h, 0, PixelFormatEnum.to_num(format)))
        raise RbSDL2Error if ptr.null?
        super(ptr)
      end

      # ポインターから Surface オブジェクトを生成します。
      # ptr へ対象となるポインターを与えます。
      # このメソッドは Surface 構造体の参照カウンターをサポートしています。
      # 生成した Surface オブジェクトは SDL 側で破棄しても Ruby 側のスコープに存在していれば安全に使用できます。
      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, SurfacePointer.to_ptr(ptr))
        obj
      end

      def yuv_conversion_mode_name
        case ::SDL.GetYUVConversionMode
        when ::SDL::YUV_CONVERSION_JPEG then "JPEG"
        when ::SDL::YUV_CONVERSION_BT601 then "BT601"
        when ::SDL::YUV_CONVERSION_BT709 then "BT709"
        when ::SDL::YUV_CONVERSION_AUTOMATIC then "AUTOMATIC"
        else ""
        end
      end

      def yuv_conversion_mode=(mode)
        ::SDL.SetYUVConversionMode(mode)
      end
    end

    def initialize(ptr)
      @st = ::SDL::Surface.new(ptr)
    end

    def ==(other)
      other.respond_to?(:to_ptr) && to_ptr == other.to_ptr
    end

    def alpha_mod
      alpha = ::FFI::MemoryPointer.new(:uint8)
      num = ::SDL.GetSurfaceAlphaMod(self, alpha)
      raise RbSDL2Error if num < 0
      alpha.read_uint8
    end

    def alpha_mod=(alpha)
      num = ::SDL.SetSurfaceAlphaMod(self, alpha)
      raise RbSDL2Error if num < 0
    end

    def blend_mode
      blend = ::FFI::MemoryPointer.new(:int)
      err = ::SDL.GetSurfaceBlendMode(self, blend)
      raise RbSDL2Error if err < 0
      blend.read_int
    end

    require_relative 'surface/blend_mode'
    include BlendMode

    def blend_mode_name = BlendMode.to_name(blend_mode)

    def blend_mode=(blend)
      err = ::SDL.SetSurfaceBlendMode(self, BlendMode.to_num(blend))
      raise RbSDL2Error if err < 0
    end

    def blit(other, from: nil, to: nil, scale: false)
      from &&= Rect.new(*from)
      to &&= Rect.new(*to)
      err = if scale
              ::SDL.UpperBlitScaled(other, from, self, to)
            else
              ::SDL.UpperBlit(other, from, self, to)
            end
      raise RbSDL2Error if err < 0
    end

    def bounds = [0, 0, w, h]

    def bytesize = pitch * height

    def clip
      rect = Rect.new
      ::SDL.GetClipRect(self, rect)
      rect.to_a
    end

    # nil の場合はサーフェィス全域がクリップになる。
    def clip=(rect)
      rect &&= Rect.new(*rect)
      bool = ::SDL.SetClipRect(self, rect)
      raise "out of bounds" if bool == ::SDL::FALSE
    end

    def clear(color = [0, 0, 0, 0]) = fill(bounds, color)

    def color_key
      return unless color_key?
      key = ::FFI::MemoryPointer.new(:uint32)
      err = ::SDL.GetColorKey(self, key)
      return RbSDL2Error if err < 0
      pixel_format.unpack_color(key.read_uint32)
    end

    def color_key=(color)
      err = if color
              ::SDL.SetColorKey(self, ::SDL::TRUE, pixel_format.pack_color(color))
            else
              ::SDL.SetColorKey(self, ::SDL::FALSE, 0)
            end
      raise RbSDL2Error if err < 0
    end

    def color_key? = ::SDL.HasColorKey(self) == ::SDL::TRUE

    def color_mod
      rgb = Array.new(3) { ::FFI::MemoryPointer.new(:uint8) }
      err = ::SDL.GetSurfaceColorMod(self, *rgb)
      raise RbSDL2Error if err < 0
      rgb.map(&:read_uint8)
    end

    def color_mod=(color)
      r, g, b = color
      err = ::SDL.SetSurfaceColorMod(self, r, g, b)
      raise RbSDL2Error if err < 0
    end

    def convert(new_format = format) = Surface.convert(self, new_format)

    def fill(rect = clip, color = [0, 0, 0, 0])
      err = ::SDL.FillRect(self, Rect.new(*rect), pixel_format.pack_color(color))
      raise RbSDL2Error if err < 0
    end

    def height = @st[:h]

    alias h height

    def pitch = @st[:pitch]

    # 指定位置のピクセル・カラーを戻します。
    def color(x, y)
      unpack_pixel(pixel(x, y))
    end

    # 指定位置のピクセル値を戻します。
    def pixel(x, y)
      raise ArgumentError if x < 0 || width <= x
      raise ArgumentError if y < 0 || height <= y

      # RLE の場合にビットマップ・メモリーへアクセスするため synchronize が必要になる。
      synchronize do
        ptr = @st[:pixels] + (pitch * y + bytes_per_pixel * x)
        case bytes_per_pixel
        when 1 then ptr.read_uint8
        when 2 then ptr.read_uint16
        when 3 then ptr.read_uint32 % 0x1000000 # for little endian
        when 4 then ptr.read_uint32
        else
          raise NotImplementedError
        end
      end
    end

    require_relative 'surface/pixel_format'

    # NOTE: @pixel_format へのアクセスは非公開にする予定です。
    def pixel_format
      # SDL_Surface の format メンバーは読み取り専用である。作成時の値が不変であることを前提とする。
      # PixelFormat は参照カウンターで管理されている。
      # 自身を所有している Surface が生きていればリソースが開放されることはない。
      # PixelFormat は Index 系（５種）のみ個別にリソースが確保されている。
      # RGB 系は SDL 側でキャッシュがあればそれを、なければ新しくリソースを確保している。
      @pixel_format ||= PixelFormat.new(@st[:format])
    end

    require 'forwardable'
    extend Forwardable
    def_delegators :pixel_format,
                   *%i(a_mask a_mask? b_mask g_mask r_mask
                   bits_per_pixel bpp bytes_per_pixel format pack_color
                   palette palette= palette? unpack_pixel)

    require_relative 'pixel_format_enum'
    include PixelFormatEnum

    def rle=(bool)
      err = ::SDL.SetSurfaceRLE(self, bool ? 1 : 0)
      raise RbSDL2Error if err < 0
    end

    def rle? = ::SDL.HasSurfaceRLE(self) == ::SDL::TRUE

    require_relative 'rw_ops'

    def save(file) = RWOps.new(file, "wb") { |rw| save_rw(rw); nil }

    # save_rw は与えられたオブジェクトをオートクローズしません。
    def save_rw(rw)
      err = ::SDL.SaveBMP_RW(rw, 0)
      raise RbSDL2Error if err < 0
      rw
    end

    def size = [width, height]

    def synchronize
      ::SDL.LockSurface(self)
      yield(self)
    ensure
      ::SDL.UnlockSurface(self)
    end

    def to_ptr = @st.to_ptr

    def width = @st[:w]

    alias w width
  end
end
