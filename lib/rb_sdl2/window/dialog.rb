module RbSDL2
  class Window
    module Dialog
      require_relative '../message_box'

      def alert(message, **opts) = MessageBox.alert(message, self, **opts)

      def confirm(message, **opts) = MessageBox.confirm(message, self, **opts)

      def dialog(message, **opts) = MessageBox.dialog(message, self, **opts)

      def error_alert(message, **opts) = MessageBox.error(message, self, **opts)

      def info_alert(message, **opts) = MessageBox.info(message, self, **opts)

      def warn_alert(message, **opts) = MessageBox.warn(message, self, **opts)
    end
  end
end
