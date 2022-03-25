module RbSDL2
  class Event
    # 全てのイベントポインターはディープコピーされる。
    # ディープコピーを定義できない UserEvent はメンバーのポインターへのアクセスを禁じる。
    # EventPointer が SDL側にあるアドレスを持つことはない。
    class EventPointer < ::FFI::AutoPointer
      class << self
        def malloc
          ptr = new(::SDL2.SDL_calloc(1, ::SDL2::SDL_Event.size))
          raise NoMemoryError if ptr.null?
          ptr
        end

        def release(ptr)
          type = to_type(ptr)
          if ::SDL2::SDL_DROPFILE == type || ::SDL2::SDL_DROPTEXT == type
            st = ::SDL2::SDL_DropEvent.new(ptr)
            ::SDL2.SDL_free(st[:file])
            st[:file] = nil
          end
          ::SDL2.SDL_free(ptr)
        end

        def to_ptr(ptr)
          dst = malloc.write_bytes(ptr.read_bytes(::SDL2::SDL_Event.size))
          type = to_type(dst)
          if ::SDL2::SDL_DROPFILE == type || ::SDL2::SDL_DROPTEXT == type
            st = ::SDL2::SDL_DropEvent.new(dst)
            unless st[:file].null?
              c_str = "#{st[:file].read_string}\x00"
              ptr = ::SDL2.SDL_malloc(c_str.size)
              raise NoMemoryError if ptr.null?
              ptr.write_bytes(c_str)
            end
          end

          dst
        end

        def to_type(ptr) = ptr.read_uint32
      end

      # メンバーのポインター先を開放しない。このメソッドは EventQueue の enq, push で使用する。
      def __free__
        self.autorelease = false
        ::SDL2.SDL_free(self)
      end
    end
  end
end
