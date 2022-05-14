module RbSDL2
  class Event
    class Queue
      require_relative 'event'
      require_relative 'event_pointer'
      require_relative 'event_type'

      SDL_ADDEVENT  = 0
      SDL_PEEKEVENT = 1
      SDL_GETEVENT  = 2

      # Thread::SizedQueue のように振る舞う。
      def initialize(type = nil)
        @min_type, @max_type = EventType.to_types(type)
      end

      attr_reader :min_type, :max_type

      EXT_FREE_EVENTS = [
        [::SDL::TEXTEDITING_EXT, ::SDL::TextEditingExtEvent.offset_of(:text)],
        [::SDL::DROPFILE, ::SDL::DropEvent.offset_of(:file)],
        [::SDL::DROPTEXT, ::SDL::DropEvent.offset_of(:file)],
      ].map(&:freeze).freeze

      def clear
        # SDL_FlushEvents() は SDL_DROPFILE, SDL_DROPTEXT の場合は file メンバーのポインター、
        # SDL_TEXTEDITING_EXT の場合は text メンバーのポインターを開放しない。
        # そのため Ruby 側でポインターの開放を行う。
        ptr = EventPointer.malloc
        EXT_FREE_EVENTS.
          filter { |type, _| min_type <= type || type <= max_type }.
          each do |type, offset|
          ref_ptr = ptr + offset
          ::SDL.free(ref_ptr) while ::SDL.PeepEvents(ptr, 1, SDL_GETEVENT, type, type) > 0
        end

        ::SDL.FlushEvents(min_type, max_type)
      end

      def length
        # SDL_PeepEvents に SDL_PEEKEVENT を与えた時のエラー条件
        # - イベントシステムがシャットダウンしている場合。
        # - イベントキューのロックが取得できない場合。
        num = ::SDL.PeepEvents(nil, 0, SDL_PEEKEVENT, min_type, max_type)
        raise RbSDL2Error if num < 0
        num
      end
      alias size length

      def empty? = ::SDL.HasEvents(min_type, max_type) != ::SDL::TRUE

      # 戻り値は不定（定義なし）
      def push(event, non_block = false)
        # SDL_PeepEvents に SDL_ADDEVENT を与えた時ののエラー条件
        # - イベントシステムがシャットダウンしている場合。
        # - イベントキューのロックが取得できない場合。
        # 以下の条件の場合はエラーではなく 0 が戻る。
        # - イベントキューのイベント数が上限に達した場合。
        # - イベントキューが追加のメモリーが確保できない場合。
        ptr = EventPointer.copy(event.to_ptr)
        while ::SDL.PeepEvents(ptr, 1, SDL_ADDEVENT, min_type, max_type) <= 0
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
        while ::SDL.PeepEvents(ptr, 1, SDL_GETEVENT, min_type, max_type) <= 0
          raise RbSDL2Error if non_block
        end
        Event.to_ptr(ptr)
      end
      alias deq pop
      alias shift pop
    end
  end
end
