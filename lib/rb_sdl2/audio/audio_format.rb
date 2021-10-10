module RbSDL2
  class Audio
    module AudioFormat
      class << self
        def to_num(signed: true, big_endian: false, bit_size: 16, float: false)
          num = 0 |
            (big_endian ? ::SDL2::SDL_AUDIO_MASK_ENDIAN : 0) |
            (bit_size & ::SDL2::SDL_AUDIO_MASK_BITSIZE) |
            (signed ? ::SDL2::SDL_AUDIO_MASK_SIGNED : 0)
          num | (float ? ::SDL2::SDL_AUDIO_MASK_DATATYPE & ::SDL2::SDL_AUDIO_MASK_SIGNED : 0)
        end
      end

      def big_endian? = ::SDL2::SDL_AUDIO_MASK_ENDIAN & format != 0

      def bit_size = ::SDL2::SDL_AUDIO_MASK_BITSIZE & format

      def float? = ::SDL2::SDL_AUDIO_MASK_DATATYPE & format != 0

      def signed? = ::SDL2::SDL_AUDIO_MASK_SIGNED & format != 0
    end
  end
end
