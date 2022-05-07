module RbSDL2
  module Keyboard
    module ModState
      class << self
        def state = ::SDL.GetModState

        def state?(num) = state & num != 0

        def state=(num)
          ::SDL::SetModState(num)
        end
      end

      KMOD_NONE   = 0x0000
      KMOD_LSHIFT = 0x0001
      KMOD_RSHIFT = 0x0002
      KMOD_LCTRL  = 0x0040
      KMOD_RCTRL  = 0x0080
      KMOD_LALT   = 0x0100
      KMOD_RALT   = 0x0200
      KMOD_LGUI   = 0x0400
      KMOD_RGUI   = 0x0800
      KMOD_NUM    = 0x1000
      KMOD_CAPS   = 0x2000
      KMOD_MODE   = 0x4000
      KMOD_SCROLL = 0x8000

      KMOD_CTRL  = KMOD_LCTRL | KMOD_RCTRL
      KMOD_SHIFT = KMOD_LSHIFT | KMOD_RSHIFT
      KMOD_ALT   = KMOD_LALT | KMOD_RALT
      KMOD_GUI   = KMOD_LGUI | KMOD_RGUI

      def alt_key? = ModState.state?(KMOD_ALT)

      def caps_key? = ModState.state?(KMOD_CAPS)

      def ctrl_key? = ModState.state?(KMOD_CTRL)

      def gui_key? = ModState.state?(KMOD_GUI)

      def l_alt_key? = ModState.state?(KMOD_LALT)

      def l_ctrl_key? = ModState.state?(KMOD_LCTRL)

      def l_gui_key? = ModState.state?(KMOD_LGUI)

      def l_shift_key? = ModState.state?(KMOD_LSHIFT)

      def mod_key? = ModState.state != 0

      def mode_key? = ModState.state?(KMOD_MODE)

      def num_key? = ModState.state?(KMOD_NUM)

      def r_alt_key? = ModState.state?(KMOD_RALT)

      def r_ctrl_key? = ModState.state?(KMOD_RCTRL)

      def r_gui_key? = ModState.state?(KMOD_RGUI)

      def r_shift_key? = ModState.state?(KMOD_RSHIFT)

      def scroll_lock_key? = ModState.state?(KMOD_SCROLL)

      def shift_key? = ModState.state?(KMOD_SHIFT)
    end
  end
end
