module RbSDL2
  class PowerInfo
    def initialize
      # ミューテックスを使わずにマルチスレッドに対応するため毎回インスタンスを作成する実装とした。
      vars = Array.new(2) { ::FFI::MemoryPointer.new(:int) }
      @state = ::SDL.GetPowerInfo(*vars)
      @battery_time, @battery_percentage = vars.map(&:read_int).map { |n| n if n >= 0 }
    end

    # バッテリーの残り容量（パーセント）を戻しますです。
    # 残り容量を特定できない, またはバッテリーで動作していない場合 nil を戻します。
    attr_reader :battery_percentage

    # バッテリーの残り時間（秒）を戻します。
    # 残り時間を特定できない、またはバッテリーで動作していない場合は nil を戻します。
    attr_reader :battery_time

    # バッテリーが搭載されているか？
    def battery? = [::SDL::POWERSTATE_CHARGING,
                    ::SDL::POWERSTATE_CHARGED,
                    ::SDL::POWERSTATE_ON_BATTERY].include?(state)

    # 電源あり、バッテリー満充電
    def charged? = ::SDL::POWERSTATE_CHARGED == state

    # 電源あり、バッテリー充電中
    def charging? = ::SDL::POWERSTATE_CHARGING == state

    # 電源あり、バッテリー非搭載（デスクトップパソコンなど）
    def no_battery? = ::SDL::POWERSTATE_NO_BATTERY == state

    # 電源なし、バッテリー使用中
    def on_battery? = ::SDL::POWERSTATE_ON_BATTERY == state

    # 電源に接続されているか？
    def plugged_in? = !on_battery?

    attr_reader :state

    # 電源、バッテリーの情報なし
    def unknown? = ::SDL::POWERSTATE_UNKNOWN == state
  end
end
