module RbSDL2
  class Audio
    class AudioDevice
      class << self
        def devices(capture = false)
          is_capture = IS_CAPTURE.(capture)
          ::SDL2.SDL_GetNumAudioDevices(is_capture).times.map do |num|
            ptr = ::SDL2.SDL_GetAudioDeviceName(num, is_capture)
            raise RbSDL2Error if ptr.null?

            spec = AudioSpec.new
            # SDL_GetAudioDeviceSpec は SDL_GetNumAudioDevices の最新の呼び出しを反映する。
            err = ::SDL2.SDL_GetAudioDeviceSpec(num, is_capture, spec)
            raise RbSDL2Error if err != 0

            new(ptr.read_string.force_encoding(Encoding::UTF_8), capture, spec)
          end
        end
      end

      def initialize(name, capture, spec)
        @capture = CAPTURE.(capture)
        @name = name
        @spec = spec
      end

      attr_reader :capture

      attr_reader :name
      alias to_s name

      attr_reader :spec

      require 'forwardable'
      extend Forwardable
      def_delegators :spec, *%i(channels format frequency)

      require_relative 'audio_format'
      include AudioFormat

      def unknown? = channels == 0 && format == 0 && frequency == 0
    end
  end
end
