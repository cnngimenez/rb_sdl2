module RbSDL2
  class Event
    module EventQueue
      class << self
        require_relative 'event_type'

        def clear
          # type が ::SDL2::SDL_DROPFILE, ::SDL2::SDL_DROPTEXT の場合に
          # イベントに含まれる file メンバーのポインターが開放されない。そのため Ruby 側で開放処理を行う。
          event = Event.new
          while peep(event, ::SDL2::SDL_GETEVENT,
                     type: ::SDL2::SDL_DROPFILE..::SDL2::SDL_DROPTEXT) > 0
            event.clear
          end
          ::SDL2.SDL_FlushEvents(*EventType.minmax)
        end

        def count(type: nil) = peep(nil, ::SDL2::SDL_PEEKEVENT, type: type)
        alias length count
        alias size count

        def deq(non_block = false, type: nil)
          event = Event.new
          while peep(event, ::SDL2::SDL_GETEVENT, type: type) == 0
            raise ThreadError, Error.message if non_block
          end
          event
        end

        # ブロックにはイベントキューにあるイベントが渡される。
        # ブロックへ渡されるイベントはコピーされたものでありブロックの外へ持ち出すことができる。
        # このメソッドは SDL のイベントキューをロックする。
        def each = block_given? ? reject! { |event| yield(event.dup); true } : to_enum

        def empty? = length == 0

        # イベントキューが一杯の時に 例外
        def enq(event, non_block = false)
          event_copy(event) do |copy|
            while peep(copy, ::SDL2::SDL_ADDEVENT) == 0
              raise ThreadError, Error.message if non_block
            end
            event
          end
        end

        private def event_copy(event)
          copy = event.dup
          yield(copy).tap do
            # 成功した場合はメンバーポインターはキューにコピーされた。
            # ブロックの実行が成功したらメンバーポインターの開放を防ぐ。
            if event.drop_file? || event.drop_text?
              copy.to_ptr.autorelease = false
              ::SDL2.SDL_free(copy)
            end
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
                                 EventType.minmax
                               when Range
                                 type.minmax
                               else
                                 [type, type]
                               end
          num = ::SDL2.SDL_PeepEvents(event, event ? 1 : 0, action, min_type, max_type)
          raise RbSDL2Error if num < 0
          num
        end

        def poll
          main_thread!
          event = Event.new
          ::SDL2::SDL_PollEvent(event).nonzero? && event
        end
        alias get poll

        def pump
          main_thread!
          ::SDL2.SDL_PumpEvents
        end

        # イベントをキューに入れる。enq との違いは push ではイベントコールバックを起動する。
        # イベントがキューに入った場合は引数のイベントを戻す。フィルターされた場合は nil を戻す。
        # キューに入れることを失敗したら例外が発生する。
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

        require_relative 'event_filter'

        # ブロックへ与えられたイベントは外に持ち出すことはできない。
        # このメソッドは SDL のイベントキューをロックする。
        # ブロックの戻り値が false の場合、イベントはキューから取り除かれる。
        # userdata に渡されたオブジェクトはポインターに変換可能なものである必要がある。
        def reject!(userdata = nil)
          func = EventFilter.new { |event| yield(event) || (event.clear; nil) }
          ::SDL2.SDL_FilterEvents(func, userdata)
        end

        def wait(sec = nil)
          main_thread!
          event = Event.new
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
