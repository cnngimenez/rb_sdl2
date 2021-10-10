module RbSDL2
  class RWOps
    class Releaser < ::FFI::AutoPointer
      class << self
        def release(ptr)
          # SDL_RWclose は RWOps構造体を開放する。そのため呼び出しは1回しかできない。
          # ::FFI::AutoPointer を使うことで2重開放を防ぐ。
          raise RbSDL2Error if ::SDL2.SDL_RWclose(ptr) < 0
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
                ::SDL2.SDL_RWFromConstMem(mem, size)
              else
                ::SDL2.SDL_RWFromMem(mem, size)
              end
        raise RbSDL2Error if ptr.null?
        obj = allocate
        obj.__send__(:initialize, ptr, mem, autoclose: autoclose)
      end

      # mode は一般的なファイルAPIと同じ文字列が使用できる。
      def new(file, _mode = "rb", autoclose: true, mode: _mode)
        ptr = ::SDL2.SDL_RWFromFile(file.to_s, mode)
        raise RbSDL2Error if ptr.null?
        obj = super(ptr, autoclose: autoclose)
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

      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, ptr, autoclose: false)
        obj
      end

      require_relative 'rw_ops/rw_operator'

      def with_object(obj)
        rw = RWOperator.new(obj)
        obj = allocate
        obj.__send__(:initialize, rw.to_ptr, rw, autoclose: false)
      end
    end

    def initialize(ptr, obj = nil, autoclose:)
      @obj = obj
      @ptr = Releaser.new(ptr)
      self.autoclose = autoclose
    end

    def autoclose=(bool)
      @ptr.autorelease = bool
    end

    def autoclose? = @ptr.autorelease

    def close = @ptr.free

    def closed? = @ptr.released?

    def read(length = nil)
      raise IOError if closed?
      len = length.nil? ? size : length.to_i
      raise ArgumentError if len < 0
      return "" if len == 0
      ptr = ::FFI::MemoryPointer.new(len)
      num = ::SDL2.SDL_RWread(self, ptr, 1, len)
      raise RbSDL2Error if num == 0
      ptr.read_bytes(num)
    end

    def seek(offset, whence = IO::SEEK_SET)
      raise IOError if closed?
      raise RbSDL2Error if ::SDL2.SDL_RWseek(self, offset, whence) == -1
      0
    end

    def size
      raise IOError if closed?
      num = ::SDL2.SDL_RWsize(self)
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
        num = ::SDL2.SDL_RWwrite(self, ptr, 1, len)
        raise RbSDL2Error if num < len
        sum + len
      end
    end
  end
end
