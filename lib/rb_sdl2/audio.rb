module RbSDL2
  class Audio
    IS_CAPTURE = -> (capture) { capture ? 1 : 0 }
    CAPTURE = -> (capture) { capture ? true : false }
    # AudioStream, AudioCallback の実装は行っていない。
    # AudioCallback は Ruby 側からまともに使う方法がない。
    # AudioStream はリアルタイムなリサンプラー、リフォーマッターとして使えるがこれが本当に必要か判らない。
    class << self
      def current
        ptr = ::SDL2.SDL_GetCurrentAudioDriver
        raise RbSDL2Error, "Audio subsystem has not been initialized" if ptr.null?
        ptr.read_string
      end

      require_relative 'audio/audio_device'

      def devices = AudioDevice.devices

      def drivers
        ::SDL2.SDL_GetNumAudioDrivers.times.map do |num|
          ptr = ::SDL2.SDL_GetAudioDriver(num)
          raise RbSDL2Error if ptr.null?
          ptr.read_string
        end
      end

      def init(driver)
        raise RbSDL2Error if ::SDL2.SDL_AudioInit(driver) < 0
      end

      require_relative 'audio/audio_buffer'

      def load(...) = AudioBuffer.load(...)

      require_relative 'audio/audio_allowed_changes'
      require_relative 'audio/audio_format'
      require_relative 'audio/audio_spec'

      def new(device = nil, capture = false, allowed_changes: {}, channels: 2, format: {},
              frequency: 48_000, samples: 0)
        want = AudioSpec.new(channels: channels, format: AudioFormat.to_num(**format),
                             frequency: frequency, samples: samples)
        have = AudioSpec.new
        id = ::SDL2.SDL_OpenAudioDevice(device&.to_s, IS_CAPTURE.(capture), want, have,
                                        AudioAllowedChanges.to_num(**allowed_changes))
        raise RbSDL2Error if id == 0
        super(id, capture, have)
      end
      alias open new

      def quit = ::SDL2.SDL_AudioQuit
    end

    def initialize(id, capture, spec)
      @capture = CAPTURE.(capture)
      @closed = false
      @id = id
      @spec = spec
    end

    def capture? = @capture

    def clear
      raise IOError if closed?
      ::SDL2.SDL_ClearQueuedAudio(self)
    end

    def close
      ::SDL2.SDL_CloseAudioDevice(id) unless @closed
      @closed = true
      nil
    end

    def closed? = @closed

    attr_reader :id
    alias to_int id

    def pause
      raise IOError if closed?
      ::SDL2.SDL_PauseAudioDevice(id, 1)
    end

    def play
      raise IOError if closed?
      ::SDL2.SDL_PauseAudioDevice(id, 0)
    end

    def read(len)
      raise IOError if closed?
      ptr = ::FFI::MemoryPointer.new(len)
      size = ::SDL2.SDL_DequeueAudio(id, ptr, len)
      ptr.read_bytes(size)
    end

    def size
      raise IOError if closed?
      ::SDL2.SDL_GetQueuedAudioSize(id)
    end
    alias length size

    attr_reader :spec

    require 'forwardable'
    extend Forwardable
    def_delegators :spec, *%i(channels chunk_size format frequency samples)

    require_relative 'audio/audio_format'
    include AudioFormat

    def status
      raise IOError if closed?
      ::SDL2.SDL_GetAudioDeviceStatus(id)
    end

    module AudioStatus
      def paused? = ::SDL2::SDL_AUDIO_PAUSED == status

      def playing? = ::SDL2::SDL_AUDIO_PLAYING == status

      def stopped? = ::SDL2::SDL_AUDIO_STOPPED == status
    end
    include AudioStatus

    def write(data)
      raise IOError if closed?
      err = ::SDL2.SDL_QueueAudio(id, data, data.size)
      raise RbSDL2Error if err < 0
      data.size
    end
  end
end
