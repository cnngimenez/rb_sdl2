module RbSDL2
  class Window
    module Position
      def position
        x_y = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL.GetWindowPosition(self, *x_y)
        x_y.map(&:read_int)
      end

      def position=(x_y)
        wx, wy = x_y
        wx ||= ::SDL::WINDOWPOS_CENTERED_MASK
        wy ||= ::SDL::WINDOWPOS_CENTERED_MASK
        ::SDL.SetWindowPosition(self, wx, wy)
      end

      def x
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL.GetWindowPosition(self, ptr, nil)
        ptr.read_int
      end

      def x=(num)
        self.position = [num, y]
      end

      def y
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL.GetWindowPosition(self, nil, ptr)
        ptr.read_int
      end

      def y=(num)
        self.position = [x, num]
      end
    end
  end
end
