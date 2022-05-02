module RbSDL2
  module EventType
    COMMON_EVENT_TYPES = ::SDL::FIRSTEVENT.succ...::SDL::USEREVENT
    USER_EVENT_TYPES = ::SDL::USEREVENT...::SDL::LASTEVENT

    table = [
      [::SDL::QUIT, ::SDL::QuitEvent, "SDL_QUIT"],
      [::SDL::APP_TERMINATING, ::SDL::CommonEvent, "SDL_APP_TERMINATING"],
      [::SDL::APP_LOWMEMORY, ::SDL::CommonEvent, "SDL_APP_LOWMEMORY"],
      [::SDL::APP_WILLENTERBACKGROUND, ::SDL::CommonEvent, "SDL_APP_WILLENTERBACKGROUND"],
      [::SDL::APP_DIDENTERBACKGROUND, ::SDL::CommonEvent, "SDL_APP_DIDENTERBACKGROUND"],
      [::SDL::APP_WILLENTERFOREGROUND, ::SDL::CommonEvent, "SDL_APP_WILLENTERFOREGROUND"],
      [::SDL::APP_DIDENTERFOREGROUND, ::SDL::CommonEvent, "SDL_APP_DIDENTERFOREGROUND"],
      [::SDL::LOCALECHANGED, ::SDL::CommonEvent, "SDL_LOCALECHANGED"],
      [::SDL::DISPLAYEVENT, ::SDL::DisplayEvent, "SDL_DISPLAYEVENT"],
      [::SDL::WINDOWEVENT, ::SDL::WindowEvent, "SDL_WINDOWEVENT"],
      [::SDL::SYSWMEVENT, ::SDL::SysWMEvent, "SDL_SYSWMEVENT"],
      [::SDL::KEYDOWN, ::SDL::KeyboardEvent, "SDL_KEYDOWN"],
      [::SDL::KEYUP, ::SDL::KeyboardEvent, "SDL_KEYUP"],
      [::SDL::TEXTEDITING, ::SDL::TextEditingEvent, "SDL_TEXTEDITING"],
      [::SDL::TEXTINPUT, ::SDL::TextInputEvent, "SDL_TEXTINPUT"],
      [::SDL::KEYMAPCHANGED, ::SDL::CommonEvent, "SDL_KEYMAPCHANGED"],
      [::SDL::MOUSEMOTION, ::SDL::MouseMotionEvent, "SDL_MOUSEMOTION"],
      [::SDL::MOUSEBUTTONDOWN, ::SDL::MouseButtonEvent, "SDL_MOUSEBUTTONDOWN"],
      [::SDL::MOUSEBUTTONUP, ::SDL::MouseButtonEvent, "SDL_MOUSEBUTTONUP"],
      [::SDL::MOUSEWHEEL, ::SDL::MouseWheelEvent, "SDL_MOUSEWHEEL"],
      [::SDL::JOYAXISMOTION, ::SDL::JoyAxisEvent, "SDL_JOYAXISMOTION"],
      [::SDL::JOYBALLMOTION, ::SDL::JoyBallEvent, "SDL_JOYBALLMOTION"],
      [::SDL::JOYHATMOTION, ::SDL::JoyHatEvent, "SDL_JOYHATMOTION"],
      [::SDL::JOYBUTTONDOWN, ::SDL::JoyButtonEvent, "SDL_JOYBUTTONDOWN"],
      [::SDL::JOYBUTTONUP, ::SDL::JoyButtonEvent, "SDL_JOYBUTTONUP"],
      [::SDL::JOYDEVICEADDED, ::SDL::JoyDeviceEvent, "SDL_JOYDEVICEADDED"],
      [::SDL::JOYDEVICEREMOVED, ::SDL::JoyDeviceEvent, "SDL_JOYDEVICEREMOVED"],
      [::SDL::CONTROLLERAXISMOTION, ::SDL::ControllerAxisEvent, "SDL_CONTROLLERAXISMOTION"],
      [::SDL::CONTROLLERBUTTONDOWN, ::SDL::ControllerButtonEvent, "SDL_CONTROLLERBUTTONDOWN"],
      [::SDL::CONTROLLERBUTTONUP, ::SDL::ControllerButtonEvent, "SDL_CONTROLLERBUTTONUP"],
      [::SDL::CONTROLLERDEVICEADDED, ::SDL::ControllerDeviceEvent, "SDL_CONTROLLERDEVICEADDED"],
      [::SDL::CONTROLLERDEVICEREMOVED, ::SDL::ControllerDeviceEvent, "SDL_CONTROLLERDEVICEREMOVED"],
      [::SDL::CONTROLLERDEVICEREMAPPED, ::SDL::ControllerDeviceEvent, "SDL_CONTROLLERDEVICEREMAPPED"],
      [::SDL::CONTROLLERTOUCHPADDOWN, ::SDL::ControllerTouchpadEvent, "SDL_CONTROLLERTOUCHPADDOWN"],
      [::SDL::CONTROLLERTOUCHPADMOTION, ::SDL::ControllerTouchpadEvent, "SDL_CONTROLLERTOUCHPADMOTION"],
      [::SDL::CONTROLLERTOUCHPADUP, ::SDL::ControllerTouchpadEvent, "SDL_CONTROLLERTOUCHPADUP"],
      [::SDL::CONTROLLERSENSORUPDATE, ::SDL::ControllerSensorEvent, "SDL_CONTROLLERSENSORUPDATE"],
      [::SDL::FINGERDOWN, ::SDL::TouchFingerEvent, "SDL_FINGERDOWN"],
      [::SDL::FINGERUP, ::SDL::TouchFingerEvent, "SDL_FINGERUP"],
      [::SDL::FINGERMOTION, ::SDL::TouchFingerEvent, "SDL_FINGERMOTION"],
      [::SDL::DOLLARGESTURE, ::SDL::DollarGestureEvent, "SDL_DOLLARGESTURE"],
      [::SDL::DOLLARRECORD, ::SDL::DollarGestureEvent, "SDL_DOLLARRECORD"],
      [::SDL::MULTIGESTURE, ::SDL::MultiGestureEvent, "SDL_MULTIGESTURE"],
      [::SDL::CLIPBOARDUPDATE, ::SDL::CommonEvent, "SDL_CLIPBOARDUPDATE"],
      [::SDL::DROPFILE, ::SDL::DropEvent, "SDL_DROPFILE"],
      [::SDL::DROPTEXT, ::SDL::DropEvent, "SDL_DROPTEXT"],
      [::SDL::DROPBEGIN, ::SDL::DropEvent, "SDL_DROPBEGIN"],
      [::SDL::DROPCOMPLETE, ::SDL::DropEvent, "SDL_DROPCOMPLETE"],
      [::SDL::AUDIODEVICEADDED, ::SDL::AudioDeviceEvent, "SDL_AUDIODEVICEADDED"],
      [::SDL::AUDIODEVICEREMOVED, ::SDL::AudioDeviceEvent, "SDL_AUDIODEVICEREMOVED"],
      [::SDL::SENSORUPDATE, ::SDL::SensorEvent, "SDL_SENSORUPDATE"],
      [::SDL::RENDER_TARGETS_RESET, ::SDL::CommonEvent, "SDL_RENDER_TARGETS_RESET"],
      [::SDL::RENDER_DEVICE_RESET, ::SDL::CommonEvent, "SDL_RENDER_DEVICE_RESET"],
      [::SDL::POLLSENTINEL, ::SDL::CommonEvent, "SDL_POLLSENTINEL"],
    ]

    default_klass = -> (_, key) { USER_EVENT_TYPES === key ? ::SDL::UserEvent : ::SDL::CommonEvent }

    ENTITY_MAP = Hash.new(&default_klass).merge!(table.map { |a| a.first(2) }.to_h).freeze

    NAME_MAP = Hash.new.merge!(table.map { |c, _, s| [c, s.freeze] }.to_h).freeze

    class << self
      def disable(num) = ::SDL.EventState(num, ::SDL::DISABLE) == ::SDL::ENABLE

      def enable(num) = ::SDL.EventState(num, ::SDL::ENABLE) == ::SDL::DISABLE

      def ignore?(num) = ::SDL.EventState(num, ::SDL::QUERY) == ::SDL::IGNORE

      def register_events(num)
        if ::SDL.RegisterEvents(num) == 0xFFFFFFFF
          raise RbSDL2Error, "unable to register user events because too many requests"
        end
      end

      def to_name(num)
        case num
        when COMMON_EVENT_TYPES then NAME_MAP[num]
        when USER_EVENT_TYPES then "SDL_USEREVENT".freeze
        else nil
        end
      end

      def to_types(obj)
        case obj
        when nil then [::SDL::FIRSTEVENT, ::SDL::LASTEVENT]
        when Integer then [obj, obj]
        when Range then obj.minmax
        else raise ArgumentError
        end
      end
    end

    def app_did_enter_background? = ::SDL::APP_DIDENTERBACKGROUND == type

    def app_did_enter_foreground? = ::SDL::APP_DIDENTERFOREGROUND == type

    def app_low_memory? = ::SDL::APP_LOWMEMORY == type

    def app_terminating? = ::SDL::APP_TERMINATING == type

    def app_will_enter_background? = ::SDL::APP_WILLENTERBACKGROUND == type

    def app_will_enter_foreground? = ::SDL::APP_WILLENTERFOREGROUND == type

    def audio_device_added? = ::SDL::AUDIODEVICEADDED == type

    def audio_device_removed? = ::SDL::AUDIODEVICEREMOVED == type

    def clipboard_update? = ::SDL::CLIPBOARDUPDATE == type

    def controller_axis_motion? = ::SDL::CONTROLLERAXISMOTION == type

    def controller_button_down? = ::SDL::CONTROLLERBUTTONDOWN == type

    def controller_button_up? = ::SDL::CONTROLLERBUTTONUP == type

    def controller_device_added? = ::SDL::CONTROLLERDEVICEADDED == type

    def controller_device_remapped? = ::SDL::CONTROLLERDEVICEREMAPPED == type

    def controller_device_removed? = ::SDL::CONTROLLERDEVICEREMOVED == type

    def controller_sensor_update? = ::SDL::CONTROLLERSENSORUPDATE == type

    def controller_touchpad_down? = ::SDL::CONTROLLERTOUCHPADDOWN == type

    def controller_touchpad_motion? = ::SDL::CONTROLLERTOUCHPADMOTION == type

    def controller_touchpad_up? = ::SDL::CONTROLLERTOUCHPADUP == type

    def display_event? = ::SDL::DISPLAYEVENT == type

    def dollar_gesture? = ::SDL::DOLLARGESTURE == type

    def dollar_record? = ::SDL::DOLLARRECORD == type

    def drop_begin? = ::SDL::DROPBEGIN == type

    def drop_complete? = ::SDL::DROPCOMPLETE == type

    def drop_file? = ::SDL::DROPFILE == type

    def drop_text? = ::SDL::DROPTEXT == type

    def finger_down? = ::SDL::FINGERDOWN == type

    def finger_motion? = ::SDL::FINGERMOTION == type

    def finger_up? = ::SDL::FINGERUP == type

    def joy_axis_motion? = ::SDL::JOYAXISMOTION == type

    def joy_ball_motion? = ::SDL::JOYBALLMOTION == type

    def joy_button_down? = ::SDL::JOYBUTTONDOWN == type

    def joy_button_up? = ::SDL::JOYBUTTONUP == type

    def joy_device_added? = ::SDL::JOYDEVICEADDED == type

    def joy_device_removed? = ::SDL::JOYDEVICEREMOVED == type

    def joy_hat_motion? = ::SDL::JOYHATMOTION == type

    def key_down? = ::SDL::KEYDOWN == type

    def key_up? = ::SDL::KEYUP == type

    def keymap_changed? = ::SDL::KEYMAPCHANGED == type

    def locale_changed? = ::SDL::LOCALECHANGED == type

    def multi_gesture? = ::SDL::MULTIGESTURE == type

    def mouse_button_down? = ::SDL::MOUSEBUTTONDOWN == type

    def mouse_button_up? = ::SDL::MOUSEBUTTONUP == type

    def mouse_motion? = ::SDL::MOUSEMOTION == type

    def mouse_wheel? = ::SDL::MOUSEWHEEL == type

    def poll_sentinel? = ::SDL::POLLSENTINEL == type

    def quit? = ::SDL::QUIT == type

    def render_device_reset? = ::SDL::RENDER_DEVICE_RESET == type

    def render_targets_reset? = ::SDL::RENDER_TARGETS_RESET == type

    def sensor_update? = ::SDL::SENSORUPDATE == type

    def sys_wm_event? = ::SDL::SYSWMEVENT == type

    def text_editing? = ::SDL::TEXTEDITING == type

    def text_input? = ::SDL::TEXTINPUT == type

    def user_event? = USER_EVENT_TYPES === type

    def window_event? = ::SDL::WINDOWEVENT == type
  end
end
