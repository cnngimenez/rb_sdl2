module RbSDL2
  class RWOperator
    # コールバック関数からの例外は全てコールバック中で拾いエラーを表す戻り値に変える。
    # SDL がコールバック関数を呼び出すときに与える引数はチェックされていないことを前提とするべきである。
    # SDL が期待するコールバック関数の戻り値は成功か失敗（エラー）かであり、
    # read, write などの戻り値を考慮した動作を行わない。
    # コールバック関数を実装する際には Ruby アプリケーションが困らない設計を行えばよい。

    class CloseCallback < ::FFI::Function
      def initialize(obj)
        # int (* close) (struct SDL_RWops * context);
        super(:int, [:pointer]) do |_context|
          # close の際に _context ポインターを開放してはならない。
          (obj.close; 0) rescue -1
        end
      end
    end

    class ReadCallback < ::FFI::Function
      def initialize(obj)
        # size_t (* read) (struct SDL_RWops * context, void *ptr, size_t size, size_t maxnum);
        super(:size_t, [:pointer, :pointer, :size_t, :size_t]) do |_context, ptr, size, max_num|
          return 0 if ptr.null?
          max = size * max_num
          str = obj.read(max)
          len = str.size
          # len > max は obj.read が壊れている。
          return 0 if str.nil? || len > max
          ptr.write_bytes(str, 0, len)
          len / size
        rescue
          0
        end
      end
    end

    class SeekCallback < ::FFI::Function
      def initialize(obj)
        # Sint64 (* seek) (struct SDL_RWops * context, Sint64 offset, int whence);
        super(:int64, [:pointer, :int64, :int]) do |_context, offset, whence|
          obj.seek(offset, whence) rescue -1
        end
      end
    end

    class SizeCallback < ::FFI::Function
      def initialize(obj)
        # Sint64 (* size) (struct SDL_RWops * context);
        super(:int64, [:pointer]) do |_context|
          # 不明な時は -1。Ruby では size が不明確なオブジェクトは size メソッドがないだろう。
          obj.size rescue -1
        end
      end
    end

    class WriteCallback < ::FFI::Function
      def initialize(obj)
        # size_t (* write) (struct SDL_RWops * context, const void *ptr, size_t size, size_t num);
        super(:size_t, [:pointer, :pointer, :size_t, :size_t]) do |_context, ptr, size, max_num|
          return 0 if ptr.null?
          obj.write(ptr.read_bytes(size * max_num)) / size rescue 0
        end
      end
    end

    class RWopsPointer < ::FFI::AutoPointer
      class << self
        # SDL_AllocRW で確保したポインターのみ SDL_FreeRW で開放できる。
        def release(ptr) = ::SDL2.SDL_FreeRW(ptr)
      end
    end

    class << self
      # obj は Ruby IO と同じようにふるまうことを期待している。
      # obj に対して close, seek, size, read, write のメソッドを呼び出す。
      # メソッドの呼び出し引数は Ruby IO と同様である。
      # メソッドの戻り値は Ruby IO と同じ値を返せばよい。
      # メソッド内での例外は SDL のエラーに変換され、Ruby 側には反映されない。
      # obj がメソッド呼び出しに応答しない場合も安全である。その場合は SDL 側にエラーが通知される。
      def new(io)
        ptr = RWopsPointer.new(::SDL2.SDL_AllocRW)
        raise RbSDL2Error if ptr.null?
        super(ptr, io)
      end
    end

    def initialize(ptr, obj)
      st = ::SDL2::SDL_RWops.new(ptr)
      st[:close] = @close = CloseCallback.new(obj)
      st[:read]  = @read  = ReadCallback.new(obj)
      st[:seek]  = @seek  = SeekCallback.new(obj)
      st[:size]  = @size  = SizeCallback.new(obj)
      st[:write] = @write = WriteCallback.new(obj)
      @obj = obj
      @ptr = ptr
    end

    def __getobj__ = @obj

    def to_ptr = @ptr
  end
end
