module RbSDL2
  module Mouse
    module MouseButton
      BUTTON = -> (x) { 1 << x - 1 }
      BUTTON_LMASK  = BUTTON.(::SDL::BUTTON_LEFT)
      BUTTON_MMASK  = BUTTON.(::SDL::BUTTON_MIDDLE)
      BUTTON_RMASK  = BUTTON.(::SDL::BUTTON_RIGHT)
      BUTTON_X1MASK = BUTTON.(::SDL::BUTTON_X1)
      BUTTON_X2MASK = BUTTON.(::SDL::BUTTON_X2)

      def button?(mask) = mask & button != 0

      def any_button? = button != 0

      def left_button? = button?(BUTTON_LMASK)

      def middle_button? = button?(BUTTON_MMASK)

      def right_button? = button?(BUTTON_RMASK)

      def x1_button? = button?(BUTTON_X1MASK)

      def x2_button? = button?(BUTTON_X2MASK)
    end
  end
end
