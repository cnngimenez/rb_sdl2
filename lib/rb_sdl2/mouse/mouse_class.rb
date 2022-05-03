module RbSDL2
  module Mouse
    class MouseClass
      def initialize(*)
        @button = @x = @y = 0
        update
      end

      attr_accessor :button, :x, :y

      require_relative 'mouse_button'
      include MouseButton

      def position = [x, y]

      def position=(x_y)
        self.x, self.y = x_y
      end

      # 継承先のクラスではこのメソッドをオーバーライドすること。
      # 戻り値は self が戻ることが期待されている。
      def update = raise NotImplementedError
    end
  end
end
