module RbSDL2
  class EventFilter < ::FFI::Function

    class Releaser
      def initialize(obj) = @obj = obj

      def call(_id) = ::SDL.DelEventWatch(@obj, nil)
    end

    class << self
      def define_watch(func)
        ::SDL.AddEventWatch(func, nil)
        # ::FFI::Function の to_ptr が戻すオブジェクトは親オブジェクトとリンクしている。
        # ファイナライザーへ渡す際に再度ポインターを作り直して関係を切る。
        ObjectSpace.define_finalizer(func, Releaser.new(::FFI::Pointer.new(func.address)))
      end

      def undefine_watch(func)
        ::SDL.DelEventWatch(func, nil)
        ObjectSpace.undefine_finalizer(func)
      end

      # SDL にフィルターコールバック関数が設定されている場合に true を戻す。
      def filter_callback_defined?
        ::SDL.GetEventFilter(nil, nil) == ::SDL::TRUE
      end
    end

    require_relative 'event'
    require_relative 'event_pointer'

    # コールバックにはコピーしたイベントが与えられます。
    # よって SDL のイベントキューにあるイベントを書き換えることはできません。
    def initialize(proc)
      # int EventFilter(void* userdata, SDL_Event* event);
      super(:int, [:pointer, :pointer]) do |_userdata, ptr|
        # SDL のイベントキューへの参照ポインターを受け取る場合は必ずコピーを取る必要がある。
        # キューの状態は変化するため、次にアクセスする際にポインター先が存在する保証はない。
        # SDL のイベントキューを参照している間は SDL がキューをロックしているためコピーは安全にできる。
        proc.call( Event.to_ptr(EventPointer.copy(ptr)) ) ? 1 : 0
      end
    end
  end
end
