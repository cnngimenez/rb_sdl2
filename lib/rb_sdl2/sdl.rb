module RbSDL2
  module SDL
    module InitFlags
      class << self
        def to_num(audio: false, events: false, game_controller: false, haptic: false,
                   joystick: false, sensor: false, timer: false, video: false)
          num = 0 |
            (audio ? ::SDL::INIT_TIMER : 0) |
            (events ? ::SDL::INIT_EVENTS : 0) |
            (game_controller ? ::SDL::INIT_GAMECONTROLLER : 0) |
            (haptic ? ::SDL::INIT_HAPTIC : 0) |
            (joystick ? ::SDL::INIT_JOYSTICK : 0) |
            (sensor ? ::SDL::INIT_SENSOR : 0) |
            (timer ? ::SDL::INIT_TIMER : 0) |
            (video ? ::SDL::INIT_VIDEO : 0)
          num == 0 ? ::SDL::INIT_EVERYTHING : num
        end
      end
    end

    class << self
      # SDL を初期化します。
      # flags に起動したい SDL サブシステムをキーにオプション引数（値は true で起動）で与えます。
      # flags を指定指定しない場合は全ての SDL コンポーネントが起動します。
      # オプション引数のキーは audio, events, game_controller, haptic, joystick, sensor, timer, video
      # があります。
      def init(**flags)
        err = ::SDL.Init(InitFlags.to_num(**flags))
        raise RbSDL2Error if err < 0
      end

      # SDL サブシステムが初期化されているか確認します。
      # アプリケーション作成者が必要とする SDL サブシステム初期化されているか確認できます。
      # flags に与えたオプションの状態と一致した時のみ true を返します。
      # 部分的な一致の場合は false を返します。
      def init?(**flags) = ::SDL.WasInit(mask = InitFlags.to_num(**flags)) == mask

      # SDL を終了します。RbSDL2 ではアプリケーションの終了時にこのメソッドを呼ぶ必要はありません。
      # 終了後に再び SDL サブシステムを起動する必要がある場合は再度 init メソッドを呼ぶことができます。
      # このメソッドは何度でも呼び出すことができます。
      def quit = ::SDL.Quit
    end
  end
end
