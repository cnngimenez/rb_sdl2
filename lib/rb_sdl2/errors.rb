module RbSDL2
  class RbSDL2Error < StandardError
    def initialize(error_message = nil)
      if error_message.nil? && (msg = Error.last_error_message).empty?
        super
      else
        super(error_message || msg)
      end
    end
  end
end
