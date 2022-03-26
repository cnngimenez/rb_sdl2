module RbSDL2
  class Audio
    module AudioAllowedChanges
      class << self
        def to_num(any_change: false, channels_change: false, format_change: false,
                   frequency_change: false, samples_change: false)
          0 |
            (any_change ? ::SDL::AUDIO_ALLOW_ANY_CHANGE : 0) |
            (channels_change ? ::SDL::AUDIO_ALLOW_CHANNELS_CHANGE : 0) |
            (format_change ? ::SDL::AUDIO_ALLOW_FORMAT_CHANGE : 0) |
            (frequency_change ? ::SDL::AUDIO_ALLOW_FREQUENCY_CHANGE : 0) |
            (samples_change ? ::SDL::AUDIO_ALLOW_SAMPLES_CHANGE : 0)
        end
      end
    end
  end
end
