module RbSDL2
  class Rect
    def initialize(x = 0, y = 0, w = 0, h = 0)
      @st = ::SDL::Rect.new
      @st[:x], @st[:y], @st[:w], @st[:h] = x, y, w, h
    end

    def to_a = @st.values

    alias to_ary to_a

    def to_ptr = @st.to_ptr
  end
end
