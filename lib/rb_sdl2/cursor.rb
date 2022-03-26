module RbSDL2
  module Cursor
    # カーソルポインターが外部から設定される場合があるため、現在のカーソルを取得する方法を提供しない。
    class << self
      require_relative 'cursor/color_cursor'
      def color_cursor(...) = ColorCursor.new(...)

      def current=(cursor)
        ::SDL.SetCursor(cursor)
      end

      def current?(cursor)
        ::SDL.GetCursor == cursor.to_ptr
      end

      require_relative 'cursor/default_cursor'
      def default_cursor = DefaultCursor.instance

      def hide = ::SDL.ShowCursor(::SDL::DISABLE)

      def show = ::SDL.ShowCursor(::SDL::ENABLE)

      def shown? = ::SDL.ShowCursor(::SDL::QUERY) == ::SDL::ENABLE

      def update
        self.current = nil
        self
      end
    end

    require 'forwardable'
    extend SingleForwardable
    require_relative 'cursor/system_cursor'
    def_single_delegators :SystemCursor,
                          *%i(arrow_cursor crosshair_cursor hand_cursor i_beam_cursor no_cursor
                          size_all_cursor size_ne_sw_cursor size_ns_cursor size_nw_se_cursor
                          size_we_cursor wait_cursor wait_arrow_cursor)
  end
end
