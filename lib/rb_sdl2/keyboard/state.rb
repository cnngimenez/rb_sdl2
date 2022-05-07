module RbSDL2
  module Keyboard
    # SDL 内部にあるキーボードのキースイッチング配列へアクセスします。
    # キースイッチング状態は SDL_PumpEvents() が呼び出さられたときに更新されます。
    class State
      require 'singleton'
      include Singleton

      # SDL ロード前に呼び出すとエラーになる。その際にインスタンスは作成されない。
      def initialize
        num_keys = ::FFI::MemoryPointer.new(:int)
        # SDL_GetKeyboardState() が戻すポインターは SDL がロードされた時点で作成されるため不変と考えてよい。
        # この関数は SDL_Init() より前に呼ぶことができる。
        # 引数に NULL ポインターを与えた場合にエラーを戻す。
        @ptr = ::SDL.GetKeyboardState(num_keys)
        raise RbSDL2Error if @ptr.null?
        @size = num_keys.read_int
      end

      # nth に該当するスキャンコードのキーが押されているか調べます。
      # nth のキーが押されている場合に nth を戻します。
      # nth のキーが押されていない、nth が範囲外の場合は nil を戻します。
      def [](nth) = 0 <= nth && nth < size && @ptr[nth].read_uint8 == ::SDL::PRESSED ? nth : nil
      alias scancode? []

      def any? = to_str.bytes.any? { |n| n == ::SDL::PRESSED }

      def each = block_given? ? size.times { |i| yield(self[i]) } : to_enum

      attr_reader :size
      alias length size

      def to_str = @ptr.read_bytes(size)

      # 現在キーボードの押されている全てのキーに対応するスキャンコードを配列で戻します。
      def to_a = to_str.bytes.with_index.inject([]) { |a, (n, i)| n == ::SDL::PRESSED ? a << i : a }
    end
  end
end
