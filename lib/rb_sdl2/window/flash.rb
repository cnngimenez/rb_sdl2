module RbSDL2
  class Window
    module Flash
      SDL_FLASH_CANCEL = 0
      SDL_FLASH_BRIEFLY = 1
      SDL_FLASH_UNTIL_FOCUSED = 2

      def flash(bool = true)
        operation = bool ? SDL_FLASH_UNTIL_FOCUSED : SDL_FLASH_CANCEL
        err = ::SDL.FlashWindow(self, operation)
        raise RbSDL2Error if err < 0
        bool
      end

      def flash!
        err = ::SDL.FlashWindow(self, SDL_FLASH_BRIEFLY)
        raise RbSDL2Error if err < 0
        self
      end
    end
  end
end
