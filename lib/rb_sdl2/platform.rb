module RbSDL2
  module Platform
    class << self
      def platform = ::SDL2.SDL_GetPlatform.read_string
    end
  end
end
