module RbSDL2
  module Keyboard
    module KeyMod
      def mod_key? = ::SDL2::KMOD_NONE != mod

      def l_shift_key? = ::SDL2::KMOD_LSHIFT & mod != 0

      def r_shift_key? = ::SDL2::KMOD_RSHIFT & mod != 0

      def l_ctrl_key? = ::SDL2::KMOD_LCTRL & mod != 0

      def r_ctrl_key? = ::SDL2::KMOD_RCTRL & mod != 0

      def l_alt_key? = ::SDL2::KMOD_LALT & mod != 0

      def r_alt_key? = ::SDL2::KMOD_RALT & mod != 0

      def l_gui_key? = ::SDL2::KMOD_LGUI & mod != 0

      def r_gui_key? = ::SDL2::KMOD_RGUI & mod != 0

      def alt_key? = ::SDL2::KMOD_ALT & mod != 0

      def caps_key? = ::SDL2::KMOD_CAPS & mod != 0

      def ctrl_key? = ::SDL2::KMOD_CTRL & mod != 0

      def gui_key? = ::SDL2::KMOD_GUI & mod != 0

      def mode_key? = ::SDL2::KMOD_MODE & mod != 0

      def num_key? = ::SDL2::KMOD_NUM & mod != 0

      def shift_key? = ::SDL2::KMOD_SHIFT & mod != 0
    end
  end
end
