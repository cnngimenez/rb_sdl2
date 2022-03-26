module RbSDL2
  module PixelFormatEnum
    names = ::SDL.constants.grep(/\APIXELFORMAT_/)
    values = names.map { |n| ::SDL.const_get(n) }
    FORMAT_MAP = names.zip(values).to_h.freeze

    INDEXED_TYPES = [::SDL::PIXELTYPE_INDEX1, ::SDL::PIXELTYPE_INDEX4,
                     ::SDL::PIXELTYPE_INDEX8].freeze

    PACKED_TYPES = [::SDL::PIXELTYPE_PACKED8, ::SDL::PIXELTYPE_PACKED16,
                    ::SDL::PIXELTYPE_PACKED32].freeze

    ARRAY_TYPES = [::SDL::PIXELTYPE_ARRAYU8, ::SDL::PIXELTYPE_ARRAYU16,
                   ::SDL::PIXELTYPE_ARRAYU32, ::SDL::PIXELTYPE_ARRAYF16,
                   ::SDL::PIXELTYPE_ARRAYF32].freeze

    PACKED_ORDERS = [::SDL::PACKEDORDER_ARGB, ::SDL::PACKEDORDER_RGBA,
                     ::SDL::PACKEDORDER_ABGR, ::SDL::PACKEDORDER_BGRA].freeze

    ARRAY_ORDERS = [::SDL::ARRAYORDER_ARGB, ::SDL::ARRAYORDER_RGBA,
                    ::SDL::ARRAYORDER_ABGR, ::SDL::ARRAYORDER_BGRA].freeze

    class << self
      def array_type?(num) = !fourcc?(num) && ARRAY_TYPES.include?(to_type(num))

      def fourcc?(num) = (num >> 28) & 0x0F != 1

      def indexed_type?(num) = !fourcc?(num) && INDEXED_TYPES.include?(to_type(num))

      def packed_type?(num) = !fourcc?(num) && PACKED_TYPES.include?(to_type(num))

      def to_fourcc(num)
        4.times.inject([]) { |n, i| n << (num >> i * 8) % 0x100 }.pack("c4") if fourcc?
      end

      def to_name(num) = ::SDL.GetPixelFormatName(num).read_string

      # obj は SDL の PIXELFORMAT_* 定数のどれか、または定数名でもよい。
      # 定数名は RGBA32 のような短縮した名前でもよい。"UNKNOWN" も受け取れる（値は 0）。
      # 該当するフォーマットがない場合は 0 (PIXELFORMAT_UNKNOWN) を戻す。
      # SDL はオリジナルのフォーマットを処理しないことに注意。
      def to_num(obj)
        name = if Symbol === obj || String === obj
                 obj.match?(/\APIXELFORMAT_/) ? obj : "PIXELFORMAT_#{obj.upcase}"
               else
                 to_name(obj)
               end
        FORMAT_MAP[name.to_sym].to_i
      end

      def to_order(num) = fourcc?(num) ? 0 : (num >> 20) & 0x0F

      def to_type(num) = fourcc?(num) ? 0 : (num >> 24) & 0x0F

      def with_alpha?(num)
        packed_type?(num) && PACKED_ORDERS.include?(to_order(num)) ||
          array_type?(num) && ARRAY_ORDERS.include?(to_order(num))
      end
    end

    def fourcc = PixelFormatEnum.to_fourcc(format)

    def fourcc? = PixelFormatEnum.fourcc?(format)

    def format_name = PixelFormatEnum.to_name(format)

    def indexed_color? = PixelFormatEnum.indexed_type?(format)

    def rgb? = !(fourcc? || indexed_color? || rgba?)

    def rgba? = PixelFormatEnum.with_alpha?(format)
  end
end
