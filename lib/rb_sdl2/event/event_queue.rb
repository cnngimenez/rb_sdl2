module RbSDL2
  class Event
    module EventQueue
      class << self
        require_relative 'event_type'

        def clear
          # type が ::SDL2::SDL_DROPFILE, ::SDL2::SDL_DROPTEXT の場合に
          # イベントに含まれる file メンバーのポインターが開放されない。そのため Ruby 側で開放処理を行う。
          ptr = ::SDL2::SDL_Event.new[:drop]
          while peep(ptr, ::SDL2::SDL_GETEVENT, type: ::SDL2::SDL_DROPFILE..::SDL2::SDL_DROPTEXT) > 0
            ::SDL2::SDL_free(ptr[:file])
          end
          ::SDL2.SDL_FlushEvents(::SDL2::SDL_FIRSTEVENT, ::SDL2::SDL_LASTEVENT)
        end

        def count = peep(nil, ::SDL2::SDL_PEEKEVENT)
        alias length count
        alias size count

        def deq(non_block = false, type: nil)
          event = Event.malloc
          raise RbSDL2Error if non_block while peep(event, ::SDL2::SDL_GETEVENT, type: type) == 0
          event
        end

        def empty? = length == 0

        # non_block に true を与えると、イベントキューが一杯の時に例外が発生する。
        def enq(event, non_block = false)
          event_copy(event) do |copy|
            raise RbSDL2Error if non_block while peep(copy, ::SDL2::SDL_ADDEVENT) == 0
          end
          event
        end

        private def event_copy(event)
          # SysWMMsg の場合は SDL が内容コピーする。イベントのコピーを行う必要はない。
          if event.drop_file? || event.drop_text?
            copy = event.dup
            yield(copy).tap { copy.to_ptr.__free__ }
          else
            yield(event)
          end
        end

        private def main_thread!
          if Thread.main != Thread.current
            raise ThreadError, "the current thread is not the main thread"
          end
        end

        private def peep(event, action, type: nil)
          min_type, max_type = case type
                               when nil
                                 [::SDL2::SDL_FIRSTEVENT, ::SDL2::SDL_LASTEVENT]
                               when Range
                                 type.minmax.
                                   map { |obj| Symbol === obj ? EventType.to_num[obj] : obj }
                               when Symbol
                                 num = EventType.to_num[type]
                                 [num, num]
                               else
                                 [type, type]
                               end
          num = ::SDL2.SDL_PeepEvents(event, event ? 1 : 0, action, min_type, max_type)
          raise RbSDL2Error if num < 0
          num
        end

        def poll
          main_thread!
          event = Event.malloc
          ::SDL2::SDL_PollEvent(event).nonzero? && event
        end

        def pump
          main_thread!
          ::SDL2.SDL_PumpEvents
        end

        # イベントをキューに入れる。enq との違いは push ではイベントコールバックを起動する。
        # 成功した場合は引数のイベントを戻す。フィルターされた場合は nil を戻す。
        # キューに入れることが失敗したら例外が発生する。
        def push(event)
          event_copy(event) do |copy|
            num = ::SDL2.SDL_PushEvent(copy)
            if num > 0
              event
            elsif num == 0
              nil
            else
              raise RbSDL2Error
            end
          end
        end

        def quit?
          pump
          ::SDL2.SDL_HasEvent(::SDL2::SDL_QUIT) == ::SDL2::SDL_TRUE
        end

        def wait(sec = nil)
          main_thread!
          event = Event.malloc
          if sec.nil?
            ::SDL2::SDL_WaitEvent(event).nonzero? && event
          elsif sec >= 0
            ::SDL2::SDL_WaitEventTimeout(event, sec * 1000).nonzero? && event
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
