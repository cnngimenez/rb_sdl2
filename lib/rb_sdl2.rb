module RbSDL2
  require 'sdl2'
  require_relative 'rb_sdl2/audio'
  require_relative 'rb_sdl2/clipboard'
  require_relative 'rb_sdl2/cpu_info'
  require_relative 'rb_sdl2/cursor'
  require_relative 'rb_sdl2/display'
  require_relative 'rb_sdl2/display_mode'
  require_relative 'rb_sdl2/error'
  require_relative 'rb_sdl2/event'
  require_relative 'rb_sdl2/filesystem'
  require_relative 'rb_sdl2/hint'
  require_relative 'rb_sdl2/keyboard'
  require_relative 'rb_sdl2/message_box'
  require_relative 'rb_sdl2/mouse'
  require_relative 'rb_sdl2/palette'
  require_relative 'rb_sdl2/pixel_format_enum'
  require_relative 'rb_sdl2/platform'
  require_relative 'rb_sdl2/power_info'
  require_relative 'rb_sdl2/rect'
  require_relative 'rb_sdl2/rw_ops'
  require_relative 'rb_sdl2/screen_saver'
  require_relative 'rb_sdl2/sdl'
  require_relative 'rb_sdl2/surface'
  require_relative 'rb_sdl2/text_input'
  require_relative 'rb_sdl2/timer'
  require_relative 'rb_sdl2/window'
  require_relative 'rb_sdl2/video'
  require_relative 'rb_sdl2/version'

  class RbSDL2Error < StandardError
    def initialize(error_message = Error.message) = super
  end

  require 'forwardable'
  extend SingleForwardable
  def_single_delegators CPUInfo, *%i(cpu_cache_line_size cpu_count cpu_extension? system_ram)
  def_single_delegators Platform, *%i(platform)
  def_single_delegators SDL, *%i(init init? quit)
  def_single_delegators Version, *%i(revision version)

  class << self
    def load(path)
      ::SDL.load_lib(path)
      # オーディオデバイスを閉じ忘れるとアプリケーションの終了時にメモリーアクセス違反を起こす。
      # アプリケーションが強制終了した場合を考慮し終了処理を設定する。
      at_exit { ::SDL.Quit }
    end

    def loop
      Event.clear
      yield until Event.pump
    end

    # *Experimental*
    # => ["ja", "JP", "en", "US"]
    def locales
      ::SDL.module_exec { attach_function :SDL_GetPreferredLocales, [], :pointer }

      ptr = ::SDL.SDL_GetPreferredLocales
      raise RbSDL2Error if ptr.null? # OutOfMemory もしくは情報が無い。空配列を返した方がよいだろう。
      a = []
      until (c = ptr.read_pointer).null?
        a << c.read_string
        ptr += ::FFI::Pointer.size
      end
      ::SDL.free(ptr)
      a
    end
  end
end
