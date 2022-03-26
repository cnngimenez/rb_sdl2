module RbSDL2
  module MessageBox
    class MessageBoxButtonDataArray
      def initialize(num)
        @entity_class = ::SDL::MessageBoxButtonData
        @ptr = ::FFI::MemoryPointer.new(@entity_class.size, num)
      end

      def [](nth) = @entity_class.new(@ptr + @entity_class.size * nth)

      def to_ptr = @ptr
    end

    class MessageBoxData
      def initialize(buttons: nil, colors: nil, escape_key: nil, level: nil, message: nil,
                     return_key: nil, title: nil, window: nil)
        @st = ::SDL::MessageBoxData.new.tap do |data|
          button_data = *buttons
          data[:numbuttons] = num_buttons = button_data.length
          data[:buttons] = @buttons = num_buttons.nonzero? &&
            MessageBoxButtonDataArray.new(num_buttons).tap do |data_ary|
              @button_texts = []
              num_buttons.times do |idx|
                st, (text, *) = data_ary[idx], button_data[idx]
                st[:buttonid] = idx
                st[:flags] = case idx
                             when escape_key then ::SDL::MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT
                             when return_key then ::SDL::MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT
                             else 0
                             end
                st[:text] = @button_texts[idx] =
                  ::FFI::MemoryPointer.from_string(text.to_s.encode(Encoding::UTF_8))
              end
            end
          data[:colorScheme] = @color_scheme = colors &&
            ::SDL::MessageBoxColorScheme.new.tap do |st|
              # r, g, b, a 形式だった場合にエラーを出さない。
              st[:colors].each.with_index { |c, i| c[:r], c[:g], c[:b] = colors[i] }
            end
          data[:flags] = MessageBoxFlags.to_num(level)
          data[:message] = @message =
            ::FFI::MemoryPointer.from_string(message.to_s.encode(Encoding::UTF_8))
          data[:title] = @title =
            ::FFI::MemoryPointer.from_string(title.to_s.encode(Encoding::UTF_8))
          data[:window] = window
        end
      end

      def to_ptr = @st.to_ptr
    end

    module MessageBoxFlags
      class << self
        def to_num(obj)
          case obj
          when /\Aerror/ then ::SDL::MESSAGEBOX_ERROR
          when /\Ainfo/ then ::SDL::MESSAGEBOX_INFORMATION
          when /\Awarn/ then ::SDL::MESSAGEBOX_WARNING
          when nil then 0
          else
            raise ArgumentError
          end
        end
      end
    end

    CONFIRMATION_OPTIONS = { buttons: { Cancel: false, OK: true }, default: true }.freeze

    class << self
      def alert(msg = nil, window = nil, level: nil, message: msg, title: nil)
        err = ::SDL.ShowSimpleMessageBox(MessageBoxFlags.to_num(level),
                                              title&.to_s&.encode(Encoding::UTF_8),
                                              message&.to_s&.encode(Encoding::UTF_8),
                                              window)
        raise RbSDL2Error if err < 0
      end

      def confirm(*args, **opts) = dialog(*args, **opts.merge!(CONFIRMATION_OPTIONS))

      # buttons: "label" | ["label",...] | [["label", obj],...] | {"label" => obj,...}
      # buttons １個以上のオブジェクトがあること。０個の場合はエラーになる。
      # colors: [[r,g,b],...] | nil
      # 環境（例えば Win10）によっては colors は反映されない。 nil の場合はシステム設定のカラーが使用される。
      # ユーザがクリックしたボタンに応じたオブジェクトが戻る。
      # ユーザが Escape キーが押した場合（何も選択しなかった場合）ブロックが与えられていればブロックの評価内容が、
      # ブロックがなければ nil が戻る。
      def dialog(msg = nil, window = nil, buttons:, message: msg, **opts)
        button_data = *buttons
        raise ArgumentError if button_data.empty?
        # Escape キーの割り当ては可能だが行わないようにした。
        # Return キーと Escape キーの割り当てが同じ場合に Return キーは機能しなくなる。
        if opts.key?(:default)
          opts.merge!(return_key: button_data.index { |*, obj| obj == opts[:default] })
          opts.delete(:default)
        end
        ptr = ::FFI::MemoryPointer.new(:int)
        data = MessageBoxData.new(buttons: button_data, message: message, window: window, **opts)
        err = ::SDL.ShowMessageBox(data, ptr)
        raise RbSDL2Error if err < 0
        # (Escape キーの割り当てがない場合に) Escape キーが押された場合 idx = -1
        if (idx = ptr.read_int) < 0
          block_given? ? yield : nil
        else
          button_data[idx]
        end
      end

      def error(*args, title: :Error, **opts)
        alert(*args, title: title, **opts.merge!(level: :error))
      end

      def info(*args, title: :Information, **opts)
        alert(*args, title: title, **opts.merge!(level: :info))
      end

      def warn(*args, title: :Warning, **opts)
        alert(*args, title: title, **opts.merge!(level: :warn))
      end
    end
  end
end
