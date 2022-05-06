module RbSDL2
  class Audio
    class AudioSpec
      SDL_AUDIO_MASK_BITSIZE  = 0xFF
      SDL_AUDIO_MASK_DATATYPE = 1 << 8
      SDL_AUDIO_MASK_ENDIAN   = 1 << 12
      SDL_AUDIO_MASK_SIGNED   = 1 << 15

      def initialize(big_endian: false, bit_size: 16, float: false, signed: true,
                     channels: 0, format: nil, frequency: 0, samples: 0)
        @st = ::SDL::AudioSpec.new
        @st[:channels] = channels
        @st[:format] = format || 0 |
          (big_endian ? SDL_AUDIO_MASK_ENDIAN : 0) |
          (bit_size & SDL_AUDIO_MASK_BITSIZE) |
          (float ? SDL_AUDIO_MASK_DATATYPE & SDL_AUDIO_MASK_SIGNED : 0) |
          (signed ? SDL_AUDIO_MASK_SIGNED : 0)
        @st[:freq] = frequency
        @st[:samples] = samples
      end

      def big_endian? = SDL_AUDIO_MASK_ENDIAN & format != 0

      def bitsize = SDL_AUDIO_MASK_BITSIZE & format

      # チャンネル数
      def channels = @st[:channels]

      def float? = SDL_AUDIO_MASK_DATATYPE & format != 0

      # 音声フォーマット
      def format = @st[:format]

      # サンプルレート
      def freq = @st[:freq]
      alias frequency freq

      # 音声バッファのサンプル数。２のべき乗。
      def samples = @st[:samples]

      def signed? = SDL_AUDIO_MASK_SIGNED & format != 0

      # 音量レベル０の値。8ビットフォーマットの際に使用する（と思われる。型が Uint8 であるため）。SDL が決定する。
      def silence = @st[:silence]

      # 音声バッファのサイズ（Byte）。SDL が決定する。
      def size = @st[:size]

      def to_ptr = @st.to_ptr

      def unknown? = channels == 0 && format == 0 && frequency == 0
    end
  end
end
