module RbSDL2
  class EventQueue
    require_relative 'event'
    require_relative 'event_pointer'
    require_relative 'event_type'

    class << self
      def clear
        # SDL_FlushEvents() は SDL_DROPFILE, SDL_DROPTEXT の場合に file メンバーのポインターは開放しない。
        # そのため Ruby 側でポインターの開放を行う。
        ptr = EventPointer.malloc
        ref_ptr = ptr + ::SDL::DropEvent.offset_of(:file)
        while ::SDL.PeepEvents(ptr, 1, ::SDL::GETEVENT, ::SDL::DROPFILE, ::SDL::DROPTEXT) > 0
          ::SDL.free(ref_ptr)
        end
        ::SDL.FlushEvents(::SDL::FIRSTEVENT, ::SDL::LASTEVENT)
      end

      def count
        num = ::SDL.PeepEvents(nil, 0, ::SDL::PEEKEVENT, ::SDL::FIRSTEVENT, ::SDL::LASTEVENT)
        raise RbSDL2Error if num < 0
        num
      end

      def exist?(type = nil)
        ::SDL.HasEvents(*EventType.to_types(type)) == ::SDL::TRUE
      end

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

    # Thread::SizedQueue のように振る舞う。

    def initialize(type = nil)
      @min_type, @max_type = EventType.to_types(type)
    end

    attr_reader :min_type, :max_type

    def length
      # SDL_PeepEvents に SDL_PEEKEVENT を与えた時のエラー条件
      # - イベントシステムがシャットダウンしている場合。
      # - イベントキューのロックが取得できない場合。
      num = ::SDL.PeepEvents(nil, 0, ::SDL::PEEKEVENT, min_type, max_type)
      raise RbSDL2Error if num < 0
      num
    end
    alias size length

    def empty? = length == 0

    # 戻り値は不定（定義なし）
    def push(event, non_block = false)
      # SDL_PeepEvents に SDL_ADDEVENT を与えた時ののエラー条件
      # - イベントシステムがシャットダウンしている場合。
      # - イベントキューのロックが取得できない場合。
      # 以下の条件の場合はエラーではなく 0 が戻る。
      # - イベントキューのイベント数が上限に達した場合。
      # - イベントキューが追加のメモリーが確保できない場合。
      ptr = EventPointer.copy(event.to_ptr)
      while ::SDL.PeepEvents(ptr, 1, ::SDL::ADDEVENT, min_type, max_type) <= 0
        raise RbSDL2Error if non_block
      end
    end
    alias << push
    alias enq push

    def pop(non_block = false)
      ptr = EventPointer.malloc
      # SDL_PeepEvents に SDL_GETEVENT を与えた時ののエラー条件
      # - イベントシステムがシャットダウンしている場合。
      # - イベントキューのロックが取得できない場合。
      while ::SDL.PeepEvents(ptr, 1, ::SDL::GETEVENT, min_type, max_type) <= 0
        raise RbSDL2Error if non_block
      end
      Event.to_ptr(ptr)
    end
    alias deq pop
    alias shift pop
  end
end
