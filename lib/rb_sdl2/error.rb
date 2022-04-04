module RbSDL2
  class Error < StandardError
    class << self
      # SDL が設定したエラーメッセージをクリアします。
      def clear = ::SDL.ClearError

      # SDL からのエラーメッセージを文字列で返します。
      # SDL からエラーが通知されてもえらメッセージがあるとは限りません。
      # SDL の関数はエラーの状態を示してもエラーメッセージをセットしない場合があります。
      def last_error_message = ::SDL.GetError.read_string

      def last_error_message=(error_message)
        raise TypeError unless String === error_message
        # SDL_SetError() の第一引数は sprintf フォーマットだが、第二引数以降に可変長引数を与える方法が無い。
        # "%" をエスケープして第二引数を無視させてメモリー参照を行わないようにする。
        ::SDL.SetError(error_message.gsub(/%/, "%%"))
      end
    end
  end
end
