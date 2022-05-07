module RbSDL2
  class Window
    module Accessor
      def border_size
        top_left_bottom_right = Array.new(4) { ::FFI::MemoryPointer.new(:int) }
        err = ::SDL.GetWindowBordersSize(self, *top_left_bottom_right)
        raise RbSDL2Error if err < 0
        top_left_bottom_right.map(&:read_int)
      end

      def height
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL.GetWindowSize(self, nil, ptr)
        ptr.read_int
      end
      alias h height

      def height=(num)
        self.size = [w, num]
      end
      alias h= height=

      def icon=(surface)
        ::SDL.SetWindowIcon(self, surface)
      end

      def maximum_size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL.GetWindowMaximumSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def maximum_size=(w_h)
        ::SDL.SetWindowMaximumSize(self, *w_h)
      end

      def minimum_size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL.GetWindowMinimumSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def minimum_size=(w_h)
        ::SDL.SetWindowMinimumSize(self, *w_h)
      end

      # 戻り値が nil の場合は範囲が設定されていません。
      def mouse_rect
        ptr = ::SDL.GetWindowMouseRect(self)
        ptr.null? ? nil : Rect.to_ary(ptr)
      end

      # 範囲を破棄する場合は rect には nil を与えます。
      def mouse_rect=(rect)
        err = ::SDL.SetWindowMouseRect(self, rect && Rect.new(*rect))
        raise RbSDL2Error if err < 0
      end

      # ウィンドウの透明度を戻す。値は 0.0 から 1.0。値が低いほど透明になる。
      def opacity
        out_opacity = ::FFI::MemoryPointer.new(:float)
        err = ::SDL.GetWindowOpacity(self, out_opacity)
        raise RbSDL2Error if err < 0
        out_opacity.read_float
      end

      # ウィンドウの透明度を変更する。値は 0.0 から 1.0。値が低いほど透明になる。
      def opacity=(val)
        err = ::SDL.SetWindowOpacity(self, val)
        raise RbSDL2Error if err < 0
      end

      def position
        x_y = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL.GetWindowPosition(self, *x_y)
        x_y.map(&:read_int)
      end

      def position=(x_y)
        wx, wy = x_y
        ::SDL.SetWindowPosition(self,
                                wx || SDL_WINDOWPOS_CENTERED_MASK,
                                wy || SDL_WINDOWPOS_CENTERED_MASK)
      end

      def size
        w_h = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
        ::SDL.GetWindowSize(self, *w_h)
        w_h.map(&:read_int)
      end

      def size=(w_h)
        ::SDL.SetWindowSize(self, *w_h)
      end

      def title = SDL.ptr_to_str(::SDL.GetWindowTitle(self))

      def title=(s)
        ::SDL.SetWindowTitle(self, SDL.str_to_sdl(s))
      end

      def width
        ptr = ::FFI::MemoryPointer.new(:int)
        ::SDL.GetWindowSize(self, ptr, nil)
        ptr.read_int
      end
      alias w width

      def width=(num)
        self.size = [num, h]
      end
      alias w= width=

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
