module RbSDL2
  module Platform
    class << self
      # プラットフォーム名（動作環境）を文字列で返します。
      # ここでの動作環境は SDL ライブラリが認識しているものです。
      def platform = ::SDL2.SDL_GetPlatform.read_string
    end
  end
end
