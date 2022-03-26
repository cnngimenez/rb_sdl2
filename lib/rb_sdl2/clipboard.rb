module RbSDL2
  module Clipboard
    class << self
      def clear = self.text = nil

      # イベントを pump したとき外部からのクリップボード取得が行われる。
      # その際に CLIPBOARDUPDATE イベントがキューに入る。これはイベントコールバックで捕獲できる。
      # 読み出し時にクリップボードの内容はクリアーされない。
      def text
        # GetClipboardText は NULL ポインターを戻さない。返すべき内容がない場合は空の文字列を戻す。
        ::SDL.GetClipboardText.read_string.force_encoding(Encoding::UTF_8)
      ensure
        # GetClipboardText は呼び出されるたびに OS から取得したクリップボードの内容を SDL 内部に保存し、
        # それをさらにコピーしたものを戻す。
        # アプリケーション側は取得した文字列ポインタを必ず開放しなければならない。
        ::SDL.free(ptr)
      end

      # クリップボードの内容を戻す。text メソッドと違い読み出し後にクリップボードの内容をクリアーする。
      def text!
        str = text
        clear
        str
      end

      # クリップボードへ書き込む。クリップボードはパブリックであり他のアプリケーションから取得できる。
      # 当然、SDL もこの書き込みを補足する。
      # クリップボードの読み出しを行わずに、大量のクリップボード書き込みを行うと SDL はエラーを戻す。
      # このエラーは SDL からではなく OS から戻るエラーである。書き込み上限や既に書き込んだ回数を知る方法はない。
      # また、アプリケーション側でクリップボードを読み出しても制限を回避できない。
      # （OS に保存されたクリップボードはパブリックなコピーでありユーザが取り出さなければそのコピーは消えないだろう）
      def text=(obj)
        raise RbSDL2Error if ::SDL.SetClipboardText(obj&.to_s&.encode(Encoding::UTF_8)) < 0
      end

      # クリップボードに内容があるか確認をする。
      # これはアプリケーションがクリップボードを読み出しても内容はクリアーされないため、
      # クリップボードの更新を知るためには実装を工夫する必要がある。
      # もっとも簡単な方法は、クリップボードの内容を読み込み度に Clipboard.text = nil を実行し、
      # クリップボードをクリアする。
      def text? = ::SDL.HasClipboardText == ::SDL::TRUE
    end
  end
end
