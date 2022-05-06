module RbSDL2
  class Audio
    SDL_AUDIO_ALLOW_FREQUENCY_CHANGE = 0x00000001
    SDL_AUDIO_ALLOW_FORMAT_CHANGE    = 0x00000002
    SDL_AUDIO_ALLOW_CHANNELS_CHANGE  = 0x00000004
    SDL_AUDIO_ALLOW_SAMPLES_CHANGE   = 0x00000008
    SDL_AUDIO_ALLOW_ANY_CHANGE = SDL_AUDIO_ALLOW_FREQUENCY_CHANGE | SDL_AUDIO_ALLOW_FORMAT_CHANGE |
      SDL_AUDIO_ALLOW_CHANNELS_CHANGE | SDL_AUDIO_ALLOW_SAMPLES_CHANGE

    SDL_AUDIO_STOPPED = 0
    SDL_AUDIO_PLAYING = 1
    SDL_AUDIO_PAUSED  = 2

    IS_CAPTURE = -> (capture) { capture ? 1 : 0 }

    class << self
      require_relative 'audio_device'

      def devices = AudioDevice.devices

      def driver
        ptr = ::SDL.GetCurrentAudioDriver
        raise RbSDL2Error, "Audio subsystem has not been initialized" if ptr.null?
        ptr.read_string
      end

      def drivers
        ::SDL.GetNumAudioDrivers.times.map do |num|
          ptr = ::SDL.GetAudioDriver(num)
          raise RbSDL2Error if ptr.null?
          ptr.read_string
        end
      end

      def init(driver)
        raise RbSDL2Error if ::SDL.AudioInit(driver) < 0
      end

      require_relative 'audio_buffer'

      def load(...) = AudioBuffer.load(...)

      def open(...)
        obj = new(...)
        return obj unless block_given?
        begin
          yield(obj)
        ensure
          obj.close
        end
      end

      def quit = ::SDL.AudioQuit
    end

    require_relative 'audio_spec'

    def initialize(device = nil, capture = false, allow_any_change: false,
                   allow_channels_change: false, allow_frequency_change: false,
                   allow_format_change: false, allow_samples_change: false,
                   autoclose: true, spec: nil, **opts)
      @capture = capture ? true : false
      @spec = AudioSpec.new
      allowed_changes = if allow_any_change
                          SDL_AUDIO_ALLOW_ANY_CHANGE
                        else
                          0 |
                            (allow_channels_change ? SDL_AUDIO_ALLOW_CHANNELS_CHANGE : 0) |
                            (allow_frequency_change ? SDL_AUDIO_ALLOW_FREQUENCY_CHANGE : 0) |
                            (allow_format_change ? SDL_AUDIO_ALLOW_FORMAT_CHANGE : 0) |
                            (allow_samples_change ? SDL_AUDIO_ALLOW_SAMPLES_CHANGE : 0)
                        end
      @id = ::SDL.OpenAudioDevice(device ? SDL.str_to_sdl(device) : nil, IS_CAPTURE.(capture),
                                  spec || AudioSpec.new(**opts), @spec, allowed_changes)
      raise RbSDL2Error if @id == 0
      self.autoclose = autoclose
    end

    class Releaser
      def initialize(num) = @id = num

      def call = ::SDL.CloseAudioDevice(@id)
    end

    def autoclose=(bool)
      return if closed?
      if bool
        ObjectSpace.define_finalizer(self, Releaser.new(@id))
      else
        ObjectSpace.undefine_finalizer(self)
      end
      @autoclose = bool ? true : false
    end

    def autoclose? = @autoclose

    def capture? = @capture

    def clear = closed? ? nil : ::SDL.ClearQueuedAudio(self)

    def close
      unless closed?
        self.autoclose = false
        @id = ::SDL.CloseAudioDevice(@id)
      end
      nil
    end

    def closed? = SDL_AUDIO_STOPPED == ::SDL.GetAudioDeviceStatus(@id) || !@id

    def id
      raise IOError if closed?
      @id
    end
    alias audio_id id

    def inspect
      "#<#{self.class.name}:#{audio_id}#{closed? ? " (closed)" : nil}>"
    end

    def pause = closed? ? nil : ::SDL.PauseAudioDevice(id, 1)

    def paused? = closed? ? false : SDL_AUDIO_PAUSED == ::SDL.GetAudioDeviceStatus(id)

    def play = closed? ? nil : ::SDL.PauseAudioDevice(id, 0)

    def playing? = closed? ? false : SDL_AUDIO_PLAYING == ::SDL.GetAudioDeviceStatus(id)

    def read(len)
      raise IOError if closed?
      ptr = ::FFI::MemoryPointer.new(len)
      size = ::SDL.DequeueAudio(id, ptr, len)
      ptr.read_bytes(size)
    end

    def size
      raise IOError if closed?
      ::SDL.GetQueuedAudioSize(id)
    end
    alias length size

    attr_reader :spec

    require_relative 'audio_spec_reader'
    include AudioSpecReader

    def write(data)
      raise IOError if closed?
      err = ::SDL.QueueAudio(id, data, data.size)
      raise RbSDL2Error if err < 0
      data.size
    end
  end
end
