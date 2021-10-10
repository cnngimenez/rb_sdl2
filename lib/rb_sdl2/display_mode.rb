module RbSDL2
  class DisplayMode
    def initialize(format: 0, h: 0, height: h, refresh_rate: 0, w: 0, width: w)
      @st = ::SDL2::SDL_DisplayMode.new
      @st[:format] = PixelFormatEnum.to_num(format)
      @st[:w] = width
      @st[:h] = height
      @st[:refresh_rate] = refresh_rate
    end

    def format = @st[:format]

    require_relative 'pixel_format_enum'
    include PixelFormatEnum

    def inspect
      "#<#{self.class.name} pixel_format_name=#{pixel_format_name} w=#{w} h=#{h}\
 refresh_rate=#{refresh_rate}>"
    end

    def width = @st[:w]

    alias w width

    def height = @st[:h]

    alias h height

    def refresh_rate = @st[:refresh_rate]

    def to_h = {format: format, w: w, h: h, refresh_rate: refresh_rate}

    def to_ptr = @st.to_ptr
  end
end
