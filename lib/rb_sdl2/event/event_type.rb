# frozen_string_literal: true
module RbSDL2
  class Event
    module EventType
      RANGE = ::SDL2::SDL_FIRSTEVENT..::SDL2::SDL_LASTEVENT
      EVENT_TYPES = RANGE.first.succ...::SDL2::SDL_LASTEVENT
      COMMON_EVENT_TYPES = EVENT_TYPES.first...::SDL2::SDL_USEREVENT
      USER_EVENT_TYPES = ::SDL2::SDL_USEREVENT...EVENT_TYPES.last

      default_type = -> (_, key) do
        case key
        when 0 then :common
        when COMMON_EVENT_TYPES then :common
        when USER_EVENT_TYPES then :user
        else raise KeyError, "(#{key})"
        end
      end

      MEMBER_MAP = Hash.new(&default_type).merge!(
        ::SDL2::SDL_AUDIODEVICEADDED => :adevice,
        ::SDL2::SDL_AUDIODEVICEREMOVED => :adevice,
        ::SDL2::SDL_DISPLAYEVENT => :display,
        ::SDL2::SDL_KEYDOWN => :key,
        ::SDL2::SDL_KEYUP => :key,
        ::SDL2::SDL_CONTROLLERAXISMOTION => :caxis,
        ::SDL2::SDL_CONTROLLERBUTTONDOWN => :cbutton,
        ::SDL2::SDL_CONTROLLERBUTTONUP => :cbutton,
        ::SDL2::SDL_CONTROLLERDEVICEADDED => :cdevice,
        ::SDL2::SDL_CONTROLLERDEVICEREMAPPED => :cdevice,
        ::SDL2::SDL_CONTROLLERDEVICEREMOVED => :cdevice,
        ::SDL2::SDL_CONTROLLERSENSORUPDATE => :csensor,
        ::SDL2::SDL_CONTROLLERTOUCHPADDOWN => :ctouchpad,
        ::SDL2::SDL_CONTROLLERTOUCHPADMOTION => :ctouchpad,
        ::SDL2::SDL_CONTROLLERTOUCHPADUP => :ctouchpad,
        ::SDL2::SDL_DOLLARGESTURE => :dgesture,
        ::SDL2::SDL_DOLLARRECORD => :dgesture,
        ::SDL2::SDL_DROPBEGIN => :drop,
        ::SDL2::SDL_DROPCOMPLETE => :drop,
        ::SDL2::SDL_DROPFILE => :drop,
        ::SDL2::SDL_DROPTEXT => :drop,
        ::SDL2::SDL_FINGERDOWN => :tfinger,
        ::SDL2::SDL_FINGERMOTION => :tfinger,
        ::SDL2::SDL_FINGERUP => :tfinger,
        ::SDL2::SDL_JOYAXISMOTION => :jaxis,
        ::SDL2::SDL_JOYBALLMOTION => :jball,
        ::SDL2::SDL_JOYBUTTONDOWN => :jbutton,
        ::SDL2::SDL_JOYBUTTONUP => :jbutton,
        ::SDL2::SDL_JOYDEVICEADDED => :jdevice,
        ::SDL2::SDL_JOYDEVICEREMOVED => :jdevice,
        ::SDL2::SDL_JOYHATMOTION => :jhat,
        ::SDL2::SDL_MOUSEBUTTONDOWN => :button,
        ::SDL2::SDL_MOUSEBUTTONUP => :button,
        ::SDL2::SDL_MOUSEMOTION => :motion,
        ::SDL2::SDL_MOUSEWHEEL => :wheel,
        ::SDL2::SDL_MULTIGESTURE => :mgesture,
        ::SDL2::SDL_QUIT => :quit,
        ::SDL2::SDL_SENSORUPDATE => :sensor,
        ::SDL2::SDL_SYSWMEVENT => :syswm,
        ::SDL2::SDL_TEXTEDITING => :edit,
        ::SDL2::SDL_TEXTINPUT => :text,
        ::SDL2::SDL_WINDOWEVENT => :window,
      ).freeze

      default_name = -> (_, key) do
        case key
        when 0 then ""
        when COMMON_EVENT_TYPES then "common_event"
        when USER_EVENT_TYPES then "user_event"
        else raise KeyError, "(#{key})"
        end
      end

      @name_map = Hash.new(&default_name).merge!(
        ::SDL2::SDL_APP_DIDENTERBACKGROUND => "app_did_enter_background",
        ::SDL2::SDL_APP_DIDENTERFOREGROUND => "app_did_enter_foreground",
        ::SDL2::SDL_APP_LOWMEMORY => "app_low_memory",
        ::SDL2::SDL_APP_TERMINATING => "app_terminating",
        ::SDL2::SDL_APP_WILLENTERBACKGROUND => "app_will_enter_background",
        ::SDL2::SDL_APP_WILLENTERFOREGROUND => "app_will_enter_foreground",
        ::SDL2::SDL_AUDIODEVICEADDED => "audio_device_added",
        ::SDL2::SDL_AUDIODEVICEREMOVED => "audio_device_removed",
        ::SDL2::SDL_CLIPBOARDUPDATE => "clipboard_update",
        ::SDL2::SDL_CONTROLLERAXISMOTION => "controller_axis_motion",
        ::SDL2::SDL_CONTROLLERBUTTONDOWN => "controller_button_down",
        ::SDL2::SDL_CONTROLLERBUTTONUP => "controller_button_up",
        ::SDL2::SDL_CONTROLLERDEVICEADDED => "controller_device_added",
        ::SDL2::SDL_CONTROLLERDEVICEREMAPPED => "controller_device_remapped",
        ::SDL2::SDL_CONTROLLERDEVICEREMOVED => "controller_device_removed",
        ::SDL2::SDL_CONTROLLERSENSORUPDATE => "controller_sensor_update",
        ::SDL2::SDL_CONTROLLERTOUCHPADDOWN => "controller_touchpad_down",
        ::SDL2::SDL_CONTROLLERTOUCHPADMOTION => "controller_touchpad_motion",
        ::SDL2::SDL_CONTROLLERTOUCHPADUP => "controller_touchpad_up",
        ::SDL2::SDL_DISPLAYEVENT => "display_event",
        ::SDL2::SDL_DOLLARGESTURE => "dollar_gesture",
        ::SDL2::SDL_DOLLARRECORD => "dollar_record",
        ::SDL2::SDL_DROPBEGIN => "drop_begin",
        ::SDL2::SDL_DROPCOMPLETE => "drop_complete",
        ::SDL2::SDL_DROPFILE => "drop_file",
        ::SDL2::SDL_DROPTEXT => "drop_text",
        ::SDL2::SDL_FINGERDOWN => "finger_down",
        ::SDL2::SDL_FINGERUP => "finger_up",
        ::SDL2::SDL_FINGERMOTION => "finger_motion",
        ::SDL2::SDL_JOYAXISMOTION => "joy_axis_motion",
        ::SDL2::SDL_JOYBALLMOTION => "joy_ball_motion",
        ::SDL2::SDL_JOYBUTTONDOWN => "joy_button_down",
        ::SDL2::SDL_JOYBUTTONUP => "joy_button_up",
        ::SDL2::SDL_JOYDEVICEADDED => "joy_device_added",
        ::SDL2::SDL_JOYDEVICEREMOVED => "joy_device_removed",
        ::SDL2::SDL_JOYHATMOTION => "joy_hat_motion",
        ::SDL2::SDL_KEYDOWN => "key_down",
        ::SDL2::SDL_KEYUP => "key_up",
        ::SDL2::SDL_KEYMAPCHANGED => "keymap_changed",
        ::SDL2::SDL_LOCALECHANGED => "locale_changed",
        ::SDL2::SDL_MULTIGESTURE => "multi_gesture",
        ::SDL2::SDL_MOUSEBUTTONDOWN => "mouse_button_down",
        ::SDL2::SDL_MOUSEBUTTONUP => "mouse_button_up",
        ::SDL2::SDL_MOUSEMOTION => "mouse_motion",
        ::SDL2::SDL_MOUSEWHEEL =>  "mouse_wheel",
        ::SDL2::SDL_QUIT => "quit",
        ::SDL2::SDL_RENDER_DEVICE_RESET => "render_device_reset",
        ::SDL2::SDL_RENDER_TARGETS_RESET => "render_targets_reset",
        ::SDL2::SDL_SENSORUPDATE => "sensor_update",
        ::SDL2::SDL_SYSWMEVENT => "sys_wm_event",
        ::SDL2::SDL_TEXTEDITING => "text_editing",
        ::SDL2::SDL_TEXTINPUT => "text_input",
        ::SDL2::SDL_WINDOWEVENT => "window_event",
      )

      @mutex = Mutex.new

      class << self
        def define_user_event(name = "user_event")
          @mutex.synchronize do
            num = ::SDL2::SDL_RegisterEvents(1)
            if num == 0xFFFFFFFF
              raise RbSDL2Error, "unable to register user events because too many requests"
            end
            @name_map[num] = name
            num
          end
        end

        def disable(type) = ::SDL2.SDL_EventState(type, ::SDL2::SDL_DISABLE) == ::SDL2::SDL_ENABLE

        def enable(type) = ::SDL2.SDL_EventState(type, ::SDL2::SDL_ENABLE) == ::SDL2::SDL_DISABLE

        def ignore?(type) = ::SDL2.SDL_EventState(type, ::SDL2::SDL_QUERY) == ::SDL2::SDL_IGNORE

        def minmax = RANGE.minmax

        def to_name(num) = @name_map[num]

        def to_num(obj)
          num =  @name_map.key(obj.to_s)
          raise ArgumentError unless num
          num
        end

        def to_type(num) = MEMBER_MAP[num]
      end

      def app_did_enter_background? = ::SDL2::SDL_APP_DIDENTERBACKGROUND == type

      def app_did_enter_foreground? = ::SDL2::SDL_APP_DIDENTERFOREGROUND == type

      def app_low_memory? = ::SDL2::SDL_APP_LOWMEMORY == type

      def app_terminating? = ::SDL2::SDL_APP_TERMINATING == type

      def app_will_enter_background? = ::SDL2::SDL_APP_WILLENTERBACKGROUND == type

      def app_will_enter_foreground? = ::SDL2::SDL_APP_WILLENTERFOREGROUND == type

      def audio_device_added? = ::SDL2::SDL_AUDIODEVICEADDED == type

      def audio_device_removed? = ::SDL2::SDL_AUDIODEVICEREMOVED == type

      def clipboard_update? = ::SDL2::SDL_CLIPBOARDUPDATE == type

      def controller_axis_motion? = ::SDL2::SDL_CONTROLLERAXISMOTION == type

      def controller_button_down? = ::SDL2::SDL_CONTROLLERBUTTONDOWN == type

      def controller_button_up? = ::SDL2::SDL_CONTROLLERBUTTONUP == type

      def controller_device_added? = ::SDL2::SDL_CONTROLLERDEVICEADDED == type

      def controller_device_remapped? = ::SDL2::SDL_CONTROLLERDEVICEREMAPPED == type

      def controller_device_removed? = ::SDL2::SDL_CONTROLLERDEVICEREMOVED == type

      def controller_sensor_update? = ::SDL2::SDL_CONTROLLERSENSORUPDATE == type

      def controller_touchpad_down? = ::SDL2::SDL_CONTROLLERTOUCHPADDOWN == type

      def controller_touchpad_motion? = ::SDL2::SDL_CONTROLLERTOUCHPADMOTION == type

      def controller_touchpad_up? = ::SDL2::SDL_CONTROLLERTOUCHPADUP == type

      def display_event? = ::SDL2::SDL_DISPLAYEVENT == type

      def dollar_gesture? = ::SDL2::SDL_DOLLARGESTURE == type

      def dollar_record? = ::SDL2::SDL_DOLLARRECORD == type

      def drop_begin? = ::SDL2::SDL_DROPBEGIN == type

      def drop_complete? = ::SDL2::SDL_DROPCOMPLETE == type

      def drop_file? = ::SDL2::SDL_DROPFILE == type

      def drop_text? = ::SDL2::SDL_DROPTEXT == type

      def finger_down? = ::SDL2::SDL_FINGERDOWN == type

      def finger_up? = ::SDL2::SDL_FINGERUP == type

      def finger_motion? = ::SDL2::SDL_FINGERMOTION == type

      def joy_axis_motion? = ::SDL2::SDL_JOYAXISMOTION == type

      def joy_ball_motion? = ::SDL2::SDL_JOYBALLMOTION == type

      def joy_button_down? = ::SDL2::SDL_JOYBUTTONDOWN == type

      def joy_button_up? = ::SDL2::SDL_JOYBUTTONUP == type

      def joy_device_added? = ::SDL2::SDL_JOYDEVICEADDED == type

      def joy_device_removed? = ::SDL2::SDL_JOYDEVICEREMOVED == type

      def joy_hat_motion? = ::SDL2::SDL_JOYHATMOTION == type

      def key_down? = ::SDL2::SDL_KEYDOWN == type

      def key_up? = ::SDL2::SDL_KEYUP == type

      def keymap_changed? = ::SDL2::SDL_KEYMAPCHANGED == type

      def locale_changed? = ::SDL2::SDL_LOCALECHANGED == type

      def multi_gesture? = ::SDL2::SDL_MULTIGESTURE == type

      def mouse_button_down? = ::SDL2::SDL_MOUSEBUTTONDOWN == type

      def mouse_button_up? = ::SDL2::SDL_MOUSEBUTTONUP == type

      def mouse_motion? = ::SDL2::SDL_MOUSEMOTION == type

      def mouse_wheel? = ::SDL2::SDL_MOUSEWHEEL == type

      def quit? = ::SDL2::SDL_QUIT == type

      def render_device_reset? = ::SDL2::SDL_RENDER_DEVICE_RESET == type

      def render_targets_reset? = ::SDL2::SDL_RENDER_TARGETS_RESET == type

      def sensor_update? = ::SDL2::SDL_SENSORUPDATE == type

      def sys_wm_event? = ::SDL2::SDL_SYSWMEVENT == type

      def text_editing? = ::SDL2::SDL_TEXTEDITING == type

      def text_input? = ::SDL2::SDL_TEXTINPUT == type

      def user_event? = USER_EVENT_TYPES === type

      def window_event? = ::SDL2::SDL_WINDOWEVENT == type
    end
  end
end
