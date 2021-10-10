module RbSDL2
  class Event
    class EventPointer < ::FFI::AutoPointer
      class << self
        def malloc
          ptr = new(::SDL2.SDL_calloc(1, ::SDL2::SDL_Event.size))
          raise NoMemoryError if ptr.null?
          ptr
        end

        def release(ptr)
          # メンバーのポインターを開放する。
          Event.to_ptr(ptr).clear
          ::SDL2.SDL_free(ptr)
        end
      end
    end

    require 'forwardable'
    extend SingleForwardable

    require_relative 'event/event_filter'
    def_single_delegators "Event::EventFilter",
                          *%i(add_watch_callback filter_callback_set filter_callback_defined?
                          remove_watch_callback)

    require_relative 'event/event_queue'
    def_single_delegators "Event::EventQueue",
                          *%i(clear count deq each empty? enq get length peep poll pump push push!
                          quit? size reject! wait)

    require_relative 'event/event_type'
    def_single_delegators "Event::EventQueue", *%i(define_user_event disable enable ignore?)

    class << self
      def new(type: 0, **members)
        ptr = EventPointer.malloc
        num = Numeric === type ? type : EventType.to_num(type)
        ptr.write_uint32(num)
        obj = super(ptr)
        if obj.typed?
          members.each_pair { |sym, val| obj[sym] = val }
        end
        obj
      end

      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end
    end

    # UserEvent の data1, data2 メンバー、SysWMEvent の msg メンバーはポインターである。
    # ポインターとしての読み書きの対応はしている。しかしポインターが指し示すメモリーの管理は行わない。
    def initialize(ptr)
      @ptr = ptr
    end

    def [](sym)
      raise ArgumentError unless member?(sym)

      case sym
      when :data
        member[:data].to_a
      when :file
        member[:file].then { |ptr| ptr.null? ? nil : ptr.read_string }
      when :keysym
        member[:keysym].then { |st| {scancode: st[:scancode], sym: st[:sym], mod: st[:mod]} }
      when :text
        member[:text].to_s
      else
        member[sym]
      end
    end

    # DropEvent の file メンバーのポインターの管理は行われる。
    # UserEvent の data1, data2 メンバーと SysWMEvent の msg メンバーはポインターである。
    # これらのポインターの管理は行ない。アプリケーション側で実装を行うこと。
    def []=(sym, val)
      raise FrozenError if frozen?
      raise ArgumentError unless member?(sym)

      case sym
      when :data
        val.each.with_index { |v, i| member[:data][i] = v }
      when :file
        if drop_file? || drop_text?
          _ptr = member[:file]

          member[:file] = if val.nil?
                            nil
                          else
                            c_str = "#{val}\x00"
                            ptr = ::SDL2.SDL_malloc(c_str.size)
                            raise NoMemoryError if ptr.null?
                            ptr.write_bytes(c_str)
                          end

          ::SDL2.SDL_free(_ptr)
        else
          raise ArgumentError
        end
      when :keysym
        val.each { |k, v| member[:keysym][k] = v }
      when :msg
        if val.nil? || val.respond_to?(:null?) && val.null? || val.respond_to?(:zero?) && val.zero?
          raise ArgumentError
        end
        member[:msg] = val
      when :type
        raise ArgumentError
      else
        member[sym] = val
      end
    end

    def clear
      raise FrozenError if frozen?
      if drop_file? || drop_text?
        self[:file] = nil
      end
      member.clear
      @st = nil
      self
    end

    # deep copy を行う。
    # これは @ptr が イベントキューの一部（SDL の管理領域）を指している場合があるためである。
    def initialize_copy(obj)
      super
      @ptr = EventPointer.malloc.write_bytes(obj.to_ptr.read_bytes(::SDL2::SDL_Event.size))
      if drop_file? || drop_text?
        self[:file] = obj[:file]
      end
    end

    def inspect
      "#<#{self.class.name} ptr=#{@ptr.inspect} name=#{name.inspect} #{to_h}>"
    end

    protected def member = @st ||= ::SDL2::SDL_Event.new(@ptr)[EventType.to_type(type)]

    def member?(name) = members.include?(name)

    def members = member.members.grep_v(/\Apadding/)

    def name = EventType.to_name(type)
    alias to_s name

    def to_h = members.map { |sym| [sym, self[sym]] }.to_h

    def to_ptr = @ptr

    def type = to_ptr.read_uint32

    include EventType

    def typed? = type != 0
  end
end
