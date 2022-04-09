module RbSDL2
  class RWObject < RWOps
    class CloseCallback < ::FFI::Function
      def initialize
        # int (* close) (struct RWops * context);
        super(:int, [:pointer]) do |context|
          yield
          0
        rescue => e
          raise e if $DEBUG
          Error.last_error_message = e.message
          -1
        ensure
          # SDL_RWclose() の仕様により成功、失敗問わずポインターを開放する。
          ::SDL.FreeRW(context)
        end
      end
    end

    class ReadCallback < ::FFI::Function
      def initialize
        # size_t (* read) (struct RWops * context, void *ptr, size_t size, size_t maxnum);
        super(:size_t, [:pointer, :pointer, :size_t, :size_t]) do |_context, ptr, size, max_num|
          num = size * max_num
          str = yield(num)
          next 0 if str.nil? # EOF
          len = str.size
          if len > num # 要求より多い文字数を返している。obj.read が壊れている。
            raise RbSDL2Error, "The return value of read method is corrupted"
          end
          ptr.write_bytes(str, 0, len)
          len / size
        rescue => e
          raise e if $DEBUG
          Error.last_error_message = e.message
          0
        end
      end
    end

    class SeekCallback < ::FFI::Function
      def initialize
        # Sint64 (* seek) (struct RWops * context, Sint64 offset, int whence);
        super(:int64, [:pointer, :int64, :int]) do |_context, offset, whence|
          # SDL_RWseek() の仕様によりシーク後の現在位置を戻す必要がある。
          yield(offset, whence)
        rescue => e
          raise e if $DEBUG
          Error.last_error_message = e.message
          -1
        end
      end
    end

    class SizeCallback < ::FFI::Function
      def initialize
        # Sint64 (* size) (struct RWops * context);
        super(:int64, [:pointer]) do |_context|
          # Ruby ではサイズが不明な IO は size メソッドが無い（NoMethodError）。
          yield
        rescue => e
          raise e if $DEBUG
          Error.last_error_message = e.message
          # 不明な時は -1。
          -1
        end
      end
    end

    class WriteCallback < ::FFI::Function
      def initialize
        # size_t (* write) (struct RWops * context, const void *ptr, size_t size, size_t num);
        super(:size_t, [:pointer, :pointer, :size_t, :size_t]) do |_context, ptr, size, max_num|
          str = ptr.read_bytes(size * max_num)
          yield(str) / size
        rescue => e
          raise e if $DEBUG
          Error.last_error_message = e.message
          0
        end
      end
    end

    require_relative 'rw_ops_pointer'

    # obj 引数には Ruby の IO オブジェクトのように振る舞うオブジェクトを与える。
    # 期待される振る舞いは close, read, seek, size, tell, write メソッド呼び出しに応答すること。
    # メソッドが無い場合やメソッドから例外が出た場合は SDL 側にエラー値を戻す。
    # autoclose 引数に true を与えた場合 close メソッドの呼び出し、GC の回収時に obj 引数に与えたオブジェクトを
    # クローズする。
    # C のスコープへ渡す場合、ポインターが利用されている間 RWOps オブジェクトを生存させる必要がある。
    def initialize(obj)
      ptr = ::SDL.AllocRW
      raise RbSDL2Error if ptr.null?
      super(
        begin
          # メンバーの関数ポインターが NULL であってはならない。
          @st = ::SDL::RWops.new(ptr)
          # 引数に与えた proc 内で例外が出たときは SDL へ例外メッセージがセットされエラーを表す戻り値が渡される。
          # デバッグモードの時は Ruby 側へ例外を出す。
          # close_proc: 引数はなし。戻り値は無視される。RWops ポインタの開放を行う必要はない。
          # read_proc:  引数に読み出すバイト数。戻り値は文字列。
          # seek_proc:  引数に offset, whence。IO#seek を参照。戻り値は現在位置（IO#tell）。
          # size_proc:  引数はなし。戻り値はバイト数。不明な場合は何らかの例外を出す。
          # write_proc: 引数に書き込む文字列。戻り値は実際に書き込んだバイト数。
          @st[:close] = @close_callback = CloseCallback.new {} # obj.close しない。autoclose=false
          @st[:read] = @read_callback = ReadCallback.new { |length| obj.read(length) }
          @st[:seek] = @seek_callback = SeekCallback.new { |offset, whence| obj.seek(offset, whence); obj.tell }
          @st[:size] = @size_callback = SizeCallback.new { obj.size }
          @st[:write] = @write_callback = WriteCallback.new { |str| obj.write(str) }
          RWOpsPointer.new(ptr)
        rescue => e
          ::SDL.FreeRW(ptr)
          raise e
        end
      )
      @obj = obj
    end

    def __getobj__ = @obj

    def inspect
      "#<#{self.class.name}:#{@obj.inspect}#{closed? ? " (closed)" : nil}>"
    end
  end
end
