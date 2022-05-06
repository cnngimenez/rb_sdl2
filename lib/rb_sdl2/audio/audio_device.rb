module RbSDL2
  class Audio
    class AudioDevice
      class << self
        def devices(capture = false)
          ::SDL.GetNumAudioDevices(IS_CAPTURE.(capture)).times.map { |num| new(num, capture) }
        end
      end

      def initialize(num, capture)
        is_capture = IS_CAPTURE.(capture)
        ptr = ::SDL.GetAudioDeviceName(num, is_capture)
        raise RbSDL2Error if ptr.null?

        spec = AudioSpec.new
        # GetAudioDeviceSpec は GetNumAudioDevices の最新の呼び出しを反映する。
        err = ::SDL.GetAudioDeviceSpec(num, is_capture, spec)
        raise RbSDL2Error if err != 0

        @capture = capture ? true : false
        @name = SDL.ptr_to_str(ptr)
        @spec = spec
      end

      def capture? = @capture

      attr_reader :name
      alias to_s name

      attr_reader :spec

      require_relative 'audio_spec_reader'
      include AudioSpecReader

      def unknown? = spec.unknown?
    end
  end
end
