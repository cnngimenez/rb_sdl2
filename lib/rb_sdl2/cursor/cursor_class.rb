module RbSDL2
  module Cursor
    class CursorClass
      def initialize(ptr)
        @ptr = ptr
      end

      def current! = Cursor.current = self

      def current? = Cursor.current?(self)

      def hide = Cursor.hide

      def show
        current!
        Cursor.show
      end

      def shown? = Cursor.shown? && current?

      def to_ptr = @ptr
    end
  end
end
