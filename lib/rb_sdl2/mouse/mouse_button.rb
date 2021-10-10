module RbSDL2
  module Mouse
    module MouseButton
      SDL_BUTTON = -> (x) { 1 << x - 1 }
      SDL_BUTTON_LMASK  = SDL_BUTTON.(::SDL2::SDL_BUTTON_LEFT)
      SDL_BUTTON_MMASK  = SDL_BUTTON.(::SDL2::SDL_BUTTON_MIDDLE)
      SDL_BUTTON_RMASK  = SDL_BUTTON.(::SDL2::SDL_BUTTON_RIGHT)
      SDL_BUTTON_X1MASK = SDL_BUTTON.(::SDL2::SDL_BUTTON_X1)
      SDL_BUTTON_X2MASK = SDL_BUTTON.(::SDL2::SDL_BUTTON_X2)

      def any_button? = button != 0

      def left_button? = SDL_BUTTON_LMASK & button != 0

      def middle_button? = SDL_BUTTON_MMASK & button != 0

      def right_button? = SDL_BUTTON_RMASK & button != 0

      def x1_button? = SDL_BUTTON_X1MASK & button != 0

      def x2_button? = SDL_BUTTON_X2MASK & button != 0
    end
  end
end
