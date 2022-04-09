module RbSDL2
  require_relative 'rw_ops_pointer'
  
  class RWMemory < RWOps
    def initialize(obj, readonly: false, size: nil)
      raise TypeError, "obj is NULL" if obj.nil? || obj.null?
      size = size || obj.size
      ptr = readonly ? ::SDL.RWFromConstMem(obj, size) : ::SDL.RWFromMem(obj, size)
      raise RbSDL2Error if ptr.null?
      super(RWOpsPointer.new(ptr))
      @obj = obj
    end

    def inspect
      "#<#{self.class.name}:memory#{closed? ? " (closed)" : nil}>"
    end
  end
end
