module RbSDL2
  class Event
    require 'forwardable'
    extend SingleForwardable

    require_relative 'event/event_filter'
    def_single_delegators "Event::EventFilter", *%i(add_watch filter_callback_defined? remove_watch)

    require_relative 'event/event_queue'
    def_single_delegators "Event::EventQueue",
                          *%i(clear count deq empty? enq length poll pump push quit? size wait)

    require_relative 'event/event_type'
    def_single_delegators "Event::EventType", *%i(disable enable ignore? register_events)

    include EventType

    require_relative 'event/event_pointer'

    class << self
      def malloc
        obj = allocate
        obj.__send__(:initialize, EventPointer.malloc)
        obj
      end

      def new(type:, **members)
        num = case type
              when Symbol then EventType.to_num(type)
              when Integer then type
              else raise ArgumentError
              end
        ptr = EventPointer.malloc
        ptr.write_uint32(num)
        obj = super(ptr)
        members.each_pair { |sym, val| obj[sym] = val }
        obj
      end

      # 与えられたポインター先のイベントをディープコピーしたものを戻す。
      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, EventPointer.to_ptr(ptr))
        obj
      end
    end

    def initialize(ptr)
      @ptr = ptr
    end

    def [](sym)
      case sym
      when :data then entity[:data].to_a
      when :data1, :data2
        if user_event?
          raise NotImplementedError
        else
          entity[sym]
        end
      when :file then entity[:file].then { |ptr| ptr.null? ? nil : ptr.read_string }
      when :keysym then entity[:keysym].then { |st| { scancode: st[:scancode], sym: st[:sym], mod: st[:mod] } }
      #
      # msg ポインターがイベントキュー内部を指し示している場合があるため読み出しを禁じる。
      # SDL は poll などのイベント取り出しの際にも msg は一時的なメモリーに置く。
      when msg then raise NotImplementedError
      when :text then entity[:text].to_s
      when :type then type
      else entity[sym]
      end
    end

    def []=(sym, val)
      raise FrozenError if frozen?

      case sym
      when :data then val.each.with_index { |v, i| entity[:data][i] = v }
      when :data1, :data2
        if user_event?
          raise NotImplementedError
        else
          entity[sym] = val
        end
      when :file
        if drop_file? || drop_text?
          _ptr = entity[:file]
          entity[:file] = if val.nil? || val.respond_to?(:null?) && val.null?
                            nil
                          else
                            c_str = "#{val}\x00"
                            ptr = ::SDL.malloc(c_str.size)
                            raise NoMemoryError if ptr.null?
                            ptr.write_bytes(c_str)
                          end
          ::SDL.free(_ptr)
        else
          raise ArgumentError
        end
      when :keysym then val.each { |k, v| entity[:keysym][k] = v }
      #
      # msg ポインターがイベントキュー内部を指し示している場合があるため書き込みを禁じる。
      # SDL は poll などのイベント取り出しの際にも msg を（再利用している）一時的な領域に置く。
      # NULL にすることはできない。SDL はポインター先を NULL チェックせずに読み出す。
      when :msg then raise NotImplementedError
      when :type then raise ArgumentError
      else entity[sym] = val
      end
    end

    def initialize_copy(obj)
      super
      @ptr = EventPointer.to_ptr(obj.to_ptr)
    end

    def inspect
      "#<#{self.class.name} name=#{name.inspect}>"
    end

    private def entity
      raise ArgumentError, "No event type specified" if type == 0
      @entity ||= EventType::ENTITY_MAP[type].new(@ptr)
    end

    def member?(name) = members.include?(name)

    def members = entity.members.grep_v(/\Apadding/)

    def name = EventType.to_name(type)
    alias to_s name

    def to_h = members.map { |sym| [sym, self[sym]] }.to_h

    def to_ptr = @ptr

    def type = EventPointer.to_type(@ptr)
  end
end
