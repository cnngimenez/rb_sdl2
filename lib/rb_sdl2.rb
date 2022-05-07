module RbSDL2
  require 'sdl2'
  require_relative 'rb_sdl2/audio/audio'
  require_relative 'rb_sdl2/clipboard'
  require_relative 'rb_sdl2/cpu_info'
  require_relative 'rb_sdl2/cursor'
  require_relative 'rb_sdl2/display'
  require_relative 'rb_sdl2/display_mode'
  require_relative 'rb_sdl2/error'
  require_relative 'rb_sdl2/errors'
  require_relative 'rb_sdl2/event/event'
  require_relative 'rb_sdl2/filesystem'
  require_relative 'rb_sdl2/hint'
  require_relative 'rb_sdl2/keyboard/keyboard'
  require_relative 'rb_sdl2/message_box'
  require_relative 'rb_sdl2/mouse/mouse'
  require_relative 'rb_sdl2/palette'
  require_relative 'rb_sdl2/pixel_format_enum'
  require_relative 'rb_sdl2/platform'
  require_relative 'rb_sdl2/power_info'
  require_relative 'rb_sdl2/rect'
  require_relative 'rb_sdl2/rw_ops/rw_ops'
  require_relative 'rb_sdl2/sdl'
  require_relative 'rb_sdl2/surface'
  require_relative 'rb_sdl2/text_input'
  require_relative 'rb_sdl2/timer'
  require_relative 'rb_sdl2/video'
  require_relative 'rb_sdl2/version'
  require_relative 'rb_sdl2/window/window'

  require 'forwardable'
  extend SingleForwardable
  def_single_delegator Clipboard, :text, :clipboard_text
  def_single_delegator Clipboard, :text=, :clipboard_text=
  def_single_delegators CPUInfo, *%i(cpu_cache_line_size cpu_count system_ram)
  def_single_delegators Keyboard, *%i(hit_any_key? pressed_any_key? pressed_key?)
  def_single_delegators Platform, *%i(platform)
  def_single_delegators SDL, *%i(init init? quit)
  def_single_delegators Timer, *%i(delay realtime ticks)
  def_single_delegators Version, *%i(revision version)
  def_single_delegators Video, *%i(screen_saver? screen_saver=)

  class << self
    def hide_cursor = Cursor.hide

    def show_cursor = Cursor.show

    def confirm(message) = MessageBox.show(0, message, buttons: %w(Cancel OK), default: 1) == 1
    alias confirm? confirm

    def alert(message) = MessageBox.simple(0, message)

    def error_alert(message) = MessageBox.simple(MessageBox::ERROR, message)

    def info_alert(message) = MessageBox.simple(MessageBox::INFO, message)

    def warn_alert(message) = MessageBox.simple(MessageBox::WARN, message)

    def load(path)
      ::SDL.load_lib(path)
      # オーディオデバイスを閉じ忘れるとアプリケーションの終了時にメモリーアクセス違反を起こす。
      # アプリケーションが強制終了した場合を考慮し終了処理を設定する。
      at_exit { ::SDL.Quit }
      ::SDL.module_exec do
        attach_function :SDL_AtomicAdd, [:pointer, :int], :int
        attach_function :SDL_GetPreferredLocales, [], :pointer
      end
    end

    def loop
      Event.clear
      yield until Event.quit?
    end

    # => ["ja", "JP", "en", "US"]
    def locales
      ptr = SDLPointer.new(::SDL.SDL_GetPreferredLocales)
      # メモリーが確保できない、もしくは情報が無い。
      return [] if ptr.null?

      ptr_size = ::FFI::Pointer.size
      a = []
      until (c = ptr.read_pointer).null?
        a << c.read_string
        ptr += ptr_size
      end
      a
    end

    def open_rw(obj, ...)
      case obj
      when String then RWFile.open(obj, ...)
      when ::FFI::Pointer then RWMemory.open(obj, ...)
      when RWOps then block_given? ? yield(obj) : obj
      else RWObject.open(obj, ...)
      end
    end

    # url に与えた URL に応じたアプリケーションが起動します。
    # URL はローカルファイルを指定することができます。
    # その場合は "file:///full/path/to/file" の形式の文字列を使います。
    # Windows 環境では "file:///C:/full/path/to/file" のようにドライブレターも含みます。
    # (パス区切り文字は '/' でも '\' でも問題はない)
    # 主な使い方としてユーザに提示したい Web サイトをブラウザーを起動して見せたい場合に使用します。
    # 成功時にアプリケーションへのフォーカスが失われる場合もあります。
    # 成功しても何も起きていない場合もある。確実な動作のためには実働テストを行う必要がある。
    # 未対応の環境ではエラーになる。
    def open_url(url)
      err = ::SDL.OpenURL(SDL.str_to_sdl(url))
      raise RbSDL2Error if err < 0
    end

    def power_info = PowerInfo.new
  end
end
