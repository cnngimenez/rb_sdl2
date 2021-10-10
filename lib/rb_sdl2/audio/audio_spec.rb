module RbSDL2
  class Audio
    class AudioSpec
      require_relative 'audio_format'

      def initialize(channels: 0, format: 0, freq: 0, frequency: freq, samples: 0)
        @st = ::SDL2::SDL_AudioSpec.new
        @st[:channels] = channels
        @st[:format] = format
        @st[:freq] = frequency
        @st[:samples] = samples
      end

      def size = @st[:size]
      alias chunk_size size

      def channels = @st[:channels]

      def format = @st[:format]

      def freq = @st[:freq]
      alias frequency freq

      def samples = @st[:samples]

      def to_ptr = @st.to_ptr
    end
  end
end
