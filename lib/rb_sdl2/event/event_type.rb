# frozen_string_literal: true
module RbSDL2
  class Event
    module EventType
      COMMON_EVENT_TYPES = ::SDL2::SDL_FIRSTEVENT.succ...::SDL2::SDL_USEREVENT
      USER_EVENT_TYPES = ::SDL2::SDL_USEREVENT...::SDL2::SDL_LASTEVENT

      event_type_map = [
        [::SDL2::SDL_QUIT, :quit, ::SDL2::SDL_QuitEvent],
        [::SDL2::SDL_APP_TERMINATING, :app_terminating, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_APP_LOWMEMORY, :app_low_memory, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_APP_WILLENTERBACKGROUND, :app_will_enter_background, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_APP_DIDENTERBACKGROUND, :app_did_enter_background, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_APP_WILLENTERFOREGROUND, :app_will_enter_foreground, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_APP_DIDENTERFOREGROUND, :app_did_enter_foreground, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_LOCALECHANGED, :locale_changed, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_DISPLAYEVENT, :display_event, ::SDL2::SDL_DisplayEvent],
        [::SDL2::SDL_WINDOWEVENT, :window_event, ::SDL2::SDL_WindowEvent],
        [::SDL2::SDL_SYSWMEVENT, :sys_em_event, ::SDL2::SDL_SysWMEvent],
        [::SDL2::SDL_KEYDOWN, :key_down, ::SDL2::SDL_KeyboardEvent],
        [::SDL2::SDL_KEYUP, :key_up, ::SDL2::SDL_KeyboardEvent],
        [::SDL2::SDL_TEXTEDITING, :text_editing, ::SDL2::SDL_TextEditingEvent],
        [::SDL2::SDL_TEXTINPUT, :text_input, ::SDL2::SDL_TextInputEvent],
        [::SDL2::SDL_KEYMAPCHANGED, :keymap_changed, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_MOUSEMOTION, :mouse_motion, ::SDL2::SDL_MouseMotionEvent],
        [::SDL2::SDL_MOUSEBUTTONDOWN, :mouse_button_down, ::SDL2::SDL_MouseButtonEvent],
        [::SDL2::SDL_MOUSEBUTTONUP, :mouse_button_up, ::SDL2::SDL_MouseButtonEvent],
        [::SDL2::SDL_MOUSEWHEEL, :mouse_wheel, ::SDL2::SDL_MouseWheelEvent],
        [::SDL2::SDL_JOYAXISMOTION, :joy_axis_motion, ::SDL2::SDL_JoyAxisEvent],
        [::SDL2::SDL_JOYBALLMOTION, :joy_ball_motion, ::SDL2::SDL_JoyBallEvent],
        [::SDL2::SDL_JOYHATMOTION, :joy_hat_motion, ::SDL2::SDL_JoyHatEvent],
        [::SDL2::SDL_JOYBUTTONDOWN, :joy_button_down, ::SDL2::SDL_JoyButtonEvent],
        [::SDL2::SDL_JOYBUTTONUP, :joy_button_up, ::SDL2::SDL_JoyButtonEvent],
        [::SDL2::SDL_JOYDEVICEADDED, :joy_device_added, ::SDL2::SDL_JoyDeviceEvent],
        [::SDL2::SDL_JOYDEVICEREMOVED, :joy_device_removed, ::SDL2::SDL_JoyDeviceEvent],
        [::SDL2::SDL_CONTROLLERAXISMOTION, :controller_axis_motion, ::SDL2::SDL_ControllerAxisEvent],
        [::SDL2::SDL_CONTROLLERBUTTONDOWN, :controller_button_down, ::SDL2::SDL_ControllerButtonEvent],
        [::SDL2::SDL_CONTROLLERBUTTONUP, :controller_button_up, ::SDL2::SDL_ControllerButtonEvent],
        [::SDL2::SDL_CONTROLLERDEVICEADDED, :controller_device_added, ::SDL2::SDL_ControllerDeviceEvent],
        [::SDL2::SDL_CONTROLLERDEVICEREMOVED, :controller_device_removed, ::SDL2::SDL_ControllerDeviceEvent],
        [::SDL2::SDL_CONTROLLERDEVICEREMAPPED, :controller_device_remapped, ::SDL2::SDL_ControllerDeviceEvent],
        [::SDL2::SDL_CONTROLLERTOUCHPADDOWN, :controller_touchpad_down, ::SDL2::SDL_ControllerTouchpadEvent],
        [::SDL2::SDL_CONTROLLERTOUCHPADMOTION, :controller_touchpad_motion, ::SDL2::SDL_ControllerTouchpadEvent],
        [::SDL2::SDL_CONTROLLERTOUCHPADUP, :controller_touchpad_up, ::SDL2::SDL_ControllerTouchpadEvent],
        [::SDL2::SDL_CONTROLLERSENSORUPDATE, :controller_sensor_update, ::SDL2::SDL_ControllerSensorEvent],
        [::SDL2::SDL_FINGERDOWN, :finger_down, ::SDL2::SDL_TouchFingerEvent],
        [::SDL2::SDL_FINGERUP, :finger_up, ::SDL2::SDL_TouchFingerEvent],
        [::SDL2::SDL_FINGERMOTION, :finger_motion, ::SDL2::SDL_TouchFingerEvent],
        [::SDL2::SDL_DOLLARGESTURE, :dollar_gesture, ::SDL2::SDL_DollarGestureEvent],
        [::SDL2::SDL_DOLLARRECORD, :dollar_record, ::SDL2::SDL_DollarGestureEvent],
        [::SDL2::SDL_MULTIGESTURE, :multi_gesture, ::SDL2::SDL_MultiGestureEvent],
        [::SDL2::SDL_CLIPBOARDUPDATE, :clipboard_update, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_DROPFILE, :drop_file, ::SDL2::SDL_DropEvent],
        [::SDL2::SDL_DROPTEXT, :drop_text, ::SDL2::SDL_DropEvent],
        [::SDL2::SDL_DROPBEGIN, :drop_begin, ::SDL2::SDL_DropEvent],
        [::SDL2::SDL_DROPCOMPLETE, :drop_complete, ::SDL2::SDL_DropEvent],
        [::SDL2::SDL_AUDIODEVICEADDED, :audio_device_added, ::SDL2::SDL_AudioDeviceEvent],
        [::SDL2::SDL_AUDIODEVICEREMOVED, :audio_device_removed, ::SDL2::SDL_AudioDeviceEvent],
        [::SDL2::SDL_SENSORUPDATE, :sensor_update, ::SDL2::SDL_SensorEvent],
        [::SDL2::SDL_RENDER_TARGETS_RESET, :render_targets_reset, ::SDL2::SDL_CommonEvent],
        [::SDL2::SDL_RENDER_DEVICE_RESET, :render_device_reset, ::SDL2::SDL_CommonEvent],
      ]

      default_klass = -> (_, key) do
        USER_EVENT_TYPES === key ? ::SDL2::SDL_UserEvent : ::SDL2::SDL_CommonEvent
      end

      ENTITY_MAP = Hash.new(&default_klass).
        merge!(event_type_map.map { |type, _, klass| [type, klass] }.to_h).freeze

      @type_to_name_map = event_type_map.map { |type, name, _| [type, name] }.to_h

      @name_to_type_map = event_type_map.map { |type, name, _| [name, type] }.to_h

      class << self
        def disable(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL2.SDL_EventState(num, ::SDL2::SDL_DISABLE) == ::SDL2::SDL_ENABLE
        end

        def enable(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL2.SDL_EventState(num, ::SDL2::SDL_ENABLE) == ::SDL2::SDL_DISABLE
        end

        def ignore?(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL2.SDL_EventState(num, ::SDL2::SDL_QUERY) == ::SDL2::SDL_IGNORE
        end

        def register_events(num)
          if ::SDL2::SDL_RegisterEvents(num) == 0xFFFFFFFF
            raise RbSDL2Error, "unable to register user events because too many requests"
          end
        end

        def to_name(num)
          case num
          when COMMON_EVENT_TYPES
            (name = @type_to_name_map[num]) ? name : :common_event
          when USER_EVENT_TYPES
            :user_event
          else
            ""
          end.to_s
        end

        def to_num(obj)
          num = @name_to_type_map[obj]
          raise ArgumentError unless num
          num
        end
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

      def finger_motion? = ::SDL2::SDL_FINGERMOTION == type

      def finger_up? = ::SDL2::SDL_FINGERUP == type

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
