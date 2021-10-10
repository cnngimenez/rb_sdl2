module RbSDL2
  class Window
    module Size
      def height
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL2.SDL_GetWindowSize(self, nil, ptr)
        ptr.read_int
      end
      alias h height

      def height=(num)
        self.size = [w, num]
      end
      alias h= height=

      def maximum_size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL2.SDL_GetWindowMaximumSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def maximum_size=(w_h)
        ::SDL2.SDL_SetWindowMaximumSize(self, *w_h)
      end

      def minimum_size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL2.SDL_GetWindowMinimumSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def minimum_size=(w_h)
        ::SDL2.SDL_SetWindowMinimumSize(self, *w_h)
      end

      def size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL2.SDL_GetWindowSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def size=(w_h)
        ::SDL2.SDL_SetWindowSize(self, *w_h)
      end

      def width
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL2.SDL_GetWindowSize(self, ptr, nil)
        ptr.read_int
      end
      alias w width

      def width=(num)
        self.size = [num, h]
      end
      alias w= width=
    end
  end
end
