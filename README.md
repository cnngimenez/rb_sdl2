# RbSDL2

RbSDL2 は [SDL](https://www.libsdl.org) (Simple DirectMedia Layer) の機能を
Ruby オブジェクトとして提供します。

SDL 2.0.22 以降を対象としています。この Gem には SDL は含まれていません。
利用する際は環境に合わせて SDL を用意してください。

## Description

RbSDL2 は SDL の機能やポインターを Ruby オブジェクトとして扱います。
ポインター管理を RbSDL2 が行っているのでメモリー管理を気にせずに SDL の機能を使うことができます。
最低限のマネージ機能も用意しています。例えばコールバック関数を設定した場合はそのオブジェクトを保持します。
スコープを外れてもコアダンプすることはありません。

[sdl2-bindings](https://rubygems.org/gems/sdl2-bindings) を基に構築していますので、
オブジェクトの仕様や性能が気に入らない場合は直接（そして全ての） SDL 関数を呼び出すこともできます。
各オブジェクトは外部からのポインターから作成することができます。
C で書いたライブラリとの部分的な連携に利用することもできます。

SDL の仕様や機能について知っている必要はありますが Ruby のコードを読めれば使えるようになっています。

## Installation

    $ gem install rb_sdl2

## Usage

```ruby
require 'rb_sdl2'

include RbSDL2

RbSDL2.load('SDL2 Library path') # SDL を読み込みます。必ず必要です。
RbSDL2.init # SDL を初期化します。

image = Surface.load("image.bmp") # 画像をメモリーに読み込みます。画像形式は BMP のみです。
window = Window.new("Title")
window.update { |s| s.blit(image) } # Window へ画像を描画します。

RbSDL2.loop do
  break if Event.quit? || Keyboard.key?("Escape") # ユーザがウィンドウを閉じたことを検出します。
  # キーボードの A キーを押したか調べます。押していればダイアログボックスを表示します。
  window.info_alert("Message") if Keyboard.key?("A")
  # マウスのボタン（種類問わず）を押したか調べます。押していればダイアログボックスを表示します。
  window.error_alert("Message from mouse") if Mouse.any_button?
  Timer.delay(33) # SDL のタイマーを使用して 33 ミリ秒間、停止します。
end
# 終了の際に SDL から得たポインターのことは考えなくてよい。 SDL_Quit() も不要。
```

## License

Zlib
