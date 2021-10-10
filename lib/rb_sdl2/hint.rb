module RbSDL2
  module Hint
    class << self
      def [](name)
        ptr = ::SDL2.SDL_GetHint(name.to_s)
        ptr.null? ? nil : ptr.read_string
      end

      def []=(name, value)
        bool = ::SDL2.SDL_SetHintWithPriority(name.to_s, value&.to_s, ::SDL2::SDL_HINT_OVERRIDE)
        raise RbSDL2Error, "failed to set hint" if bool == ::SDL2::SDL_FALSE
      end

      def clear = ::SDL2.SDL_ClearHints

      def freeze = raise(TypeError, "cannot freeze Hint")

      def include?(name) = ::SDL2.SDL_GetHintBoolean(name, -1) != -1
      alias has_key? include?
      alias member? include?
      alias key? include?
    end
  end
end
