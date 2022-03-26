module RbSDL2
  class Event
    module EventQueue
      class << self
        require_relative 'event_type'

        def clear
          # type が ::SDL::DROPFILE, ::SDL::DROPTEXT の場合に
          # イベントに含まれる file メンバーのポインターが開放されない。そのため Ruby 側で開放処理を行う。
          ptr = ::SDL::Event.new[:drop]
          while peep(ptr, ::SDL::GETEVENT, type: ::SDL::DROPFILE..::SDL::DROPTEXT) > 0
            ::SDL::free(ptr[:file])
          end
          ::SDL.FlushEvents(::SDL::FIRSTEVENT, ::SDL::LASTEVENT)
        end

        def count = peep(nil, ::SDL::PEEKEVENT)
        alias length count
        alias size count

        def deq(non_block = false, type: nil)
          event = Event.malloc
          raise RbSDL2Error if non_block while peep(event, ::SDL::GETEVENT, type: type) == 0
          event
        end

        def empty? = length == 0

        # non_block に true を与えると、イベントキューが一杯の時に例外が発生する。
        def enq(event, non_block = false)
          event_copy(event) do |copy|
            raise RbSDL2Error if non_block while peep(copy, ::SDL::ADDEVENT) == 0
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
                                 [::SDL::FIRSTEVENT, ::SDL::LASTEVENT]
                               when Range
                                 type.minmax.
                                   map { |obj| Symbol === obj ? EventType.to_num[obj] : obj }
                               when Symbol
                                 num = EventType.to_num[type]
                                 [num, num]
                               else
                                 [type, type]
                               end
          num = ::SDL.PeepEvents(event, event ? 1 : 0, action, min_type, max_type)
          raise RbSDL2Error if num < 0
          num
        end

        def poll
          main_thread!
          event = Event.malloc
          ::SDL::PollEvent(event).nonzero? && event
        end

        def pump
          main_thread!
          ::SDL.PumpEvents
        end

        # イベントをキューに入れる。enq との違いは push ではイベントコールバックを起動する。
        # 成功した場合は引数のイベントを戻す。フィルターされた場合は nil を戻す。
        # キューに入れることが失敗したら例外が発生する。
        def push(event)
          event_copy(event) do |copy|
            num = ::SDL.PushEvent(copy)
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
          ::SDL.HasEvent(::SDL::QUIT) == ::SDL::TRUE
        end

        def wait(sec = nil)
          main_thread!
          event = Event.malloc
          if sec.nil?
            ::SDL::WaitEvent(event).nonzero? && event
          elsif sec >= 0
            ::SDL::WaitEventTimeout(event, sec * 1000).nonzero? && event
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
