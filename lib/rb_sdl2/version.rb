module RbSDL2
  module Version
    class << self
      def revision = ::SDL2.SDL_GetRevision.read_string

      def version
        st = ::SDL2::SDL_version.new
        ::SDL2.SDL_GetVersion(st)
        "#{st[:major]}.#{st[:minor]}.#{st[:patch]}"
      end
    end
  end
end
