module RbSDL2
  module Mouse
    class MouseClass
      require 'singleton'
      include Singleton

      def initialize
        @button = 0
        @x_ptr, @y_ptr = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
      end

      attr_reader :button
      private attr_writer :button

      require_relative 'mouse_button'
      include MouseButton

      def position = [x, y]

      # 継承先のクラスではこのメソッドをオーバーライドすること。
      # 戻り値は self が戻ることが期待されている。
      def update = self

      private attr_reader :x_ptr

      def x = x_ptr.read_int

      private attr_reader :y_ptr

      def y = y_ptr.read_int
    end
  end
end
