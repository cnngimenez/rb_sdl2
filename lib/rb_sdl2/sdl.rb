module RbSDL2
  module SDL
    class << self
      # SDL を初期化します。
      # flags に起動したい SDL サブシステムのシンボルで指定します。
      # flags を指定指定しない場合は全ての SDL サブシステムが起動します。
      # SDL サブシステムのシンボルは
      # :audio, :events, :game_controller, :haptic, :joystick, :sensor, :timer, :video
      # です。
      def init(*flags)
        err = ::SDL.Init(to_num(*flags))
        raise RbSDL2Error if err < 0
      end

      # SDL サブシステムが初期化されているか確認します。
      # flags に与えたシンボルの SDL サブシステムが全て起動している時に true を戻します。
      def init?(*flags) = ::SDL.WasInit(mask = to_num(*flags)) == mask

      # SDL を終了します。RbSDL2 ではアプリケーションの終了時にこのメソッドを呼ぶ必要はありません。
      # 終了後に再び SDL サブシステムを起動する必要がある場合は再度 init メソッドを呼ぶことができます。
      # このメソッドは何度でも呼び出すことができます。
      def quit = ::SDL.Quit

      private def to_num(*flags)
        flags.inject(0) { |num, sym|
          num | case sym
                when :audio then ::SDL::INIT_AUDIO
                when :events then ::SDL::INIT_EVENTS
                when :game_controller then ::SDL::INIT_GAMECONTROLLER
                when :haptic then ::SDL::INIT_HAPTIC
                when :joystick then ::SDL::INIT_JOYSTICK
                when :sensor then ::SDL::INIT_SENSOR
                when :timer then ::SDL::INIT_TIMER
                when :video then ::SDL::INIT_VIDEO
                else
                  raise ArgumentError, "Invalid sub system name(#{sym})"
                end
        }.nonzero? || ::SDL::INIT_EVERYTHING
      end
    end
  end
end
