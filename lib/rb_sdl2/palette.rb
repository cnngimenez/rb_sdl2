module RbSDL2
  class Palette
    require_relative 'ref_count_pointer'

    class PalettePointer < RefCountPointer
      class << self
        def release(ptr) = ::SDL2.SDL_FreePalette(ptr)

        def entity_class = ::SDL2::SDL_Palette
      end
    end

    class << self
      def [](*color)
        plt = new(color.length)
        color.each.with_index { |c, nth| plt[nth] = c }
        plt
      end

      def new(num_colors)
        ptr = PalettePointer.new(::SDL2.SDL_AllocPalette(num_colors))
        raise RbSDL2Error if ptr.null?
        super(ptr)
      end

      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, PalettePointer.to_ptr(ptr))
        obj
      end
    end

    def initialize(ptr)
      @st = ::SDL2::SDL_Palette.new(ptr)
    end

    def ==(other)
      other.respond_to?(:to_ptr) && to_ptr == other.to_ptr
    end

    def [](nth)
      raise ArgumentError if nth < 0 || length <= nth
      ::SDL2::SDL_Color.new(@st[:colors] + ::SDL2::SDL_Color.size * nth).values
    end

    # color 引数には ３要素以上の配列であること。４要素目以降は無視される。
    # color 引数は内部で splat する。これに対応していれば配列以外のオブジェクトでもよい。
    # パレットのカラーが描画に使われるときはアルファ値は無視されて不透明(SDL_ALPHA_OPAQUE)として扱わられる。
    # パレットのカラーは作成時に全て [255, 255, 255, 255] で埋められている。
    def []=(nth, color)
      raise ArgumentError if nth < 0 || length <= nth
      c = ::SDL2::SDL_Color.new
      c[:r], c[:g], c[:b] = color
      err = ::SDL2.SDL_SetPaletteColors(self, c, nth, 1)
      raise RbSDL2Error if err < 0
    end

    def each = length.times { |nth| yield(self[nth]) }

    def inspect
      "#<#{self.class.name} ptr=#{to_ptr.inspect} colors=#{length} version=#{version}>"
    end

    def length = @st[:ncolors]

    alias size length

    def to_a = to_enum.to_a

    def to_ptr = @st.to_ptr

    def version = @st[:version]
  end
end
