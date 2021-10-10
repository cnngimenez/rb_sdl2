module RbSDL2
  class Event
    class EventFilter < ::FFI::Function
      @filter_callback = nil, nil
      @filter_mutex = Mutex.new

      class << self
        def filter_callback_set(obj, userdata = nil)
          func = if Proc === obj
                   # イベントを削除する時にイベントメンバーのポインターを開放（Event#clear）する。
                   new { |event| obj.call(event) || (event.clear; nil) }
                 else
                   obj
                 end
          # func, userdata の対の関係を保つ。
          @filter_mutex.synchronize do
            ::SDL2.SDL_SetEventFilter(func, userdata)
            @filter_callback = [func, userdata]
          end
          [obj, userdata]
        end

        # SDL にフィルターコールバック関数が設定されている場合に true を戻す。
        def filter_callback_defined?
          _func_userdata = Array.new(2) { ::FFI::MemoryPointer.new(:pointer) }
          # SDL_GetEventFilter はコールバックのポインター関数が NULL の場合に SDL_FALSE となる。
          # userdata ポインターが設定されていても SDL_GetEventFilter の戻り値に関与しない。
          ::SDL2.SDL_GetEventFilter(*_func_userdata) == ::SDL2::SDL_TRUE
        end
      end

      @watch_callbacks = []
      @watch_mutex = Mutex.new

      class << self
        def add_watch_callback(obj, userdata = nil)
          func = if Proc === obj
                   new(&obj)
                 else
                   obj
                 end
          obj_userdata = [obj, userdata]
          @watch_mutex.synchronize do
            ::SDL2.SDL_AddEventWatch(func, userdata)
            @watch_callbacks << [obj_userdata, func]
          end
          obj_userdata
        end

        def remove_watch_callback(obj, userdata = nil)
          obj_userdata = [obj, userdata]
          @watch_mutex.synchronize do
            idx = @watch_callbacks.index { |obj| obj.first == obj_userdata }
            if idx
              _, func = @watch_callbacks.delete_at(idx)
              ::SDL2.SDL_DelEventWatch(func, userdata)
            end
          end
          obj_userdata
        end
      end

      require 'delegate'

      # 引数ブロックへはコールバック実行時に Event のインスタンス（のデリゲーター）が与えられる。
      # 与えられた Event インスタンスは引数ブロック終了後に nil に変化する(デリゲート先を変更している)。
      # SDL がイベントコールバックへ与えるイベントへのポインターがイベントキューの一部を直接指しているため
      # コールバックを抜けた後にイベント内容の永続性が保証ができない（たぶん別のイベント内容になるだろう）。
      # 引数ブロックに与えられたオブジェクトをスコープ外に持ち出しても安全である。
      # オブジェクトではなくイベントの内容をスコープ外に持ち出したい場合は
      # 与えられたオブジェクトをコピー（clone, dup）すればよい。
      def initialize
        # typedef int (SDLCALL * SDL_EventFilter) (void *userdata, SDL_Event * event);
        super(:int, [:pointer, :pointer]) do |_userdata, ptr|
          obj = SimpleDelegator.new(Event.to_ptr(ptr))
          yield(obj) ? 1 : 0
        ensure
          obj.__setobj__(nil)
        end
      end
    end
  end
end
