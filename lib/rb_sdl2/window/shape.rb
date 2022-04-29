module RbSDL2
  class Window
    module Shape

      class WindowShapeMode < ::SDL::WindowShapeMode
        def alpha_test = self[:parameters][:binarizationCutoff]

        def alpha_test? = [::SDL::ShapeModeBinarizeAlpha, ::SDL::ShapeModeDefault].include?(mode)

        def alpha_test=(num)
          self[:parameters][:binarizationCutoff] = num
        end

        def color_key = self[:parameters][:colorKey].values.first(3)

        def color_key? = ::SDL::ShapeModeColorKey == mode

        def color_key=(color)
          self[:parameters][:colorKey].tap { |c| c[:r], c[:g], c[:b] = color }
        end

        def mode = self[:mode]

        def mode=(num)
          self[:mode] = num
        end

        def reverse_alpha_test? = ::SDL::ShapeModeReverseBinarizeAlpha == mode
      end

      private def shape_mode
        mode = WindowShapeMode.new
        err = ::SDL.GetShapedWindowMode(self, mode)
        # GetShapedWindowMode は INVALID_SHAPE_ARGUMENT を返すことはない。
        if err == ::SDL::NONSHAPEABLE_WINDOW
          raise RbSDL2Error, "unshaped window"
        elsif err == ::SDL::WINDOW_LACKS_SHAPE
          raise RbSDL2Error, "window lacks shape"
        elsif err < 0
          raise RbSDL2Error
        end
        mode
      end

      def alpha_test = shaped? && alpha_test? ? shape_mode.alpha_test : nil

      def alpha_test? = shaped? && shape_mode.alpha_test?

      def color_key = shaped? && color_key? ? shape_mode.color_key : nil

      def color_key? = shaped? && shape_mode.color_key?

      def reverse_alpha_test? = shaped? && shape_mode.reverse_alpha_test?

      # サーフェスにアルファ―チャンネルが含まれていない場合、color_key オプションを与える必要がある。
      # 形状マスクの設定を行う。ウィンドウの描画域は透明なピクセルで埋められている。
      # このメソッド呼び出しの成功後にウィンドウのサーフェスへ描画を行う必要がある。
      # 描画方法はウィンドウのサーフェスまたはレンダラーのどちらを使用してもよい。
      def shape_set(surface, alpha_test: nil, color_key: nil)
        shape = WindowShapeMode.new
        if color_key
          shape.mode = ::SDL::ShapeModeColorKey
          shape.color_key = color_key
        elsif alpha_test&.>= 0
          shape.mode = ::SDL::ShapeModeBinarizeAlpha
          shape.alpha_test = alpha_test
        elsif alpha_test&.< 0
          shape.mode = ::SDL::ShapeModeReverseBinarizeAlpha
          shape.alpha_test = alpha_test.abs
        else
          shape.mode = ::SDL::ShapeModeDefault
        end
        err = ::SDL.SetWindowShape(self, surface, shape)
        # SetWindowShape は WINDOW_LACKS_SHAPE を返すことはない。
        if err == ::SDL::NONSHAPEABLE_WINDOW
          raise RbSDL2Error, "unshaped window"
        elsif err == ::SDL::INVALID_SHAPE_ARGUMENT
          raise RbSDL2Error,
                "Invalid shape argument. \
The size of the window and the size of the surface do not match. \
Or the color key is not specified in the surface without alpha channel."
        elsif err < 0
          raise RbSDL2Error
        end
        surface
      end

      def shaped? = ::SDL.IsShapedWindow(self) == ::SDL::TRUE
    end
  end
end
