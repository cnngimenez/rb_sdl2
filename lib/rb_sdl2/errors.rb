module RbSDL2
  class RbSDL2Error < StandardError
    def initialize(error_message = nil)
      super(error_message || Error.last_error_message)
    end
  end
end
