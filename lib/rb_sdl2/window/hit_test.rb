module RbSDL2
  class Window
    SDL_HITTEST_NORMAL             = 0
    SDL_HITTEST_DRAGGABLE          = 1
    SDL_HITTEST_RESIZE_TOPLEFT     = 2
    SDL_HITTEST_RESIZE_TOP         = 3
    SDL_HITTEST_RESIZE_TOPRIGHT    = 4
    SDL_HITTEST_RESIZE_RIGHT       = 5
    SDL_HITTEST_RESIZE_BOTTOMRIGHT = 6
    SDL_HITTEST_RESIZE_BOTTOM      = 7
    SDL_HITTEST_RESIZE_BOTTOMLEFT  = 8
    SDL_HITTEST_RESIZE_LEFT        = 9

    class HitTest < ::FFI::Function
      # proc には引数を１つ取るコーラブル・オブジェクトを与えます。
      # コーラブル・オブジェクトの引数に与えられる値はウィンドウのクリックされた位置を表す配列（[x, y]）です。
      # コールバックは整数を戻す必要があります。何もしないのであれば SDL_HITTEST_NORMAL を戻します。
      # 詳しくは SDL_HitTestResult 列挙体を参照してください。
      # コールバックを呼び出したウィンドウの情報を受け取ることはできません。
      # コーラブル・オブジェクトに対応するウィンドウ・オブジェクトを取り込むことで同じことができます。
      def initialize(proc)
        # SDL_HitTestResult SDL_HitTest(SDL_Window* win, const SDL_Point* area, void* data)
        super(:int, [:pointer, :pointer, :pointer]) do |_win, area, _data|
          # コールバック実行終了を OS が待つようなので、与えらえた window ポインターは有効なものとしてよいだろう。
          # area には Point のアドレスが入る。Point は x, y の２つの int 型メンバーである。
          proc.call(::SDL::Point.new(area).values)
        end
      end
    end
  end
end
