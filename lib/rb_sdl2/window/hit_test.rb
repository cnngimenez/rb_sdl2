module RbSDL2
  class Window
    class HitTest < ::FFI::Function
      @callbacks = {}
      @mutex = Mutex.new

      class << self
        def callback_set(window, obj, userdata = nil)
          func = if Proc === obj
                   new(&obj)
                 else
                   obj
                 end
          @mutex.synchronize do
            err = ::SDL2.SDL_SetWindowHitTest(window, func, userdata)
            raise RbSDL2Error if err < 0
            id = window.id
            if obj
              @callbacks[id] = [func, userdata]
            else
              @callbacks.delete(id)
            end
          end
          [obj, userdata]
        end
      end

      HIT_TEST_RESULT = Hash.new(::SDL2::SDL_HITTEST_NORMAL).merge!(
        :normal => ::SDL2::SDL_HITTEST_NORMAL,
        :draggable => ::SDL2::SDL_HITTEST_DRAGGABLE,
        :top_left => ::SDL2::SDL_HITTEST_RESIZE_TOPLEFT,
        :top => ::SDL2::SDL_HITTEST_RESIZE_TOP,
        :top_right => ::SDL2::SDL_HITTEST_RESIZE_TOPRIGHT,
        :resize_right => ::SDL2::SDL_HITTEST_RESIZE_RIGHT,
        :bottom_right => ::SDL2::SDL_HITTEST_RESIZE_BOTTOMRIGHT,
        :bottom => ::SDL2::SDL_HITTEST_RESIZE_BOTTOM,
        :bottom_left => ::SDL2::SDL_HITTEST_RESIZE_BOTTOMLEFT,
        :resize_left => ::SDL2::SDL_HITTEST_RESIZE_LEFT,
      ).freeze

      def initialize(&block)
        # typedef SDL_HitTestResult (*SDL_HitTest)(SDL_Window *win,
        #                                          const SDL_Point *area, void *data);
        super(:int, [:pointer, :pointer, :pointer]) do |win, area, _data|
          # コールバック実行終了を OS が待つようなので、与えらえた window ポインターは有効なものとしてよいだろう。
          # area には SDL_Point のアドレスが入る。SDL_Point は x, y の２つの int 型メンバーである。
          HIT_TEST_RESULT[yield(Window.to_ptr(win), ::SDL2::SDL_Point.new(area).values)]
        end
      end
    end
  end
end
