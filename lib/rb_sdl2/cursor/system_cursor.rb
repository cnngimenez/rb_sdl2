module RbSDL2
  module Cursor
    require_relative 'cursor_class'

    class SystemCursor < CursorClass
      require_relative 'cursor_pointer'

      @cursors = Array.new(::SDL2::SDL_NUM_SYSTEM_CURSORS)

      class << self
        private def new(id)
          return @cursors[id] if @cursors[id]

          ptr = CursorPointer.new(::SDL2.SDL_CreateSystemCursor(id))
          raise RbSDL2Error if ptr.null?
          @cursors[id] = super(ptr)
        end

        def arrow_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_ARROW)

        def crosshair_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_CROSSHAIR)

        def hand_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_HAND)

        def i_beam_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_IBEAM)

        def no_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_NO)

        def size_all_cursor = new(SDL_SYSTEM_CURSOR_SIZEALL)

        def size_ne_sw_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_SIZENESW)

        def size_ns_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_SIZENS)

        def size_nw_se_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_SIZENWSE)

        def size_we_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_SIZEWE)

        def wait_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_WAIT)

        def wait_arrow_cursor = new(::SDL2::SDL_SYSTEM_CURSOR_WAITARROW)
      end
    end
  end
end
