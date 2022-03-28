module RbSDL2
  module Hint
    class << self
      # ヒントの設定が行われていないときは nil を戻す。
      # SDL のデフォルト値はハードコーディングされているためこのメソッドで読み出すことはできない。
      def [](name)
        ptr = ::SDL.GetHint(name.to_s)
        ptr.null? ? nil : ptr.read_string
      end

      def []=(name, value)
        bool = ::SDL.SetHintWithPriority(name.to_s, value&.to_s, ::SDL::HINT_OVERRIDE)
        raise RbSDL2Error, "failed to set hint" if bool == ::SDL::FALSE
      end

      def clear = ::SDL.ClearHints

      def freeze = raise(TypeError, "cannot freeze Hint")

      def include?(name) = ::SDL.GetHintBoolean(name, -1) != -1
      alias has_key? include?
      alias member? include?
      alias key? include?
    end
  end
end
