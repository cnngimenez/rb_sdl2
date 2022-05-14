module RbSDL2
  class Event
    module Pump
      class << self
        def poll
          ptr = EventPointer.malloc
          ::SDL.PollEvent(ptr).nonzero? && Event.to_ptr(ptr)
        end

        # メインスレッドから呼び出した方が良い。
        def pump = ::SDL.PumpEvents

        # イベントをキューに入れる。enq との違いは push ではイベントコールバックを起動する。
        # 成功した場合は引数のイベントを戻す。フィルターされた場合は nil を戻す。
        # キューに入れることが失敗したら例外が発生する。
        def push!(event)
          ptr = EventPointer.copy(event.to_ptr)
          num = ::SDL.PushEvent(ptr)
          raise RbSDL2Error if num < 0
          num > 0 ? event : nil
        end

        def wait(sec = nil)
          ptr = EventPointer.malloc
          if sec.nil?
            ::SDL.WaitEvent(ptr).nonzero? && Event.to_ptr(ptr)
          elsif sec >= 0
            ::SDL.WaitEventTimeout(ptr, sec * 1000).nonzero? && Event.to_ptr(ptr)
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
