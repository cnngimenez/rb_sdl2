module RbSDL2
  module Cursor
    require_relative 'cursor_class'

    class DefaultCursor < CursorClass
      class << self
        def new
          ptr = ::SDL2.SDL_GetDefaultCursor
          raise RbSDL2Error if ptr.null?
          super(ptr)
        end
      end

      require 'singleton'
      include Singleton
    end
  end
end
