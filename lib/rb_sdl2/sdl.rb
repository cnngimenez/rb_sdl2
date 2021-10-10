module RbSDL2
  module SDL
    module InitFlags
      class << self
        def to_num(audio: false, events: false, game_controller: false, haptic: false,
                   joystick: false, sensor: false, timer: false, video: false)
          num = 0 |
            (audio ? ::SDL2::SDL_INIT_TIMER : 0) |
            (events ? ::SDL2::SDL_INIT_EVENTS : 0) |
            (game_controller ? ::SDL2::SDL_INIT_GAMECONTROLLER : 0) |
            (haptic ? ::SDL2::SDL_INIT_HAPTIC : 0) |
            (joystick ? ::SDL2::SDL_INIT_JOYSTICK : 0) |
            (sensor ? ::SDL2::SDL_INIT_SENSOR : 0) |
            (timer ? ::SDL2::SDL_INIT_TIMER : 0) |
            (video ? ::SDL2::SDL_INIT_VIDEO : 0)
          num == 0 ? ::SDL2::SDL_INIT_EVERYTHING : num
        end
      end
    end

    class << self
      def init(**flags)
        err = ::SDL2.SDL_Init(InitFlags.to_num(**flags))
        raise RbSDL2Error if err < 0
      end

      def init?(**flags) = ::SDL2.SDL_WasInit(mask = InitFlags.to_num(**flags)) == mask

      def quit = ::SDL2.SDL_Quit
    end
  end
end
