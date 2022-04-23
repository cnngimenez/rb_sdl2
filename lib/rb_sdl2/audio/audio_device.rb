module RbSDL2
  class Audio
    class AudioDevice
      class << self
        def devices(capture = false)
          is_capture = IS_CAPTURE.(capture)
          ::SDL.GetNumAudioDevices(is_capture).times.map do |num|
            ptr = ::SDL.GetAudioDeviceName(num, is_capture)
            raise RbSDL2Error if ptr.null?

            spec = AudioSpec.new
            # GetAudioDeviceSpec は GetNumAudioDevices の最新の呼び出しを反映する。
            err = ::SDL.GetAudioDeviceSpec(num, is_capture, spec)
            raise RbSDL2Error if err != 0

            new(SDL.ptr_to_str(ptr), capture, spec)
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
