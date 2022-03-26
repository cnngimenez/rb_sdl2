module RbSDL2
  class Display
    class << self
      def displays
        count = ::SDL.GetNumVideoDisplays
        raise RbSDL2Error if count < 0
        count.times.map { |num| Display.new(num) }
      end
    end

    def initialize(num)
      @num = num
    end

    def bounds
      rect = Rect.new
      err = ::SDL.GetDisplayBounds(index, rect)
      raise RbSDL2Error if err < 0
      rect.to_a
    end

    require_relative 'display_mode'

    def closest_display_mode(**display_mode)
      mode ||= DisplayMode.new(**display_mode)
      closest = DisplayMode.new
      err = ::SDL.GetClosestDisplayMode(self, mode, closest)
      raise RbSDL2Error if err.null?
      closest
      # 利用可能なディスプレイモードが検索され, 要求と最も近いモードがclosestに代入される.
      # modeのformatとrefresh_rateが0の場合, デスクトップのモードとなる.
      # モードは, サイズを最優先で検索し, ピクセル形式は次の優先度となる.
      # そして最後に更新周期をチェックする. 利用可能なモードが要求に対して小さすぎる場合, NULLを戻す.
    end

    def current_display_mode
      obj = DisplayMode.new
      err = ::SDL.GetCurrentDisplayMode(index, obj)
      raise RbSDL2Error if err < 0
      obj
    end

    def desktop_display_mode
      obj = DisplayMode.new
      err = ::SDL.GetDesktopDisplayMode(index, obj)
      raise RbSDL2Error if err < 0
      obj
    end

    def display_modes
      num = ::SDL.GetNumDisplayModes(index)
      raise RbSDL2Error if num < 0
      num.times.map do |mode_index|
        obj = DisplayMode.new
        err = ::SDL.GetDisplayMode(index, mode_index, obj)
        raise RbSDL2Error if err < 0
        obj
      end
    end

    # ディスプレイピクセルの斜め、水平、垂直方向の DPI を配列で戻す。
    def dpi
      d_h_v_dpi = Array.new(3) { ::FFI::MemoryPointer.new(:float) }
      err = ::SDL.GetDisplayDPI(index, *d_h_v_dpi)
      raise RbSDL2Error if err < 0
      d_h_v_dpi.map { |v| v.read_float }
    end

    def index = @num
    alias to_int index

    def inspect
      "#<#{self.class.name} name=#{name.inspect} bounds=#{bounds} dpi=#{dpi}>"
    end

    def name
      ptr = ::SDL.GetDisplayName(index)
      raise RbSDL2Error if ptr.null?
      ptr.read_string.force_encoding(Encoding::UTF_8)
    end
    alias to_s name

    def orientation = ::SDL.GetDisplayOrientation(index)

    module DisplayOrientation
      def flipped_landscape? = ::SDL::ORIENTATION_LANDSCAPE_FLIPPED == orientation

      def flipped_portrait? = ::SDL::ORIENTATION_PORTRAIT_FLIPPED == orientation

      def landscape? = ::SDL::ORIENTATION_LANDSCAPE == orientation

      def portrait? = ::SDL::ORIENTATION_PORTRAIT == orientation
    end
    include DisplayOrientation

    def usable_bounds
      rect = Rect.new
      err = ::SDL.GetDisplayUsableBounds(index, rect)
      raise RbSDL2Error if err < 0
      rect.to_a
    end
  end
end
