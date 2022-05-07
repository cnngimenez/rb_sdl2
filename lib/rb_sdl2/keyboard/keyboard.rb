module RbSDL2
  module Keyboard
    require_relative 'mod_state'
    extend ModState

    class << self
      # いずれかのキーが押されている場合に true を戻す。つまり *any key* が押されたということ。
      # このメソッドを使用するには定期的に Event.pump を呼び出してキーボード状態を更新する必要があります。
      def any_key? = state.any?
      alias hit_any_key? any_key?
      alias pressed_any_key? any_key?

      # s に与えた文字列に対応するスキャンコードのキーが押されてい場合に true を戻します。
      # キーが押されていない場合、対応するスキャンコードが無い場合は false を戻します。
      # このメソッドを使用するには定期的に Event.pump を呼び出してキーボード状態を更新する必要があります。
      def key?(s) = state[::SDL.GetScancodeFromName(s)]
      alias pressed_key? key?

      # num に与えたキーコードに対応する文字列を戻します。対応する文字列が無い場合は nil を戻します。
      def keycode_name(num) = (s = ::SDL.GetKeyName(num).read_string).empty? ? nil : s

      # キーコードをスキャンコードに変換します。対応するキーコードがない場合は nil を戻します。
      def keycode_to_scancode(num) = ::SDL.GetScancodeFromKey(num).nonzero?

      # 現在キーボードの押されているキーの名前を配列で戻します。
      # このメソッドを使用するには定期的に Event.pump を呼び出してキーボード状態を更新する必要があります。
      def pressed_keys = state.to_a.map { |n| Keyboard.scancode_name(n) }

      # num に与えたスキャンコードに対応する文字列を戻します。対応する文字列が無い場合は nil を戻します。
      def scancode_name(num) = (s = ::SDL.GetScancodeName(num).read_string).empty? ? nil : s

      # num に与えたスキャンコードのキーが押されている場合に true を戻します。
      # スキャンコードに対応するキーがない場合、キーが押されていない場合は false を戻します。
      def scancode?(num) = state.scancode?(num)

      # スキャンコードをキーコードに変換します。対応するキーコードがない場合は nil を戻します。
      def scancode_to_keycode(num) = ::SDL.GetKeyFromScancode(num).nonzero?

      require_relative 'state'

      def state = State.instance

      # s に与えた文字列に対応するキーコードを戻します。対応するキーコードがない場合は nil を戻します。
      def to_keycode(s) = ::SDL.GetKeyFromName(s).nonzero?

      # s に与えた文字列に対応するスキャンコードを戻します。対応するスキャンコードが無い場合は nil を戻します。
      def to_scancode(s) = ::SDL.GetScancodeFromName(s).nonzero?
    end
  end
end
