module RbSDL2
  class Event
    class EventFilter < ::FFI::Function
      class << self
        # SDL にフィルターコールバック関数が設定されている場合に true を戻す。
        def filter_callback_defined?
          _func_userdata = Array.new(2) { ::FFI::MemoryPointer.new(:pointer) }
          # GetEventFilter はコールバックのポインター関数が NULL の場合に FALSE となる。
          # userdata ポインターが設定されていても GetEventFilter の戻り値に関与しない。
          ::SDL.GetEventFilter(*_func_userdata) == ::SDL::TRUE
        end
      end

      @watch_set = []
      @watch_mutex = Mutex.new

      class << self
        def add_watch(proc)
          @watch_mutex.synchronize do
            raise ArgumentError if @watch_set.assoc(proc)
            func = new(&proc)
            ::SDL.AddEventWatch(func, nil)
            @watch_set << [proc, func]
          end
          proc
        end

        def remove_watch(proc)
          @watch_mutex.synchronize do
            idx = @watch_set.assoc(proc)
            if idx
              _, func = @watch_set.delete_at(idx)
              ::SDL.DelEventWatch(func, nil)
            end
          end
          proc
        end
      end

      # コールバックへはコピーされたイベントが与えられる。
      def initialize
        # typedef int (SDLCALL * EventFilter) (void *userdata, Event * event);
        super(:int, [:pointer, :pointer]) { |_, ptr| yield(Event.to_ptr(ptr)) ? 1 : 0 }
      end
    end
  end
end
