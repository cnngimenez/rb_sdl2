module RbSDL2
  module SDL
    SDL_INIT_TIMER          = 0x00000001
    SDL_INIT_AUDIO          = 0x00000010
    SDL_INIT_VIDEO          = 0x00000020
    SDL_INIT_JOYSTICK       = 0x00000200
    SDL_INIT_HAPTIC         = 0x00001000
    SDL_INIT_GAMECONTROLLER = 0x00002000
    SDL_INIT_EVENTS         = 0x00004000
    SDL_INIT_SENSOR         = 0x00008000

    SDL_INIT_EVERYTHING = SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS |
      SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_GAMECONTROLLER | SDL_INIT_SENSOR

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
                when :audio then SDL_INIT_AUDIO
                when :events then SDL_INIT_EVENTS
                when :game_controller then SDL_INIT_GAMECONTROLLER
                when :haptic then SDL_INIT_HAPTIC
                when :joystick then SDL_INIT_JOYSTICK
                when :sensor then SDL_INIT_SENSOR
                when :timer then SDL_INIT_TIMER
                when :video then SDL_INIT_VIDEO
                else
                  raise ArgumentError, "Invalid sub system name(#{sym})"
                end
        }.nonzero? || SDL_INIT_EVERYTHING
      end

      # SDL String(C String, UTF-8) を Ruby String へ変換します。
      # 戻り値の文字列エンコードは UTF-8 です。ptr へ与えたポインター先のメモリーは開放しません。
      # ptr へ NULL ポインターを与えても安全です。その場合は空文字を戻します。
      # 戻り値の文字列は Ruby 側へコピーされたものです。これを変更しても SDL のメモリー領域に影響を与えません。
      def ptr_to_str(ptr)
        if ptr.null?
          ""
        else
          ptr.read_string.force_encoding(Encoding::UTF_8)
        end
      end

      # 厳密な定義のためエンコーディングは ASCII-8BIT とする。
      NUL = "\x00".encode!(Encoding::ASCII_8BIT).freeze

      # Ruby String を SDL で取り扱う String へ変換します。
      # 戻り値は UTF-8 エンコードされた変更不可能な文字列です。
      # 内部では s へ与えた文字列をコピーし UTF-8 エンコードへ変換します。（元の文字列への影響はありません）
      # 文字列に NUL 文字が含まれる場合は ArgumentError が発生します。
      def str_to_sdl(s)
        # dup -> UTF-8 -> ASCII-8BIT
        # ASCII-8BIT にするのは size メソッドで正確なバイト数を得るため。（bytesize は忘れることがある）
        # frozen にして SDL 用文字列を変更（例えばエンコーディング）させない。
        sdl = String.new(s).encode!(Encoding::UTF_8).force_encoding(Encoding::ASCII_8BIT).freeze
        # NUL 文字の混入チェック
        raise ArgumentError if sdl.include?(NUL)
        sdl
      end
    end
  end
end
