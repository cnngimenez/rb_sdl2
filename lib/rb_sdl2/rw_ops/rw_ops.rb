module RbSDL2
  require_relative 'rw_file'
  require_relative 'rw_memory'
  require_relative 'rw_object'

  class RWOps
    class << self
      def open(...)
        rw = new(...)
        return rw unless block_given?
        begin
          yield(rw)
        ensure
          rw.close
        end
      end

      alias to_ptr new
    end

    def initialize(ptr)
      @ptr = ptr
    end

    # close 呼び出しの結果によらずポインターは開放されます。
    # 継承先のクラスは close をオーバーライドしてポインターを適切に扱う必要があります。
    def close
      # SDL_RWclose は必ずポインターを開放する。二重開放を防ぐ。
      unless closed?
        # クローズ処理は @ptr 先にあるメンバーの close 関数内あるため、SDL_RWclose() を呼ぶ。
        err = ::SDL.RWclose(@ptr)
        raise RbSDL2Error if err < 0
      end
    rescue => e
      # Ruby IO と同じように例外を出さない。デバッグモードでは例外を出す。
      raise e if $DEBUG
    ensure
      # ポインターは開放済みのためファイナライザーを停止させる。
      @ptr.autorelease = false
      @ptr = nil
    end

    def closed?
      # @ptr があるのに autorelease? が false の場合はポインターが Ruby の外に渡されているだろう。
      # この場合をクローズされたと判断する。
      !@ptr&.autorelease?
    end

    def pos=(n)
      seek(n, IO::SEEK_SET)
    end

    def read(length = nil)
      raise IOError if closed?
      len = length.nil? ? size - tell : length
      raise ArgumentError if len < 0
      return "" if len == 0
      ptr = ::FFI::MemoryPointer.new(len)
      num = ::SDL.RWread(@ptr, ptr, 1, len)
      raise RbSDL2Error if num == 0
      ptr.read_bytes(num)
    end

    def seek(offset, whence = IO::SEEK_SET)
      raise IOError if closed?
      raise RbSDL2Error if ::SDL.RWseek(@ptr, offset, whence) == -1
      0
    end

    def size
      raise IOError if closed?
      num = ::SDL.RWsize(@ptr)
      raise RbSDL2Error if num < 0
      num
    end

    def tell
      raise IOError if closed?
      num = ::SDL.RWtell(@ptr)
      raise RbSDL2Error if num == -1
      num
    end
    alias pos tell

    # close メソッドを呼び出した後、インスタンスからポインターを取り出すことはできません。
    def to_ptr
      raise TypeError if closed?
      @ptr
    end

    def write(*str)
      raise FrozenError if frozen?
      raise IOError if closed?
      str.inject(0) do |sum, obj|
        bytes = obj.to_s
        len = bytes.size
        ptr = ::FFI::MemoryPointer.new(len).write_bytes(bytes)
        num = ::SDL.RWwrite(@ptr, ptr, 1, len)
        raise RbSDL2Error if num < len
        sum + len
      end
    end
  end
end
