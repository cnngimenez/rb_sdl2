module RbSDL2
  module Mouse
    module MouseButton
      BUTTON = -> (x) { 1 << x - 1 }
      BUTTON_LMASK  = BUTTON.(::SDL::BUTTON_LEFT)
      BUTTON_MMASK  = BUTTON.(::SDL::BUTTON_MIDDLE)
      BUTTON_RMASK  = BUTTON.(::SDL::BUTTON_RIGHT)
      BUTTON_X1MASK = BUTTON.(::SDL::BUTTON_X1)
      BUTTON_X2MASK = BUTTON.(::SDL::BUTTON_X2)

      def any_button? = button != 0

      def left_button? = BUTTON_LMASK & button != 0

      def middle_button? = BUTTON_MMASK & button != 0

      def right_button? = BUTTON_RMASK & button != 0

      def x1_button? = BUTTON_X1MASK & button != 0

      def x2_button? = BUTTON_X2MASK & button != 0
    end
  end
end
