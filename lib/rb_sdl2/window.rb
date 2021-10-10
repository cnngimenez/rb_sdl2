module RbSDL2
  class Window
    class << self
      def keyboard_focused = (ptr = ::SDL2.SDL_GetKeyboardFocus).null? ? nil : to_ptr(ptr)

      def mouse_focused = (ptr = ::SDL2.SDL_GetMouseFocus).null? ? nil : to_ptr(ptr)

      def grabbed = (ptr = ::SDL2.SDL_GetGrabbedWindow).null? ? nil : to_ptr(ptr)

      def new(title = nil, x = nil, y = nil, w = 640, h = 480, flags = nil, **opts)
        x ||= ::SDL2::SDL_WINDOWPOS_CENTERED_MASK
        y ||= ::SDL2::SDL_WINDOWPOS_CENTERED_MASK
        flags ||= WindowFlags.to_num(**opts)
        ptr = ::SDL2.SDL_CreateWindow(title&.to_s, x, y, w, h, flags)
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
        # SDL_CreateShapedWindow は引数 x, y を無視する。そして x = -1000, y = -1000 に強制する。
        # w, h は形状マスクのサイズに合わせる必要がある。
        ptr = ::SDL2.SDL_CreateShapedWindow(title, 0, 0, shape.w, shape.h, flags)
        raise RbSDL2Error if ptr.null?
        to_ptr(ptr).tap do |obj|
          obj.shape_set(shape, alpha_test: alpha_test, color_key: color_key)
          obj.size = [w || shape.w, h || shape.h]
          # 位置の再指定を行いアプリケーションの意図した位置に表示する。
          obj.position = [x || ::SDL2::SDL_WINDOWPOS_CENTERED_MASK,
                          y || ::SDL2::SDL_WINDOWPOS_CENTERED_MASK]
        end
      end

      def to_id(num)
        ptr = ::SDL2.SDL_GetWindowFromID(num)
        raise RbSDL2Error, "invalid window id" if ptr.null?
        obj = allocate
        obj.__send__(:initialize, num)
        obj
      end

      def to_ptr(ptr)
        num = ::SDL2.SDL_GetWindowID(ptr)
        raise RbSDL2Error if num == 0
        obj = allocate
        obj.__send__(:initialize, num)
        obj
      end
    end

    def initialize(num)
      @id = num
    end

    require_relative 'window/dialog'
    require_relative 'window/display'
    require_relative 'window/grab'
    require_relative 'window/position'
    require_relative 'window/shape'
    require_relative 'window/size'
    include Dialog, Display, Grab, Position, Shape, Size

    def always_on_top=(bool)
      ::SDL2.SDL_SetWindowAlwaysOnTop(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
    end

    def border_size
      top_left_bottom_right = Array.new(4) { ::FFI::MemoryPointer.new(:int) }
      err = ::SDL2.SDL_GetWindowBordersSize(self, *top_left_bottom_right)
      raise RbSDL2Error if err < 0
      top_left_bottom_right.map(&:read_int)
    end

    def bordered=(bool)
      ::SDL2.SDL_SetWindowBordered(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
    end

    def destroy
      return if destroyed?
      HitTest.callback_set(self, nil)
      ::SDL2.SDL_DestroyWindow(self)
    end

    def destroyed? = ::SDL2.SDL_GetWindowFromID(id).null?

    def flags = ::SDL2.SDL_GetWindowFlags(self)

    require_relative 'window/window_flags'
    include WindowFlags

    def format = ::SDL2.SDL_GetWindowPixelFormat(self)

    require_relative "pixel_format_enum"
    include PixelFormatEnum

    def flash(bool = true)
      operation = bool ? ::SDL2::SDL_FLASH_UNTIL_FOCUSED : ::SDL2::SDL_FLASH_CANCEL
      err = ::SDL2.SDL_FlashWindow(self, operation)
      raise RbSDL2Error if err < 0
      bool
    end

    def flash!
      err = ::SDL2.SDL_FlashWindow(self, ::SDL2::SDL_FLASH_BRIEFLY)
      raise RbSDL2Error if err < 0
      self
    end

    def fullscreen
      err = ::SDL2.SDL_SetWindowFullscreen(self, ::SDL2::SDL_WINDOW_FULLSCREEN)
      raise RbSDL2Error if err < 0
      self
    end

    def fullscreen_desktop
      err = ::SDL2.SDL_SetWindowFullscreen(self, ::SDL2::SDL_WINDOW_FULLSCREEN_DESKTOP)
      raise RbSDL2Error if err < 0
      self
    end

    def hide
      ::SDL2.SDL_HideWindow(self)
      self
    end

    require_relative 'window/hit_test'

    def hit_test_callback_set(*args) = HitTest.callback_set(self, *args)

    def icon=(surface)
      ::SDL2.SDL_SetWindowIcon(self, surface)
    end

    attr_reader :id

    def maximize
      ::SDL2.SDL_MaximizeWindow(self)
      self
    end

    def minimize
      ::SDL2.SDL_MinimizeWindow(self)
      self
    end

    def mouse_position=(x_y)
      ::SDL2.SDL_WarpMouseInWindow(self, *x_y)
    end

    def opacity
      out_opacity = ::FFI::MemoryPointer.new(:float)
      err = ::SDL2.SDL_GetWindowOpacity(self, out_opacity)
      raise RbSDL2Error if err < 0
      out_opacity.read_float
    end

    # ウィンドウの透明度を変更する。値は 0.0 から 1.0。値が低いほど透明になる。
    def opacity=(val)
      err = ::SDL2.SDL_SetWindowOpacity(self, val)
      raise RbSDL2Error if err < 0
    end

    def popup
      ::SDL2.SDL_RaiseWindow(self)
      self
    end

    def resizable=(bool)
      ::SDL2.SDL_SetWindowResizable(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
    end

    def restore
      ::SDL2.SDL_RestoreWindow(self)
      self
    end

    def show
      ::SDL2.SDL_ShowWindow(self)
      self
    end

    def surface
      ptr = ::SDL2.SDL_GetWindowSurface(self)
      if ptr.null?
        @surface = nil
        raise RbSDL2Error
      end
      # SDL_Surface は参照カウンターで管理されているため Ruby 側でポインターを保持している限り
      # 同アドレスに違う SDL_Surface が作成されることはない。安全にキャッシュできる。
      ptr == @surface&.to_ptr ? @surface : @surface = Surface.to_ptr(ptr)
    end

    def title = ::SDL2.SDL_GetWindowTitle(self).read_string.force_encoding(Encoding::UTF_8)

    def title=(obj)
      ::SDL2.SDL_SetWindowTitle(self, obj&.to_s&.encode(Encoding::UTF_8))
    end

    def to_ptr
      ptr = ::SDL2.SDL_GetWindowFromID(id)
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
      # SDL_UpdateWindowSurface, SDL_UpdateWindowSurfaceRects の *初回* 呼び出しの前に
      # SDL_GetWindowSurface が必要になる。
      surface unless @surface

      err = if rect
              ::SDL2.SDL_UpdateWindowSurfaceRects(self, Rect.new(*rect), 1)
            else
              ::SDL2.SDL_UpdateWindowSurface(self)
            end
      # SDL_GetWindowSurface の後に Window のサイズ変更があった場合はエラーになる。
      if err < 0
        @surface = nil
        raise RbSDL2Error
      end
      self
    end

    def windowed
      err = ::SDL2.SDL_SetWindowFullscreen(self, 0)
      raise RbSDL2Error if err < 0
      self
    end
  end
end
