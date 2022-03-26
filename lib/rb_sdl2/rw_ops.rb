module RbSDL2
  class RWOps
    class RWOpsPointer < ::FFI::AutoPointer
      class << self
        def release(ptr)
          # RWclose は RWOps構造体を開放する。そのため呼び出しは1回しかできない。
          # ::FFI::AutoPointer を使うことで2重開放を防ぐ。
          err = ::SDL.RWclose(ptr)
          raise RbSDL2Error if err < 0
        end
      end

      def free
        @released = true
        super
      end

      def released? = @released
    end

    # マルチスレッド対応はしていない。
    # close メソッドは SDL 側からクローズされていた場合に対応していない。
    class << self
      def from_memory(mem, size, autoclose: true, readonly: true)
        ptr = if readonly
                ::SDL.RWFromConstMem(mem, size)
              else
                ::SDL.RWFromMem(mem, size)
              end
        ptr = RWOpsPointer.new(ptr)
        raise RbSDL2Error if ptr.null?
        ptr.autorelease = autoclose
        obj = allocate
        obj.__send__(:initialize, ptr, mem)
        if block_given?
          begin
            yield(obj)
          ensure
            obj.close
          end
        else
          obj
        end
      end

      # mode は一般的なファイルAPIと同じ文字列が使用できる。
      def new(file, _mode = "rb", autoclose: true, mode: _mode)
        ptr = RWOpsPointer.new(::SDL.RWFromFile(file.to_s, mode))
        raise RbSDL2Error if ptr.null?
        ptr.autorelease = autoclose
        obj = super(ptr, file)
        if block_given?
          begin
            yield(obj)
          ensure
            obj.close
          end
        else
          obj
        end
      end
      alias open new

      require_relative 'rw_ops/rw_operator'

      # io 引数には Ruby の IO オブジェクトのように振る舞うオブジェクトを与える。
      # オブジェクトは自動的にクローズされない。（close が呼ばれた場合はクローズする）
      # autoclose オプション引数に false を与えて、RWOps#to_ptr から取り出したポインターを
      # C のスコープへ渡す場合、ポインターが利用されている間 RWOps オブジェクトを生存させる必要がある。
      def with_object(io, autoclose: true)
        rw = RWOperator.new(io)
        ptr = rw.to_ptr
        ptr.autorelease = autoclose
        obj = allocate
        obj.__send__(:initialize, ptr, rw)
        if block_given?
          begin
            yield(obj)
          ensure
            obj.close
          end
        else
          obj
        end
      end
    end

    def initialize(ptr, obj = nil)
      @obj = obj
      @ptr = ptr
    end

    def autoclose=(bool)
      @ptr.autorelease = bool
    end

    def autoclose? = @ptr.autorelease?

    def close = @ptr.free

    def closed? = @ptr.released?

    def inspect
      "#<#{self.class.name}:#{@obj.inspect}>"
    end

    def read(length = nil)
      raise IOError if closed?
      len = length.nil? ? size : length.to_i
      raise ArgumentError if len < 0
      return "" if len == 0
      ptr = ::FFI::MemoryPointer.new(len)
      num = ::SDL.RWread(self, ptr, 1, len)
      raise RbSDL2Error if num == 0
      ptr.read_bytes(num)
    end

    def seek(offset, whence = IO::SEEK_SET)
      raise IOError if closed?
      raise RbSDL2Error if ::SDL.RWseek(self, offset, whence) == -1
      0
    end

    def size
      raise IOError if closed?
      num = ::SDL.RWsize(self)
      raise RbSDL2Error if num < 0
      num
    end

    def to_ptr
      raise IOError if closed?
      @ptr
    end

    def write(*str)
      raise FrozenError if frozen?
      raise IOError if closed?
      str.inject(0) do |sum, obj|
        bytes = obj.to_s
        len = bytes.size
        ptr = ::FFI::MemoryPointer.new(len).write_bytes(bytes)
        num = ::SDL.RWwrite(self, ptr, 1, len)
        raise RbSDL2Error if num < len
        sum + len
      end
    end
  end
end
