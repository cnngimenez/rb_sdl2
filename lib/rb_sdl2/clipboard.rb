module RbSDL2
  module Clipboard
    class << self
      # クリップボードの内容をクリアします。
      def clear = ::SDL.SetClipboardText(nil)

      require_relative 'sdl_pointer'

      # テキストクリップボードの内容を戻します。文字エンコードは UTF-8 です。
      # このメソッドを使用する前に video sub-system を初期化しておく必要があります。
      # クリップボードの取得ができない場合（video sub-system が初期化されていない）場合はエラー通知します。
      # 読み出し時にクリップボードの内容はクリアーされません。
      # クリップボードの状態が変化したかどうか知りたい場合はイベントを監視してください。
      # その場合はイベントを受け取るためウィンドウを表示します。
      # 次にそのウィンドウがフォーカスされた時に SDL_CLIPBOARDUPDATE イベントを受け取ることができます。
      def text
        # SDL_GetClipboardText() は NULL ポインターを戻さない。返すべき内容がない場合は空文字列を戻す。
        # 取得できないとき（video sub-system が初期化されていない）も空文字列を戻す。
        # SDL は OS から取得したクリップボードの内容を SDL 内部に保存し、それをさらにコピーしたものを戻す。
        # アプリケーション側は取得した文字列ポインタを必ず開放しなければならない。
        ptr = SDLPointer.new(::SDL.GetClipboardText)
        s = ptr.to_s
        # クリップボードが空の時（OS 起動直後など）およびエラーの際も空文字列を戻す。
        raise RbSDL2Error if s.empty? && !SDL.init?(:video)
        s
      end

      # テキストクリップボードへ書き込みます。書き込んだ内容は外部アプリケーションから取得できます。
      # 書き込みを行った場合 SDL は SDL_CLIPBOARDUPDATE イベントを発生させます。
      # 繰り返しクリップボード書き込みを行うとエラーを戻します。この上限は OS 側にあるため事前に知る方法はありません。
      # その場合は Clipboard.clear を実行すると書き込みができるようになります。
      def text=(s)
        raise RbSDL2Error if ::SDL.SetClipboardText(SDL.str_to_sdl(s)) < 0
      end

      # クリップボードに内容があるか確認します。
      # 取得できないとき（video sub-system が初期化されていない）も false を戻します。
      # 外部アプリケーションがクリップボードを読み出しても内容はクリアーされません。
      # クリップボードのクリアを行った場合、または外部アプリケーションからテキスト以外の内容がクリップボードにセット
      # された場合 false になります。
      def exist? = ::SDL.HasClipboardText == ::SDL::TRUE
    end
  end
end
