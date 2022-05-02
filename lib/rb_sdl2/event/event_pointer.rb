module RbSDL2
  class EventPointer < ::FFI::MemoryPointer
    class << self
      def copy(ptr)
        obj = malloc
        ::SDL.memcpy(obj, ptr, size)
        type = obj.type
        if ::SDL::DROPFILE == type || ::SDL::DROPTEXT == type
          ref = obj + ::SDL::DropEvent.offset_of(:file)
          str = ::SDL.strdup(ref.read_pointer)
          raise NoMemoryError if str.null?
          ref.write_pointer(str)
        end
        obj
      end

      def malloc = new(0)

      def new(type) = super(size).write_uint32(type)

      def size = ::SDL::Event.size
    end

    def type = read_uint32
  end
end
