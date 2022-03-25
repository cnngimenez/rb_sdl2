module RbSDL2
  class Event
    class EventFilter < ::FFI::Function
      class << self
        # SDL にフィルターコールバック関数が設定されている場合に true を戻す。
        def filter_callback_defined?
          _func_userdata = Array.new(2) { ::FFI::MemoryPointer.new(:pointer) }
          # SDL_GetEventFilter はコールバックのポインター関数が NULL の場合に SDL_FALSE となる。
          # userdata ポインターが設定されていても SDL_GetEventFilter の戻り値に関与しない。
          ::SDL2.SDL_GetEventFilter(*_func_userdata) == ::SDL2::SDL_TRUE
        end
      end

      @watch_set = []
      @watch_mutex = Mutex.new

      class << self
        def add_watch(proc)
          @watch_mutex.synchronize do
            raise ArgumentError if @watch_set.assoc(proc)
            func = new(&proc)
            ::SDL2.SDL_AddEventWatch(func, nil)
            @watch_set << [proc, func]
          end
          proc
        end

        def remove_watch(proc)
          @watch_mutex.synchronize do
            idx = @watch_set.assoc(proc)
            if idx
              _, func = @watch_set.delete_at(idx)
              ::SDL2.SDL_DelEventWatch(func, nil)
            end
          end
          proc
        end
      end

      # コールバックへはコピーされたイベントが与えられる。
      def initialize
        # typedef int (SDLCALL * SDL_EventFilter) (void *userdata, SDL_Event * event);
        super(:int, [:pointer, :pointer]) { |_, ptr| yield(Event.to_ptr(ptr)) ? 1 : 0 }
      end
    end
  end
end
