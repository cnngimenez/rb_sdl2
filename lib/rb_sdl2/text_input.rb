module RbSDL2
  module TextInput
    class << self
      def active? = ::SDL.IsTextInputActive == ::SDL::TRUE

      def bounds=(rect)
        ::SDL.SetTextInputRect(Rect.new(*rect))
      end

      def start = ::SDL.StartTextInput

      def stop = ::SDL.StopTextInput
    end
  end
end
