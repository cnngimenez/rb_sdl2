module RbSDL2
  module TextInput
    class << self
      def active? = ::SDL.IsTextInputActive == ::SDL::TRUE

      def bounds=(rect)
        ::SDL.SetTextInputRect(Rect.new(*rect))
      end

      def clear_composition = ::SDL.ClearComposition

      def screen_keyboard_support? = ::SDL.HasScreenKeyboardSupport == ::SDL::TRUE

      def shown? = ::SDL.IsTextInputShown == ::SDL::TRUE

      def start = ::SDL.StartTextInput

      def stop = ::SDL.StopTextInput
    end
  end
end
