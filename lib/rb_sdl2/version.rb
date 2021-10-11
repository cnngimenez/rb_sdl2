module RbSDL2
  module Version
    class << self
      # SDL ライブラリのリビジョンを文字列で返します。
      def revision = ::SDL2.SDL_GetRevision.read_string

      # SDL ライブラリのバージョン番号を文字列で返します。形式はセマンティックバージョニングです。
      def version
        st = ::SDL2::SDL_version.new
        ::SDL2.SDL_GetVersion(st)
        "#{st[:major]}.#{st[:minor]}.#{st[:patch]}"
      end
    end
  end
end
