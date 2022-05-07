## [Unreleased]

## [0.2.0] - 2022-05-08

### Added
- Error.last_error_message= - SDL のエラーメッセージを設定する。
- Event - SDL_TEXTEDITING_EXT, SDL_POLLSENTINEL イベントを追加。
- RbSDL2 - クラスメソッドへ CPUInfo, Keyboard, Platform, SDL, Timer, Version のメソッドを追加した。
- RbSDL2.alert, error_alert, info_alert, warn_alert - シンプルなメッセージボックスを開く。
- RbSDL2.confirm, confirm? - Ok, Cancel のボタンがあるメッセージボックスを開く。
- RbSDL2.clipboard_text, RbSDL2.clipboard_text= - テキストクリップボードの読み書き。
- RbSDL2.hide_cursor, show_cursor - マウスカーソルの表示状態を変更する。
- RbSDL2.open_rw - ファイル、メモリー、IO オブジェクトを RWOps インスタンスで開く。Surface.load などで使用する。
- RbSDL2.open_url - アプリケーションからブラウザーを起動できる。
- RbSDL2.power_info - システムの電源状態を取得する。
- RbSDL2.screen_saver?, screen_saver= - スクリーンセーバー起動の可否状態を取得、設定する。
- RWFile, RWMemory, RWObject - SDL の SDL_RWops コンストラクターに応じてクラスを分けた。RWOps を継承している。
- SDL.ptr_to_str, SDL.str_to_sdl - Ruby 文字列と SDL 文字列の相互変換。
- SDLPointer - SDL のメモリーアロケーターを使用したメモリー領域を扱うためのクラス。
- Surface#pixel_color - 指定座標のピクセルのカラーを戻す。
- Surface#pixel - 指定座標のピクセル値を戻す。
- Window#mouse_rect, mouse_rect= - ウィンドウ内のマウス移動範囲を指定する。

### Changed
- Ruby のバージョン要求を 3.1 以上に変更した。
- sdl2-bindings v0.1.1 に対応した。以前のバージョンは使用できない。
- Audio, Cursor, Event, Keyboard, Mouse, Window - リファクタリング。再設計した。
- Error.message -> Error.last_error_message
- RbSDL2.loop - ループごとに Event.clear を呼び出すのをやめた。これはイベントを握りつぶさないようにするため。
- RWOps - SDL_RWops コンストラクタ毎に子クラスへ分けた。実際に利用する際には RbSDL2.open_rw を使うこと。
- SDL.init, SDL.init? - 引数の形式を変更。
- Window#popup -> Window#current!

### Deprecated

### Fixed

### Removed
- AudioBuffer.load_rw - load に取り込まれた。
- PixelFormatEnum - パックされたフォーマットの解析メソッドを削除。実装を変更し不要になった。
- Surface.load_rw - load に取り込まれた。
- Surface＃save_rw - save に取り込まれた。

### Security

## [0.1.2] - 2021-10-19

### Added
- RWOps#inspect - Return Ruby File#inspect like string.

### Changed
- RWOps - The constructor can accept blocks.
- RWOperator - Code cleanup.

### Fixed
- RWOps - some bugs.
- RWOperator - some bugs.

### Removed
- RWOps.to_ptr - There is no use case.

## [0.1.1] - 2021-10-11

### Added
- Added metadata to gemspec.
- Added document to Error, Platform, SDL, Surface, Timer, and Version.
- Added description to README.md.

### Changed
- Changed the contents of Palette#inspect to something meaningful.

## [0.1.0] - 2021-10-10

- Initial release
