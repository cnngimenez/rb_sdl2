module RbSDL2
  class Window
    SDL_WINDOWPOS_CENTERED_MASK = 0x2FFF0000

    require_relative 'accessor'
    require_relative 'display'
    require_relative 'flash'
    require_relative 'shape'
    require_relative 'state'

    class << self
      def keyboard_focused = (ptr = ::SDL.GetKeyboardFocus).null? ? nil : to_ptr(ptr)

      def mouse_focused = (ptr = ::SDL.GetMouseFocus).null? ? nil : to_ptr(ptr)

      def grabbed = (ptr = ::SDL.GetGrabbedWindow).null? ? nil : to_ptr(ptr)

      def new(title = "", x = nil, y = nil, w = 640, h = 480, flags: nil, **opts)
        ptr = ::SDL.CreateWindow(SDL.str_to_sdl(title),
                                 x || SDL_WINDOWPOS_CENTERED_MASK, y || SDL_WINDOWPOS_CENTERED_MASK,
                                 w, h, flags || State.to_flags(**opts))
        raise RbSDL2Error if ptr.null?
        to_ptr(ptr)
      end

      # w, h は nil の場合は shape に与えられたサーフェィスの w, h を使用する。
      # flags は常に borderless: true, fullscreen: false, resizable: false が設定される。
      # shape には Surface のインスタンス・オブジェクトを与える。
      # 作成されたウィンドウは透明である。表示内容は作成後に描画する必要がある。
      # ウィンドウへの操作を扱いたければ HitTest コールバックを設定しコールバック側で処理を行う必要がある。
      def shaped(title = "", x = nil, y = nil, w = nil, h = nil, flags: nil,
                 alpha_test: nil, color_key: nil, shape:, **opts)
        size = [w || shape.w, h || shape.h]
        # w, h は形状マスクのサイズに合わせる必要がある。
        ptr = ::SDL.CreateShapedWindow(SDL.str_to_sdl(title), 0, 0, *size,
                                       flags || State.to_flags(**opts))
        raise RbSDL2Error if ptr.null?
        to_ptr(ptr).tap do |obj|
          obj.shape_set(shape, alpha_test: alpha_test, color_key: color_key)
          obj.size = size
          # CreateShapedWindow は引数 x, y を無視する。そして x = -1000, y = -1000 に強制する。
          # 位置の再指定を行いアプリケーションの意図した位置に表示する。
          obj.position = [x || SDL_WINDOWPOS_CENTERED_MASK, y || SDL_WINDOWPOS_CENTERED_MASK]
        end
      end

      def to_id(num)
        ptr = ::SDL.GetWindowFromID(num)
        raise RbSDL2Error, "invalid window id" if ptr.null?
        obj = allocate
        obj.__send__(:initialize, num)
        obj
      end

      def to_ptr(ptr)
        num = ::SDL.GetWindowID(ptr)
        raise RbSDL2Error if num == 0
        obj = allocate
        obj.__send__(:initialize, num)
        obj
      end
    end

    include Accessor, Display, Flash, Shape, State

    def initialize(num)
      @window_id = num
    end

    def ==(other)
      # ウィンドウのポインターアドレスは SDL によって再利用されることがある。
      # 最初に window_id を比較しなければならない。
      other.respond_to?(:window_id) && other.window_id == window_id ||
        other.respond_to?(:to_ptr) && other.to_ptr == to_ptr
    end

    def destroy = ::SDL.DestroyWindow(::SDL.GetWindowFromID(@window_id))

    def destroyed? = ::SDL.GetWindowFromID(@window_id).null?

    def format = ::SDL.GetWindowPixelFormat(self)

    require_relative "../pixel_format_enum"
    include PixelFormatEnum

    require_relative 'hit_test'

    def hit_test=(obj)
      # dup されて片方で無効にした場合、もう一方にコールバックオブジェクトの拘束がおきる。
      # これはほおっておくことにする。
      @hit_test_callback = if obj
                             func = HitTest.new(obj)
                             err = ::SDL.SetWindowHitTest(self, func, nil)
                             raise RbSDL2Error if err < 0
                             func
                           end
      @hit_test_object = obj
    end

    def mouse_position=(x_y)
      ::SDL.WarpMouseInWindow(self, *x_y)
    end

    def surface
      ptr = ::SDL.GetWindowSurface(self)
      if ptr.null?
        @surface = nil
        raise RbSDL2Error
      end
      # Surface は参照カウンターで管理されているため Ruby 側でポインターを保持している限り
      # 同アドレスに違う Surface が作成されることはない。安全にキャッシュできる。
      ptr == @surface&.to_ptr ? @surface : @surface = Surface.to_ptr(ptr)
    end

    def to_ptr
      ptr = ::SDL.GetWindowFromID(@window_id)
      raise RbSDL2Error, "Invalid window id or window was destroyed" if ptr.null?
      ptr
    end

    # ウィンドウのサーフェィスのコピーを戻す。
    # このメソッドはウィンドウのスクリーンショットが欲しい場合に使う。
    def to_surface = surface.then { |s| convert(s.format) }

    # surface メソッドを実行後に Window のサイズ変更があった場合、update メソッドを実行するとエラーになる。
    # このメソッドは self を戻す。
    def update(rect = nil)
      yield(surface) if block_given?
      # UpdateWindowSurface, UpdateWindowSurfaceRects の *初回* 呼び出しの前に
      # GetWindowSurface が必要になる。
      surface unless @surface

      err = if rect
              ::SDL.UpdateWindowSurfaceRects(self, Rect.new(*rect), 1)
            else
              ::SDL.UpdateWindowSurface(self)
            end
      # GetWindowSurface の後に Window のサイズ変更があった場合はエラーになる。
      if err < 0
        @surface = nil
        raise RbSDL2Error
      end
      self
    end

    attr_reader :window_id
    alias id window_id

    def confirm(message) = RbSDL2.confirm(message, self)
    alias confirm? confirm

    def alert(message) = RbSDL2.alert(message, self)

    def error_alert(message) = RbSDL2.error_alert(message, self)

    def info_alert(message) = RbSDL2.info_alert(message, self)

    def warn_alert(message) = RbSDL2.warn_alert(message, self)

  end
end
