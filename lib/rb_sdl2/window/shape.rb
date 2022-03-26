module RbSDL2
  class Window
    module Shape
      private def shape_mode
        mode = ::SDL::WindowShapeMode.new
        num = ::SDL.GetShapedWindowMode(self, mode)
        # GetShapedWindowMode は INVALID_SHAPE_ARGUMENT を返すことはない。
        if num == ::SDL::NONSHAPEABLE_WINDOW
          raise RbSDL2Error, "unshaped window"
        elsif num == ::SDL::WINDOW_LACKS_SHAPE
          raise RbSDL2Error, "window lacks shape"
        elsif num < 0
          raise RbSDL2Error
        end
        mode
      end

      def alpha_test
        shape_mode[:parameters][:binarizationCutoff] unless shaped? && color_key?
      end

      def alpha_test?
        shaped? && [::SDL::ShapeModeBinarizeAlpha,
                    ::SDL::ShapeModeDefault].include?(shape_mode[:mode])
      end

      def color_key
        shape_mode[:parameters][:colorKey].values if shaped? && color_key?
      end

      def color_key?
        shaped? && ::SDL::ShapeModeColorKey == shape_mode[:mode]
      end

      def reverse_alpha_test?
        shaped? && ::SDL::ShapeModeReverseBinarizeAlpha == shape_mode[:mode]
      end

      # サーフェスにアルファ―チャンネルが含まれていない場合、color_key オプションを与える必要がある。
      # 形状マスクの設定を行う。ウィンドウの描画域は透明なピクセルで埋められている。
      # このメソッド呼び出しの成功後にウィンドウのサーフェスへ描画を行う必要がある。
      # 描画方法はウィンドウのサーフェスまたはレンダラーのどちらを使用してもよい。
      def shape_set(surface, alpha_test: nil, color_key: nil)
        mode = ::SDL::WindowShapeMode.new.tap do |st|
          st[:mode] = if color_key
                        st[:parameters][:colorKey].tap { |c| c[:r], c[:g], c[:b] = color_key }
                        ::SDL::ShapeModeColorKey
                      elsif alpha_test&.>= 0
                        st[:parameters][:binarizationCutoff] = alpha_test
                        ::SDL::ShapeModeBinarizeAlpha
                      elsif alpha_test&.< 0
                        st[:parameters][:binarizationCutoff] = alpha_test.abs
                        ::SDL::ShapeModeReverseBinarizeAlpha
                      else
                        ::SDL::ShapeModeDefault
                      end
        end
        err = ::SDL.SetWindowShape(self, surface, mode)
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
