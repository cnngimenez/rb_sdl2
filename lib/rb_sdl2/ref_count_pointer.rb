module RbSDL2
  class RefCountPointer < ::FFI::AutoPointer
    class << self
      def entity_class
        raise NotImplementedError
      end

      def to_ptr(ptr)
        raise ArgumentError, 'Invalid pointer, ptr is NULL' if ptr.null?
        # refcount の増加を AutoPointer 化する前に成功させる必要がある。
        # AutoPointer になった後に失敗すると、GC に回収されたとき refcount が実際の参照数より少なくなる。
        entity_class.new(ptr)[:refcount] += 1
        new(ptr)
      end
    end

    # for debug
    def refcount = self.class.entity_class.new(self)[:refcount]
  end
end
