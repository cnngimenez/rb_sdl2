module RbSDL2
  require_relative 'rw_ops_pointer'

  class RWFile < RWOps
    def initialize(path, mode = "r")
      @path = path
      ptr = ::SDL.RWFromFile(SDL.str_to_sdl(path), SDL.str_to_sdl(mode))
      raise RbSDL2Error if ptr.null?
      super(RWOpsPointer.new(ptr))
    end

    def inspect
      "#<#{self.class.name}:#{path}#{closed? ? " (closed)" : nil}>"
    end

    attr_reader :path
    alias to_path path
  end
end
