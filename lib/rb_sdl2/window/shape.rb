module RbSDL2
  class Window
    module Shape
      private def shape_mode
        mode = ::SDL2::SDL_WindowShapeMode.new
        num = ::SDL2.SDL_GetShapedWindowMode(self, mode)
        # SDL_GetShapedWindowMode は SDL_INVALID_SHAPE_ARGUMENT を返すことはない。
        if num == ::SDL2::SDL_NONSHAPEABLE_WINDOW
          raise RbSDL2Error, "unshaped window"
        elsif num == ::SDL2::SDL_WINDOW_LACKS_SHAPE
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
        shaped? && [::SDL2::ShapeModeBinarizeAlpha,
                    ::SDL2::ShapeModeDefault].include?(shape_mode[:mode])
      end

      def color_key
        shape_mode[:parameters][:colorKey].values if shaped? && color_key?
      end

      def color_key?
        shaped? && ::SDL2::ShapeModeColorKey == shape_mode[:mode]
      end

      def reverse_alpha_test?
        shaped? && ::SDL2::ShapeModeReverseBinarizeAlpha == shape_mode[:mode]
      end

      # サーフェスにアルファ―チャンネルが含まれていない場合、color_key オプションを与える必要がある。
      # 形状マスクの設定を行う。ウィンドウの描画域は透明なピクセルで埋められている。
      # このメソッド呼び出しの成功後にウィンドウのサーフェスへ描画を行う必要がある。
      # 描画方法はウィンドウのサーフェスまたはレンダラーのどちらを使用してもよい。
      def shape_set(surface, alpha_test: nil, color_key: nil)
        mode = ::SDL2::SDL_WindowShapeMode.new.tap do |st|
          st[:mode] = if color_key
                        st[:parameters][:colorKey].tap { |c| c[:r], c[:g], c[:b] = color_key }
                        ::SDL2::ShapeModeColorKey
                      elsif alpha_test&.>= 0
                        st[:parameters][:binarizationCutoff] = alpha_test
                        ::SDL2::ShapeModeBinarizeAlpha
                      elsif alpha_test&.< 0
                        st[:parameters][:binarizationCutoff] = alpha_test.abs
                        ::SDL2::ShapeModeReverseBinarizeAlpha
                      else
                        ::SDL2::ShapeModeDefault
                      end
        end
        err = ::SDL2.SDL_SetWindowShape(self, surface, mode)
        # SDL_SetWindowShape は SDL_WINDOW_LACKS_SHAPE を返すことはない。
        if err == ::SDL2::SDL_NONSHAPEABLE_WINDOW
          raise RbSDL2Error, "unshaped window"
        elsif err == ::SDL2::SDL_INVALID_SHAPE_ARGUMENT
          raise RbSDL2Error,
                "Invalid shape argument. \
The size of the window and the size of the surface do not match. \
Or the color key is not specified in the surface without alpha channel."
        elsif err < 0
          raise RbSDL2Error
        end
        surface
      end

      def shaped? = ::SDL2.SDL_IsShapedWindow(self) == ::SDL2::SDL_TRUE
    end
  end
end
