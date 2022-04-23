module RbSDL2
  class Error < StandardError
    class << self
      # SDL が設定したエラーメッセージをクリアします。
      def clear = ::SDL.ClearError

      # SDL からのエラーメッセージを文字列で返します。
      # SDL からエラーが通知されてもエラーメッセージがあるとは限りません。
      # SDL の関数はエラーの状態を示してもエラーメッセージをセットしない場合があります。
      def last_error_message = SDL.ptr_to_str(::SDL.GetError)

      def last_error_message=(error_message)
        # SDL_SetError() の第一引数は sprintf フォーマットである。
        # このメソッドのデザインの都合上、可変長引数を与える方法が無い。
        # "%" をエスケープすることで第二引数を無視させてメモリー参照を行わないようにする。
        ::SDL.SetError(SDL.str_to_sdl(error_message.gsub(/%/, "%%")))
      end
    end
  end
end
