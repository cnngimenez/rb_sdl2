# frozen_string_literal: true
module RbSDL2
  class Event
    module EventType
      COMMON_EVENT_TYPES = ::SDL::FIRSTEVENT.succ...::SDL::USEREVENT
      USER_EVENT_TYPES = ::SDL::USEREVENT...::SDL::LASTEVENT

      event_type_map = [
        [::SDL::QUIT, :quit, ::SDL::QuitEvent],
        [::SDL::APP_TERMINATING, :app_terminating, ::SDL::CommonEvent],
        [::SDL::APP_LOWMEMORY, :app_low_memory, ::SDL::CommonEvent],
        [::SDL::APP_WILLENTERBACKGROUND, :app_will_enter_background, ::SDL::CommonEvent],
        [::SDL::APP_DIDENTERBACKGROUND, :app_did_enter_background, ::SDL::CommonEvent],
        [::SDL::APP_WILLENTERFOREGROUND, :app_will_enter_foreground, ::SDL::CommonEvent],
        [::SDL::APP_DIDENTERFOREGROUND, :app_did_enter_foreground, ::SDL::CommonEvent],
        [::SDL::LOCALECHANGED, :locale_changed, ::SDL::CommonEvent],
        [::SDL::DISPLAYEVENT, :display_event, ::SDL::DisplayEvent],
        [::SDL::WINDOWEVENT, :window_event, ::SDL::WindowEvent],
        [::SDL::SYSWMEVENT, :sys_em_event, ::SDL::SysWMEvent],
        [::SDL::KEYDOWN, :key_down, ::SDL::KeyboardEvent],
        [::SDL::KEYUP, :key_up, ::SDL::KeyboardEvent],
        [::SDL::TEXTEDITING, :text_editing, ::SDL::TextEditingEvent],
        [::SDL::TEXTINPUT, :text_input, ::SDL::TextInputEvent],
        [::SDL::KEYMAPCHANGED, :keymap_changed, ::SDL::CommonEvent],
        [::SDL::MOUSEMOTION, :mouse_motion, ::SDL::MouseMotionEvent],
        [::SDL::MOUSEBUTTONDOWN, :mouse_button_down, ::SDL::MouseButtonEvent],
        [::SDL::MOUSEBUTTONUP, :mouse_button_up, ::SDL::MouseButtonEvent],
        [::SDL::MOUSEWHEEL, :mouse_wheel, ::SDL::MouseWheelEvent],
        [::SDL::JOYAXISMOTION, :joy_axis_motion, ::SDL::JoyAxisEvent],
        [::SDL::JOYBALLMOTION, :joy_ball_motion, ::SDL::JoyBallEvent],
        [::SDL::JOYHATMOTION, :joy_hat_motion, ::SDL::JoyHatEvent],
        [::SDL::JOYBUTTONDOWN, :joy_button_down, ::SDL::JoyButtonEvent],
        [::SDL::JOYBUTTONUP, :joy_button_up, ::SDL::JoyButtonEvent],
        [::SDL::JOYDEVICEADDED, :joy_device_added, ::SDL::JoyDeviceEvent],
        [::SDL::JOYDEVICEREMOVED, :joy_device_removed, ::SDL::JoyDeviceEvent],
        [::SDL::CONTROLLERAXISMOTION, :controller_axis_motion, ::SDL::ControllerAxisEvent],
        [::SDL::CONTROLLERBUTTONDOWN, :controller_button_down, ::SDL::ControllerButtonEvent],
        [::SDL::CONTROLLERBUTTONUP, :controller_button_up, ::SDL::ControllerButtonEvent],
        [::SDL::CONTROLLERDEVICEADDED, :controller_device_added, ::SDL::ControllerDeviceEvent],
        [::SDL::CONTROLLERDEVICEREMOVED, :controller_device_removed, ::SDL::ControllerDeviceEvent],
        [::SDL::CONTROLLERDEVICEREMAPPED, :controller_device_remapped, ::SDL::ControllerDeviceEvent],
        [::SDL::CONTROLLERTOUCHPADDOWN, :controller_touchpad_down, ::SDL::ControllerTouchpadEvent],
        [::SDL::CONTROLLERTOUCHPADMOTION, :controller_touchpad_motion, ::SDL::ControllerTouchpadEvent],
        [::SDL::CONTROLLERTOUCHPADUP, :controller_touchpad_up, ::SDL::ControllerTouchpadEvent],
        [::SDL::CONTROLLERSENSORUPDATE, :controller_sensor_update, ::SDL::ControllerSensorEvent],
        [::SDL::FINGERDOWN, :finger_down, ::SDL::TouchFingerEvent],
        [::SDL::FINGERUP, :finger_up, ::SDL::TouchFingerEvent],
        [::SDL::FINGERMOTION, :finger_motion, ::SDL::TouchFingerEvent],
        [::SDL::DOLLARGESTURE, :dollar_gesture, ::SDL::DollarGestureEvent],
        [::SDL::DOLLARRECORD, :dollar_record, ::SDL::DollarGestureEvent],
        [::SDL::MULTIGESTURE, :multi_gesture, ::SDL::MultiGestureEvent],
        [::SDL::CLIPBOARDUPDATE, :clipboard_update, ::SDL::CommonEvent],
        [::SDL::DROPFILE, :drop_file, ::SDL::DropEvent],
        [::SDL::DROPTEXT, :drop_text, ::SDL::DropEvent],
        [::SDL::DROPBEGIN, :drop_begin, ::SDL::DropEvent],
        [::SDL::DROPCOMPLETE, :drop_complete, ::SDL::DropEvent],
        [::SDL::AUDIODEVICEADDED, :audio_device_added, ::SDL::AudioDeviceEvent],
        [::SDL::AUDIODEVICEREMOVED, :audio_device_removed, ::SDL::AudioDeviceEvent],
        [::SDL::SENSORUPDATE, :sensor_update, ::SDL::SensorEvent],
        [::SDL::RENDER_TARGETS_RESET, :render_targets_reset, ::SDL::CommonEvent],
        [::SDL::RENDER_DEVICE_RESET, :render_device_reset, ::SDL::CommonEvent],
        [::SDL::POLLSENTINEL, :poll_sentinel, ::SDL::CommonEvent],
      ]

      default_klass = -> (_, key) do
        USER_EVENT_TYPES === key ? ::SDL::UserEvent : ::SDL::CommonEvent
      end

      ENTITY_MAP = Hash.new(&default_klass).
        merge!(event_type_map.map { |type, _, klass| [type, klass] }.to_h).freeze

      @type_to_name_map = event_type_map.map { |type, name, _| [type, name] }.to_h

      @name_to_type_map = event_type_map.map { |type, name, _| [name, type] }.to_h

      class << self
        def disable(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL.EventState(num, ::SDL::DISABLE) == ::SDL::ENABLE
        end

        def enable(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL.EventState(num, ::SDL::ENABLE) == ::SDL::DISABLE
        end

        def ignore?(type)
          num = Symbol === type ? to_num(type) : type
          ::SDL.EventState(num, ::SDL::QUERY) == ::SDL::IGNORE
        end

        def register_events(num)
          if ::SDL::RegisterEvents(num) == 0xFFFFFFFF
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
end
