module RbSDL2
  module Keyboard
    class << self
      def keycode_to_name(keycode) = ::SDL2.SDL_GetKeyName(keycode).read_string

      # 対応するコードが存在しない場合 0 を戻す。戻り値 は nonzero? メソッドをチェーンすることができる。
      # これは KeyboardState#[] での利用を考慮して設計した。
      def keycode_to_scancode(keycode) = ::SDL2.SDL_GetScancodeFromKey(keycode)

      def name_to_keycode(name) = ::SDL2.SDL_GetKeyFromName(name)

      def name_to_scancode(name) = ::SDL2.SDL_GetScancodeFromName(name)

      def scancode_to_keycode(scancode) = ::SDL2.SDL_GetKeyFromScancode(scancode)

      def scancode_to_name(scancode) = ::SDL2.SDL_GetScancodeName(scancode).read_string
    end

    require 'forwardable'
    extend SingleForwardable
    require_relative 'keyboard/keyboard_state'
    def_single_delegators 'KeyboardState.instance', *%i([] each to_str)

    class << self
      # いずれかのキーが押されている場合に true を戻す。つまり *any key* が押されたということ。
      def any_key? = each.any?

      # 引数に与えたキー名のキーが押されている場合に対応するスキャンコードを戻す。
      # 押されていない場合は nil を戻す。
      # 不正な名前の場合でも例外を戻さない、その場合 0 または nil を戻す。
      # キー名は SDL が定義したものである。
      def key?(name) = self[name_to_scancode(name)]

      # 現在押されているキーの名前を配列で戻す。
      def names = scancodes.map { |num| scancode_to_name(num) }

      # 現在押されているキーのスキャンコードを配列で戻す。
      def scancodes = each.to_a.compact!

      def mod = ::SDL2.SDL_GetModState

      require_relative 'keyboard/key_mod'
      include KeyMod

      def mod=(state)
        ::SDL2::SDL_SetModState(state)
      end
    end
  end
end
