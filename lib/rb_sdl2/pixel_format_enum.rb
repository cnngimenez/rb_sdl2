module RbSDL2
  module PixelFormatEnum
    # SDL の PixelFormatEnum はピクセルフォーマットをビット列にパックしたものである。
    # ビット操作を通じてピクセルフォーマットを構築、分析できる。
    # しかし、SDL API は事前に定義されているフォーマット以外を与えるとエラーになる。
    # ユーザ側で自由なフォーマット定義を行うことはできない。
    # Ruby 側でフォーマットの詳細を知るため目的に応じたフォーマット集合を作成することにした。
    # これはコードのメンテナンスを考慮したためである。
    #
    # [[name, num, type, alpha], ...]
    table = [
      [:index1lsb, ::SDL::PIXELFORMAT_INDEX1LSB, :indexed, false],
      [:index1msb, ::SDL::PIXELFORMAT_INDEX1MSB, :indexed, false],
      [:index4lsb, ::SDL::PIXELFORMAT_INDEX4LSB, :indexed, false],
      [:index4msb, ::SDL::PIXELFORMAT_INDEX4MSB, :indexed, false],
      [:index8, ::SDL::PIXELFORMAT_INDEX8, :indexed, false],
      [:rgb332, ::SDL::PIXELFORMAT_RGB332, :packed, false],
      [:xrgb4444, ::SDL::PIXELFORMAT_XRGB4444, :packed, false],
      [:rgb444, ::SDL::PIXELFORMAT_RGB444, :packed, false],
      [:xbgr4444, ::SDL::PIXELFORMAT_XBGR4444, :packed, false],
      [:bgr444, ::SDL::PIXELFORMAT_BGR444, :packed, false],
      [:xrgb1555, ::SDL::PIXELFORMAT_XRGB1555, :packed, false],
      [:rgb555, ::SDL::PIXELFORMAT_RGB555, :packed, false],
      [:xbgr1555, ::SDL::PIXELFORMAT_XBGR1555, :packed, false],
      [:bgr555, ::SDL::PIXELFORMAT_BGR555, :packed, false],
      [:argb4444, ::SDL::PIXELFORMAT_ARGB4444, :packed, true],
      [:rgba4444, ::SDL::PIXELFORMAT_RGBA4444, :packed, true],
      [:abgr4444, ::SDL::PIXELFORMAT_ABGR4444, :packed, true],
      [:bgra4444, ::SDL::PIXELFORMAT_BGRA4444, :packed, true],
      [:argb1555, ::SDL::PIXELFORMAT_ARGB1555, :packed, true],
      [:rgba5551, ::SDL::PIXELFORMAT_RGBA5551, :packed, true],
      [:abgr1555, ::SDL::PIXELFORMAT_ABGR1555, :packed, true],
      [:bgra5551, ::SDL::PIXELFORMAT_BGRA5551, :packed, true],
      [:rgb565, ::SDL::PIXELFORMAT_RGB565, :packed, false],
      [:bgr565, ::SDL::PIXELFORMAT_BGR565, :packed, false],
      [:rgb24, ::SDL::PIXELFORMAT_RGB24, :array, false],
      [:bgr24, ::SDL::PIXELFORMAT_BGR24, :array, false],
      [:xrgb8888, ::SDL::PIXELFORMAT_XRGB8888, :packed, false],
      [:rgb888, ::SDL::PIXELFORMAT_RGB888, :packed, false],
      [:rgbx8888, ::SDL::PIXELFORMAT_RGBX8888, :packed, false],
      [:xbgr8888, ::SDL::PIXELFORMAT_XBGR8888, :packed, false],
      [:bgr888, ::SDL::PIXELFORMAT_BGR888, :packed, false],
      [:bgrx8888, ::SDL::PIXELFORMAT_BGRX8888, :packed, false],
      [:argb8888, ::SDL::PIXELFORMAT_ARGB8888, :packed, true],
      [:rgba8888, ::SDL::PIXELFORMAT_RGBA8888, :packed, true],
      [:abgr8888, ::SDL::PIXELFORMAT_ABGR8888, :packed, true],
      [:bgra8888, ::SDL::PIXELFORMAT_BGRA8888, :packed, true],
      [:argb2101010, ::SDL::PIXELFORMAT_ARGB2101010, :packed, true],
      [:rgba32, ::SDL::PIXELFORMAT_RGBA32, :packed, true],
      [:argb32, ::SDL::PIXELFORMAT_ARGB32, :packed, true],
      [:bgra32, ::SDL::PIXELFORMAT_BGRA32, :packed, true],
      [:abgr32, ::SDL::PIXELFORMAT_ABGR32, :packed, true],
      [:yv12, ::SDL::PIXELFORMAT_YV12, :fourcc, false],
      [:iyuv, ::SDL::PIXELFORMAT_IYUV, :fourcc, false],
      [:yuy2, ::SDL::PIXELFORMAT_YUY2, :fourcc, false],
      [:uyvy, ::SDL::PIXELFORMAT_UYVY, :fourcc, false],
      [:yvyu, ::SDL::PIXELFORMAT_YVYU, :fourcc, false],
      [:nv12, ::SDL::PIXELFORMAT_NV12, :fourcc, false],
      [:nv21, ::SDL::PIXELFORMAT_NV21, :fourcc, false],
      [:external_oes, ::SDL::PIXELFORMAT_EXTERNAL_OES, :fourcc, false],
    ]

    FORMAT_MAP = table.map { |name, num, _, _| [name, num] }.to_h.freeze

    INDEXED_TYPES = table.inject([]) { |a, _, num, type, _| a << num if type == :indexed }.freeze

    WITH_ALPHA = table.inject([]) { |a, _, num, _, alpha| a << num if alpha }.freeze

    class << self
      # obj に与えたピクセルフォーマットに応じた整数値を戻す。
      def to_num(obj)
        case obj
        when Symbol, String
          sym = obj.to_sym.downcase
          if FORMAT_MAP.key?(sym)
            FORMAT_MAP[sym]
          else
            raise ArgumentError, "Invalid format name"
          end
        else
          raise ArgumentError
        end
      end
    end

    # FOURCC が無い場合は nil を戻す。
    def fourcc
      4.times.inject([]) { |n, i| n << (num >> i * 8) % 0x100 }.pack("c4") if fourcc?
    end

    def fourcc? = (format >> 28) & 0x0F != 1

    def format_name = ::SDL.GetPixelFormatName(format).read_string.delete_prefix("SDL_PIXELFORMAT_")

    def indexed_color? = PixelFormatEnum::INDEXED_TYPES.include?(format)

    def rgb? = !(fourcc? || indexed_color? || rgba?)

    def rgba? = PixelFormatEnum::WITH_ALPHA.include?(format)
  end
end
