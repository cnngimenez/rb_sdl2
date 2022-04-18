module RbSDL2
  module Video
    class << self
      def init(driver = nil)
        raise RbSDL2Error if ::SDL.VideoInit(driver) < 0
      end

      def current
        ptr = ::SDL.GetCurrentVideoDriver
        raise RbSDL2Error if ptr.null?
        ptr.read_string
      end

      def drivers
        ::SDL.GetNumVideoDrivers.times.map do |num|
          ptr = ::SDL.GetVideoDriver(num)
          raise RbSDL2Error if ptr.null?
          ptr.read_string
        end
      end

      def quit = ::SDL.VideoQuit

      # SDL アプリケーションがスクリーンセーバーの起動を有効にしている場合に true を戻します。
      # false が戻る場合はスクリーンセーバーの起動が無効です。
      # SDL アプリケーションが起動している間はスクリーンセーバーが起動しません。
      def screen_saver? = ::SDL.IsScreenSaverEnabled == ::SDL::TRUE

      # bool に false を与えたときスクリーンセーバーの起動を無効にすることができます。
      # これは SDL アプリケーション実行中のみシステムに影響を与えます。システムの設定を変更しません。
      # SDL 2.0.2以降 のデフォルトは false です。
      def screen_saver=(bool)
        bool ? ::SDL.EnableScreenSaver : ::SDL.DisableScreenSaver
      end
    end
  end
end
