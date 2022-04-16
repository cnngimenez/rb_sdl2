## [Unreleased]

### Added
- CPUInfo.cpu_extension? : CPU 拡張命令セットの存在を問い合わせる。
- Error.last_error_message= : SDL のエラーメッセージを設定する。
- Event : SDL_POLLSENTINEL イベントを追加。
- Event.register_events : SDL_RegisterEvents() への素直な実装。
- Event.malloc : イベントポインターを確保する（だけ）のため。これは EventQueue で使うために実装した。
- Event#poll_sentinel? : SDL_POLLSENTINEL イベントを追加。
- RbSDL2 : クラスメソッドへ CPUInfo, Platform, SDL, Timer, Version のメソッドを追加した。
- RbSDL2.clipboard_text, RbSDL2.clipboard_text= : テキストクリップボードの読み書き。
- RbSDL2.open_rw : ファイル、メモリー、IO オブジェクトを RWOps インスタンスで開く。Surface.load などで使用する。
- RbSDL2.open_url : アプリケーションからブラウザーを起動できる。
- RWFile, RWMemory, RWObject : SDL の SDL_RWops コンストラクターに応じてクラスを分けた。RWOps を継承している。
- Surface#color : 指定座標のピクセルのカラーを戻す。
- Surface#pixel : 指定座標のピクセル値を戻す。

### Changed
- sdl2-bindings v0.1.0 に対応した。以前のバージョンは使用できない。
- Error.message : Error.last_error_message へリネーム。
- Event.new : type オプション引数を必須とした。不完全なイベントを作成させないため。
- Event.to_ptr : ポインターの示すイベントをディープコピーしたものを戻す。イベントのメンバーにあるポインターを勝手に開放することができないため。
- Event.count : type 引数を削除。キューの特性から不必要と判断。
- Event.enq, Event.deq: 例外を RbSDL2Error に変更。
- Event.disable, Event.enable, Event.ignore? : イベントを表すシンボルを受け取るようになった。
- Event.add_watch, Event.remove_watch : proc オブジェクトを受け SDL のイベントワッチに設定する。
- Event.deq : type 引数にシンボルを受けるようなった。
- Event#[]= : file メンバーへ nil を与えたとき空文字列として扱うように変更。
- Event#inspect : 過剰だった情報量を減らした。
- EventFilter : 与えられたブロックへコピーしたイベントを渡すようにした。イベントに干渉することはできない。しかし、イベントオブジェクトの取り扱いは自由になる。
- Palette#inspect : 過剰だった情報量を減らした。
- PixelFormatEnum.to_num : 引数に整数を受けなくなった。また定義外のフォーマットネームの場合は例外を戻すようになった。
- RbSDL2.loop : ループごとに Event.clear を呼び出すのをやめた。これはイベントを握りつぶさないようにするため。
- RWOps : SDL_RWops コンストラクタ毎に子クラスへ分けた。実際に利用する際には RbSDL2.open_rw を使うこと。
- SDL.init, SDL.init? : 引数の形式を変更。

### Deprecated

### Fixed
- Event : EventType クラスメソッドへのデリーゲート指定が正しくなかった。
- Event#initialize_copy : Drop イベントのディープコピーの際に元の file メンバーのポインターを開放ないように。

### Removed
- AudioBuffer.load_rw : load に取り込まれた。
- CPUInfo : 拡張命令クエリーメソッドを全て削除。これらは CPUInfo.cpu_extension? メソッドに取って変わられら。
- Event.clear : ポインターを含むイベントのクリアー結果を定義できない。またメモリーリークの危険性のため。
- Event.define_user_event : SDL 側への登録と名前定義が同時に行っていたが、これは使い勝手が悪い。求められているものは任意のタイプ値への名前定義だろう。
- Event.each, Event.reject! : イベントのメンバーが持つポインターの取り扱いが定義できないため。
- Event.filter_callback_set : イベントを落とす際にメンバーが持つポインターの取り扱いが定義できないため。
- Event.add_watch_callback, Event.remove_watch_callback : userdata引数のポインターの取り扱いが定義できないため。
- Event#get : poll でよい。キューに対するメソッド名として不適切。
- Event#typed? : UserEvent を含めた正確な応答ができないため。
- EventType.to_type : type 値から直接メンバークラスを求めるように変更したため。
- EventType.minmax : 使わなくなった。
- PixelFormatEnum : パックされたフォーマットの解析メソッドを削除。実装を変更し不要となったため。
- Surface.load_rw : load に取り込まれた。
- Surface＃save_rw : save に取り込まれた。

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
