module RbSDL2
  class Window
    module Display
      # Brightness はウィンドウ単体ではなくウインドウの中心があるディスプレイの輝度の取得、変更を行う。
      # 対象となるディスプレイの取得は Window＃display メソッドを呼び出す。
      def brightness = ::SDL2.SDL_GetWindowBrightness(self)

      def brightness=(float)
        err = ::SDL2.SDL_SetWindowBrightness(self, float)
        raise RbSDL2Error if err < 0
      end

      require_relative '../display'

      def display = Display.new(display_index)

      def display_index
        index = ::SDL2.SDL_GetWindowDisplayIndex(to_ptr)
        raise RbSDL2Error if index < 0
        index
      end

      require_relative '../display_mode'
      def fullscreen_display_mode
        obj = DisplayMode.new
        err = ::SDL2.SDL_GetWindowDisplayMode(self, obj)
        raise RbSDL2Error if err < 0
        obj
      end

      def fullscreen_display_mode=(display_mode)
        err = ::SDL2.SDL_SetWindowDisplayMode(self, display_mode)
        raise RbSDL2Error if err < 0
      end

      class GammaRamp
        class << self
          def [](*a)
            raise ArgumentError if a.length != 256
            ptr = ::FFI::MemoryPointer.new(:uint16, 256).write_array_of_uint16(a)
            obj = allocate
            obj.__send__(:initialize, ptr)
            obj
          end

          def new(gamma)
            ptr = ::FFI::MemoryPointer.new(:uint16, 256)
            ::SDL2.SDL_CalculateGammaRamp(gamma, ptr)
            super(ptr)
          end
        end

        def initialize(ptr)
          @ptr = ptr
        end

        def to_ptr = @ptr

        def to_a = @ptr.read_array_of_uint16(256)
        alias to_ary to_a
      end

      # [r_gamma, g_gamma, b_gamma] | gamma
      def gamma=(rgb)
        r, g, b = *rgb
        self.gamma_ramp = (!g && !b ? [r, r, r] : [r, g, b]).map { |f| GammaRamp.new(f) }
      end

      def gamma_ramp
        rgb = Array.new(3) { GammaRamp.new }
        err = ::SDL2.SDL_GetWindowGammaRamp(self, *rgb)
        raise RbSDL2Error if err < 0
        rgb.map(&:to_a)
      end

      # r_g_b: [[r,...],[g,...],[b,...]]
      # 画面全体に影響を与える。OSからリセットされることもある。
      # アプリケーションが終了しても永続的に影響をあたえる。ユーザにとって望ましくないだろう。
      def gamma_ramp=(r_g_b)
        err = ::SDL2.SDL_SetWindowGammaRamp(self, *r_g_b.map { |a| GammaRamp[*a] })
        raise RbSDL2Error if err < 0
      end
    end
  end
end
