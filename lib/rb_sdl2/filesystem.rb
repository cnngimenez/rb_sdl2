module RbSDL2
  module Filesystem
    class << self
      require_relative 'sdl_pointer'

      # RbSDL2 にロードされた SDL2 の配置パスを戻す。
      # パスの末尾にはパスの区切り文字がかならずある。
      # パスの区切り記号は環境依存である。Windows であれば "\" が使われる。
      # Ruby は環境依存のパスの区切り文字を正しく取り扱うことができる。
      def base_path
        # 戻り値のポインターはアプリケーション側で開放する。
        ptr = SDLPointer.new(::SDL.GetBasePath)
        raise RbSDL2Error if ptr.null?
        ptr.to_s
      end

      # アプリケーションが書き込むことのできるパスを戻す。
      # このパスはユーザ毎に存在し、かつアプリケーション固有のものであり OS によって保証されている。
      # org_name, app_name 引数はパスの生成に利用される。引数にパスの区切り記号がある場合はそれを取り除く。
      # ここに SDL2 が提示した守るべきルールの要約を記す。
      # - アプリケーション内でこのメソッドw呼び出す際は org_name は常に同じ文字列を使うこと。
      # - アプリケーションごとに違う app_name を使うこと.
      # - アプリケーションに一度割り当てた app_name は変更しないこと。
      # - 使用する文字はアルファベット, 数字, 空白のみにすること.
      #
      # 注意: このメソッドを呼ぶと SDL はこのメソッドが戻すパスを実際に作成する。
      # 書き込みを行わなかった場合、空のフォルダーが残る。
      # 引数に空文字を渡しすことも、また既存のフォルダーになるように引数を与えることもできる。
      # SDL が知りたいことはアプリケーションがアクセス可能かどうかだけだ。
      # エラーが出るかどうかはユーザが設定するパスのアクセス制限による。
      def pref_path(org_name, app_name)
        # 戻り値のポインターはアプリケーション側で開放する。
        ptr = SDLPointer.new(::SDL.GetPrefPath(SDL.str_to_sdl(org_name), SDL.str_to_sdl(app_name)))
        raise RbSDL2Error if ptr.null?
        ptr.to_s
      end
    end
  end
end
