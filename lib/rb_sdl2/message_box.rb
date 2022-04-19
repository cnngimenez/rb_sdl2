module RbSDL2
  module MessageBox
    ERROR = ::SDL::MESSAGEBOX_ERROR
    WARN = ::SDL::MESSAGEBOX_WARNING
    INFO = ::SDL::MESSAGEBOX_INFORMATION

    class << self
      # 簡単なボタン入力のあるウィンドウを表示します。
      # SDL が初期化される前に呼び出すことができます。
      # 環境によってはこのメソッドをメインスレッドで呼び出す必要があるでしょう。
      # このウィンドウを表示中はアプリケーションはブロックされます。
      # ボタン配置は右詰めです。配列の先頭のボタン番号 0 がウィンドウ右側に配置され、以降はその左に配置されます。
      #
      # level: RbSDL2::MessageBox にある ERROR, WARN, INFO, 0 のどれかを与えます。
      # これはウィンドウの本文部分に表示するアイコンを選択します。
      # message:
      # ウィンドウに表示する本文の文字列を与えます。
      # オブジェクトを与えた場合はメソッド内部で文字列への変換を試みます。
      # title:
      # ウィンドウに表示するタイトルの文字列を与えます。
      # オブジェクトを与えた場合はメソッド内部で文字列への変換を試みます。
      # window:
      # 関連のある親ウィンドウがあればそれを与えます。
      # メッセージウィンドウが閉じるまで親ウィンドウは入力を受け付けなくなります。
      # buttons:
      # ボタンに表示する文字列または文字列の配列です。
      # オブジェクトを与えた場合はメソッド内部で配列への変換を試みます。
      # 配列の要素がオブジェクトの場合はメソッド内部で文字列への変換を試みます。
      # nil を与えた場合はボタンが表示されません。
      # その場合はユーザがエスケープキーを押さない限りこのメソッドを終了できません。
      # default:
      # 選択済みのボタンをボタン番号（0 から始まる）指定します。nil の場合はどのボタンも選択されません。
      # ウィンドウ表示中にユーザがリターンキーを押すと選択済みのボタンが押されたことになります。
      #
      # 戻り値は押されたボタン番号か nil です。
      # nil になる場合はこのウィンドウがアクティブな時に表示中にエスケープキーが押された場合です。
      def show(level, message = nil, title = nil, window = nil, buttons: nil, default: nil)
        # アンダーバーのついた変数はオブジェクトをスコープ中に保持するためにある。
        data = ::SDL::MessageBoxData.new
        data[:flags] = level
        data[:window] = _window = window
        data[:title] = _title = ::FFI::MemoryPointer.from_string(
          String(title).dup.encode(Encoding::UTF_8)
        )
        data[:message] = _message = ::FFI::MemoryPointer.from_string(
          String(message).dup.encode(Encoding::UTF_8)
        )

        texts = Array(buttons)

        data[:numbuttons] = num_buttons = texts.size

        _texts = Array.new(num_buttons)
        button_data = ::SDL::MessageBoxButtonData
        st_size = button_data.size

        data[:buttons] = _buttons = ::FFI::MemoryPointer.new(st_size, num_buttons).tap do |ptr|
          texts.each_with_index do |text, idx|
            st = button_data.new(ptr + st_size * idx)
            # Escape キー（SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT）はボタンへ割り当てない。
            # return_key と escape_key は排他的でありが同一値の場合はどちらかが機能しないため。
            st[:flags] = idx == default ? ::SDL::MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT : 0
            st[:buttonid] = idx
            st[:text] = _texts[idx] = ::FFI::MemoryPointer.from_string(
              String(text).dup.encode(Encoding::UTF_8)
            )
            st
          end
        end
        # colorScheme は環境依存。例えば Windows　では反映されない。NULL の場合はシステム設定のカラーを使用する。
        data[:colorScheme] = nil

        ptr = ::FFI::MemoryPointer.new(:int)
        err = ::SDL.ShowMessageBox(data, ptr)
        raise RbSDL2Error if err < 0
        num = ptr.read_int
        # (Escape キーの割り当てがない場合に) Escape キーが押された場合 idx = -1
        num if num >= 0
      end

      # シンプルなメッセージウィンドウを開きます。
      # MessageBox.show の簡易版です。ボタン一つのウィンドウが表示されます。
      # 戻り値は常に true です。
      def simple(level, message = nil, title = nil, window = nil)
        err = ::SDL.ShowSimpleMessageBox(level,
                                         String(title).dup.encode(Encoding::UTF_8),
                                         String(message).dup.encode(Encoding::UTF_8),
                                         window)
        raise RbSDL2Error if err < 0
        true
      end
    end
  end
end
