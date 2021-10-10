module RbSDL2
  module PowerInfo
    @secs_ptr, @pct_ptr = Array.new(2) { ::FFI::MemoryPointer.new(:int) }

    class << self
      attr_reader :battery_capacity, :battery_time, :state

      # バッテリーが搭載されているか？
      def battery? = on_battery? || battery_charging? || battery_charged?

      # 電源あり、バッテリー満充電
      def battery_charged? = ::SDL2::SDL_POWERSTATE_CHARGED == state

      # 電源あり、バッテリー充電中
      def battery_charging? = ::SDL2::SDL_POWERSTATE_CHARGING == state

      # 電源あり、バッテリー非搭載（デスクトップパソコンなど）
      def no_battery? = ::SDL2::SDL_POWERSTATE_NO_BATTERY == state

      # 電源なし、バッテリー使用中
      def on_battery? = ::SDL2::SDL_POWERSTATE_ON_BATTERY == state

      # 電源に接続されているか？
      def plugged_in? = no_battery? || battery_charging? || battery_charged?

      def update
        @state = ::SDL2.SDL_GetPowerInfo(@secs_ptr, @pct_ptr)
        @battery_time, @battery_capacity = @secs_ptr.read_int, @pct_ptr.read_int
        self
      end

      # 電源、バッテリーの情報なし
      def unknown? = ::SDL2::SDL_POWERSTATE_UNKNOWN == state
    end
  end
end
