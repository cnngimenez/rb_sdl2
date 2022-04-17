module RbSDL2
  class Cursor
    class CursorPointer < ::FFI::AutoPointer
      class << self
        # カーソルポインターはいつでも（表示中であっても）安全に開放できる。
        # SDL はカレントカーソルが開放されたときはデフォルトカーソルをカレントカーソルに設定する。
        # デフォルトカーソルは FreeCursorを呼び出しても開放されない。
        def release(ptr) = ::SDL.FreeCursor(ptr)
      end
    end

    @current = nil # カレントカーソルのオブジェクトを GC に回収されないように保持するために使用。

    class << self
      # nil を与えた場合デフォルトカーソルが設定されます。
      def current=(cursor)
        @current = if cursor.nil?
                     ::SDL.SetCursor(::SDL.GetDefaultCursor) # => nil
                   elsif Cursor === cursor
                     ::SDL.SetCursor(cursor)
                     cursor
                   else
                     raise TypeError
                   end
      end

      def current?(cursor) = ::SDL.GetCursor == cursor.to_ptr

      def hide
        ::SDL.ShowCursor(::SDL::DISABLE)
        nil
      end

      def show
        ::SDL.ShowCursor(::SDL::ENABLE)
        nil
      end

      def shown? = ::SDL.ShowCursor(::SDL::QUERY) == ::SDL::ENABLE

      # カーソルの再描画を行います。
      def update = ::SDL.SetCursor(nil); self

      # obj が Surface オブジェクトの時はカラーカーソルを作成します。
      # その際に hot 引数にカーソルの判定位置を与えることができます。値は [x, y] です。
      # 引数に与えた Surface オブジェクトは SDL 側にコピーされるため呼び出し後に安全に開放できます。
      # obj が Symbol の時はシステムカーソルを作成します。
      # Symbol は :arrow, :i_beam, :wait, :crosshair, :wait_arrow, :size_nw_se, :size_ne_sw,
      # :size_we, :sie_ns, :size_all, :no, :hand が指定できます。
      # obj が　nil の場合はデフォルトカーソルを作成します。
      def new(obj = nil, hot: nil)
        ptr = CursorPointer.new(
          case obj
          when Surface
            hot_x, hot_y = hot
            # SDL_CreateColorCursor() は与えられた surface をコピーする。
            # 呼び出し後に引数に与えた surface オブジェクトは安全に開放できる。
            ::SDL.CreateColorCursor(obj, hot_x, hot_y)
          when Symbol
            id = case obj
                 when :arrow      then ::SDL::SYSTEM_CURSOR_ARROW
                 when :i_beam     then ::SDL::SYSTEM_CURSOR_IBEAM
                 when :wait       then ::SDL::SYSTEM_CURSOR_WAIT
                 when :crosshair  then ::SDL::SYSTEM_CURSOR_CROSSHAIR
                 when :wait_arrow then ::SDL::SYSTEM_CURSOR_WAITARROW
                 when :size_nw_se then ::SDL::SYSTEM_CURSOR_SIZENWSE
                 when :size_ne_sw then ::SDL::SYSTEM_CURSOR_SIZENESW
                 when :size_we    then ::SDL::SYSTEM_CURSOR_SIZEWE
                 when :size_ns    then ::SDL::SYSTEM_CURSOR_SIZENS
                 when :size_all   then ::SDL::SYSTEM_CURSOR_SIZEALL
                 when :no         then ::SDL::SYSTEM_CURSOR_NO
                 when :hand       then ::SDL::SYSTEM_CURSOR_HAND
                 else raise ArgumentError
                 end
            ::SDL.CreateSystemCursor(id)
          when nil
            # SDL 側にあるデフォルトカーソルのポインターを戻す。このポインターはシングルトンである。
            # ポインターを SDL_FreeCursor() へ与えても安全である。SDL 内部では開放されない。
            ::SDL.GetDefaultCursor
          else
            raise ArgumentError
          end
        )
        raise RbSDL2Error if ptr.null?
        super(ptr)
      end
    end

    def initialize(ptr)
      @ptr = ptr
    end

    def ==(other)
      other.respond_to?(:to_ptr) && other.to_ptr == @ptr
    end

    # 自身をカレントカーソルに設定します。カーソルの表示状態は変更されません。
    def current! = Cursor.current = self

    # 自身がカレントカーソルの場合に true を戻します。
    def current? = Cursor.current?(self)

    # 自身がカレントカーソルの場合のみカーソルを非表示にします。
    def hide
      current? && Cursor.hide
      self
    end

    # 自身を表示カーソルにします。この時カレントカーソルは自身に設定されています。
    def show
      current! && Cursor.show
      self
    end

    # 自身がカレントカーソルの場合かつカーソル表示中の時に true を戻します。
    def shown? = current? && Cursor.shown?

    def to_ptr = @ptr
  end
end
