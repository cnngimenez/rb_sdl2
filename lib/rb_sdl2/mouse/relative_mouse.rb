module RbSDL2
  module Mouse
    require_relative 'mouse_class'

    class RelativeMouse < MouseClass
      require 'singleton'
      include Singleton

      @_x = ::FFI::MemoryPointer.new(:int)
      @_y = ::FFI::MemoryPointer.new(:int)

      class << self
        def update
          self.button, self.x, self.y =
            ::SDL.GetRelativeMouseState(@_x, @_y), @_x.read_int, @_y.read_int
          self
        end
      end

      def update
        self.class.update
        self
      end
    end
  end
end
