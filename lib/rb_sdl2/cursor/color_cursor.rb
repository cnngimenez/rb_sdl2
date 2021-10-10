module RbSDL2
  module Cursor
    require_relative 'cursor_class'

    class ColorCursor < CursorClass
      class << self
        require_relative 'cursor_pointer'

        def new(surface, hot_x = 0, hot_y = 0)
          # SDL_CreateColorCursor は与えられた surface をコピーする。
          # 呼び出し後に引数に与えた surface オブジェクトは安全に開放できる。
          ptr = CursorPointer.new(::SDL2.SDL_CreateColorCursor(surface, hot_x, hot_y))
          raise RbSDL2Error if ptr.null?
          super(ptr)
        end
      end
    end
  end
end
