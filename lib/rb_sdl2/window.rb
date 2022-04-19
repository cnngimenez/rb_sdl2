module RbSDL2
  class Window
    class << self
      def keyboard_focused = (ptr = ::SDL.GetKeyboardFocus).null? ? nil : to_ptr(ptr)

      def mouse_focused = (ptr = ::SDL.GetMouseFocus).null? ? nil : to_ptr(ptr)

      def grabbed = (ptr = ::SDL.GetGrabbedWindow).null? ? nil : to_ptr(ptr)

      def new(title = nil, x = nil, y = nil, w = 640, h = 480, flags = nil, **opts)
        x ||= ::SDL::WINDOWPOS_CENTERED_MASK
        y ||= ::SDL::WINDOWPOS_CENTERED_MASK
        flags ||= WindowFlags.to_num(**opts)
        ptr = ::SDL.CreateWindow(title&.to_s, x, y, w, h, flags)
        raise RbSDL2Error if ptr.null?
        to_ptr(ptr)
      end

      # w, h は nil の場合は shape に与えられたサーフェィスの w, h を使用する。
      # flags は常に borderless: true, fullscreen: false, resizable: false が設定される。
      # shape には Surface のインスタンス・オブジェクトを与える。
      # 作成されたウィンドウは透明である。表示内容は作成後に描画する必要がある。
      # ウィンドウへの操作を扱いたければ HitTest コールバックを設定しコールバック側で処理を行う必要がある。
      def shaped(title = nil, x = nil, y = nil, w = nil, h = nil, flags = nil,
                 alpha_test: nil, color_key: nil, shape:, **opts)
        flags ||= WindowFlags.to_num(**opts)
        # CreateShapedWindow は引数 x, y を無視する。そして x = -1000, y = -1000 に強制する。
        # w, h は形状マスクのサイズに合わせる必要がある。
        ptr = ::SDL.CreateShapedWindow(title, 0, 0, shape.w, shape.h, flags)
        raise RbSDL2Error if ptr.null?
        to_ptr(ptr).tap do |obj|
          obj.shape_set(shape, alpha_test: alpha_test, color_key: color_key)
          obj.size = [w || shape.w, h || shape.h]
          # 位置の再指定を行いアプリケーションの意図した位置に表示する。
          obj.position = [x || ::SDL::WINDOWPOS_CENTERED_MASK,
                          y || ::SDL::WINDOWPOS_CENTERED_MASK]
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

    def initialize(num)
      @id = num
    end

    require_relative 'window/display'
    require_relative 'window/grab'
    require_relative 'window/position'
    require_relative 'window/shape'
    require_relative 'window/size'
    include Display, Grab, Position, Shape, Size

    def always_on_top=(bool)
      ::SDL.SetWindowAlwaysOnTop(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
    end

    def border_size
      top_left_bottom_right = Array.new(4) { ::FFI::MemoryPointer.new(:int) }
      err = ::SDL.GetWindowBordersSize(self, *top_left_bottom_right)
      raise RbSDL2Error if err < 0
      top_left_bottom_right.map(&:read_int)
    end

    def bordered=(bool)
      ::SDL.SetWindowBordered(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
    end

    def destroy
      return if destroyed?
      HitTest.callback_set(self, nil)
      ::SDL.DestroyWindow(self)
    end

    def destroyed? = ::SDL.GetWindowFromID(id).null?

    def flags = ::SDL.GetWindowFlags(self)

    require_relative 'window/window_flags'
    include WindowFlags

    def format = ::SDL.GetWindowPixelFormat(self)

    require_relative "pixel_format_enum"
    include PixelFormatEnum

    def flash(bool = true)
      operation = bool ? ::SDL::FLASH_UNTIL_FOCUSED : ::SDL::FLASH_CANCEL
      err = ::SDL.FlashWindow(self, operation)
      raise RbSDL2Error if err < 0
      bool
    end

    def flash!
      err = ::SDL.FlashWindow(self, ::SDL::FLASH_BRIEFLY)
      raise RbSDL2Error if err < 0
      self
    end

    def fullscreen
      err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN)
      raise RbSDL2Error if err < 0
      self
    end

    def fullscreen_desktop
      err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN_DESKTOP)
      raise RbSDL2Error if err < 0
      self
    end

    def hide
      ::SDL.HideWindow(self)
      self
    end

    require_relative 'window/hit_test'

    def hit_test_callback_set(*args) = HitTest.callback_set(self, *args)

    def icon=(surface)
      ::SDL.SetWindowIcon(self, surface)
    end

    attr_reader :id

    def maximize
      ::SDL.MaximizeWindow(self)
      self
    end

    def minimize
      ::SDL.MinimizeWindow(self)
      self
    end

    def mouse_position=(x_y)
      ::SDL.WarpMouseInWindow(self, *x_y)
    end

    def opacity
      out_opacity = ::FFI::MemoryPointer.new(:float)
      err = ::SDL.GetWindowOpacity(self, out_opacity)
      raise RbSDL2Error if err < 0
      out_opacity.read_float
    end

    # ウィンドウの透明度を変更する。値は 0.0 から 1.0。値が低いほど透明になる。
    def opacity=(val)
      err = ::SDL.SetWindowOpacity(self, val)
      raise RbSDL2Error if err < 0
    end

    def popup
      ::SDL.RaiseWindow(self)
      self
    end

    def resizable=(bool)
      ::SDL.SetWindowResizable(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
    end

    def restore
      ::SDL.RestoreWindow(self)
      self
    end

    def show
      ::SDL.ShowWindow(self)
      self
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

    def title = ::SDL.GetWindowTitle(self).read_string.force_encoding(Encoding::UTF_8)

    def title=(obj)
      ::SDL.SetWindowTitle(self, obj&.to_s&.encode(Encoding::UTF_8))
    end

    def to_ptr
      ptr = ::SDL.GetWindowFromID(id)
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

    def windowed
      err = ::SDL.SetWindowFullscreen(self, 0)
      raise RbSDL2Error if err < 0
      self
    end
  end
end
