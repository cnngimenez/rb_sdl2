module RbSDL2
  class Event
    # SDL_SYSWMEVENT の msg メンバーの実装はしない。
    # msg ポインターが指す SDL_SysWMmsg は構造体サイズが環境に依存するためコピーを行うことができない。
    # SDL_SYSWMEVENT イベントの作成はできない、受け取りはできるが msg メンバーへのアクセスはできない。
    # SDL は SDL_SYSWMEVENT にある SDL_SysWMmsg をマネージしている。
    # イベントへの追加ではコピーを行い、取り出しの際にはテンポラリ領域へコピーしてからアプリケーションへ渡す。
    # アプリケーションが SDL_SYSWMEVENT を無視してもメモリーリークはしない。

    require 'forwardable'
    extend SingleForwardable

    require_relative 'event_filter'
    def_single_delegators EventFilter, *%i(define_watch filter_callback_defined? undefine_watch)

    require_relative 'pump'
    def_single_delegators Pump, *%i(poll pump wait)

    require_relative 'queue'

    class << self
      def clear = Queue.new.clear

      def count = Queue.new.size

      def exist?(type = nil) = !Queue.new(type).empty?

      def quit?
        pump
        exist?(::SDL::QUIT)
      end
    end

    require_relative 'event_type'
    def_single_delegators EventType, *%i(disable enable ignore? register_events)

    include EventType

    require_relative 'event_pointer'

    class << self
      def new(type:, **members)
        obj = super(EventPointer.new(type))
        members.each_pair { |sym, val| obj[sym] = val }
        obj
      end

      def to_ptr(ptr)
        obj = allocate
        obj.__send__(:initialize, ptr)
        obj
      end
    end

    def initialize(ptr)
      @ptr = ptr
      @entity = nil
      @obj = if drop_file? || drop_text?
               SDLPointer.new(entity[:file])
             elsif text_editing_ext?
               SDLPointer.new(entity[:text])
             elsif sys_wm_event? && entity[:msg].null?
               # msg に NULL があると SDL はこのポインターをチェックせずに読み出す。
               raise TypeError
             end
    end

    # SDL_SYSWMEVENT の msg はポインターです。このポインターの取り扱いはアプリケーションに委ねられます。
    # SDL_USEREVENT の data1, data2 はポインターです。このポインターの取り扱いはアプリケーションに委ねられます。
    def [](sym)
      obj = entity[sym]
      case sym
      when :data   then obj.to_a
      when :file   then if drop_file? || drop_text?
                          SDL.ptr_to_str(obj)
                        else
                          # SDL_EVENTBEGIN, SDL_DROPCOMPLETE はこのメンバー使用しない。
                          nil
                        end
      when :keysym then { scancode: obj[:scancode], sym: obj[:sym], mod: obj[:mod] }
      when :msg    then obj
      when :text   then SDL.ptr_to_str(obj.to_ptr)
      when :type   then type
      else obj
      end
    end

    # SDL_SYSWMEVENT の msg への書き込みはできません。
    # SDL_USEREVENT の data1, data2 はポインターです。このポインターの取り扱いはアプリケーションに委ねられます。
    def []=(sym, val)
      raise FrozenError if frozen?

      case sym
      when :data   then entity[sym].tap { |st| val.each.with_index { |v, i| st[i] = v } }
      when :file   then if drop_file? || drop_text?
                          entity[sym] = @obj = SDLPointer.from_string(val)
                        else
                          # SDL_EVENTBEGIN, SDL_DROPCOMPLETE はこのメンバー使用しない。
                          raise TypeError
                        end
      when :keysym then entity[sym].tap { |st| val.each { |k, v| st[k] = v } }
      when :msg    then raise NotImplementedError
      when :text   then if text_editing_ext?
                          entity[sym] = @obj = SDLPointer.from_string(val)
                        else
                          ::SDL.utf8strlcpy(entity[sym].to_ptr, SDL.str_to_sdl(val), entity[sym].size)
                        end
      when :type   then raise TypeError
      else entity[sym] = val
      end
    end

    private def entity = @entity ||= EventType::ENTITY_MAP[type].new(@ptr)

    # clone, dup はディープコピーを行います。
    def initialize_copy(obj)
      super
      initialize(EventPointer.copy(obj.to_ptr))
    end

    def inspect = "#<#{self.class.name}: #{name}>"

    def member?(name) = members.include?(name)

    def members = entity.members.grep_v(/\Apadding/)

    def name = EventType.to_name(type)

    def to_h = members.map { |sym| [sym, self[sym]] }.to_h

    def to_ptr = @ptr

    def to_s = name.to_s

    def type = @ptr.type
    alias to_i type
  end
end
