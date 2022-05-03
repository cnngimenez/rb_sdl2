module RbSDL2
  class RefCountPointer < ::FFI::AutoPointer
    # 備考：SDL では参照カウンターを操作する際にロックを行っていない。
    # SDL_AtomicAdd() を使用した理由はオブジェクトの生成をなるべく行わないようにするため。
    class << self
      def entity_class = raise NotImplementedError

      def offset_of_refcount = entity_class.offset_of(:refcount)

      def dec_ref(ptr) = ::SDL.SDL_AtomicAdd(ptr + offset_of_refcount, -1)

      def inc_ref(ptr) = ::SDL.SDL_AtomicAdd(ptr + offset_of_refcount, 1)

      def to_ptr(ptr)
        obj = new(ptr)

        # ポインターの参照カウントを増加する際に例外が発生すると、
        # ポインターが GC に回収され refcount が実際の参照数より少なくなる。
        # 例外を補足してポインターのファイナライザーを解除する。
        unless ptr.null?
          begin
            inc_ref(ptr)
          rescue => e
            obj.autorelease = false
            raise e
          end
        end

        obj
      end
    end

    def refcount = get_int(self.class.offset_of_refcount)
  end
end
