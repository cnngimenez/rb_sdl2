module RbSDL2
  module Error
    class << self
      def clear = ::SDL2.SDL_ClearError

      def message = ::SDL2.SDL_GetError.read_string
    end
  end
end
