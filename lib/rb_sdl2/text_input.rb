module RbSDL2
  module TextInput
    class << self
      def active? = ::SDL2.SDL_IsTextInputActive == ::SDL2::SDL_TRUE

      def bounds=(rect)
        ::SDL2.SDL_SetTextInputRect(Rect.new(*rect))
      end

      def start = ::SDL2.SDL_StartTextInput

      def stop = ::SDL2.SDL_StopTextInput
    end
  end
end
