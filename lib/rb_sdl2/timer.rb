module RbSDL2
  module Timer
    class << self
      # ms へ与えたミリ秒だけスレッドを停止します。SDL のタイマーを使用しています。
      # ms が負の数だった場合 ArgumentError が発生します。
      def delay(ms)
        raise ArgumentError if ms < 0
        ::SDL.Delay(ms)
      end

      # performance_count の 1 秒あたりの増加量を返します。
      def performance_frequency = ::SDL.GetPerformanceFrequency

      # SDL が提供する高精度カウンターの値を返します。
      # 返ってくる値には意味がありません。精度も SDL の実装や動作環境ごとに違います。
      def performance_count = ::SDL.GetPerformanceCounter

      # 与えられたブロックの実行時間を返します。単位は秒です。
      # 実行時間の計測に SDL の高精度カウンターを使用しています。
      def realtime
        t = performance_count
        yield
        (performance_count - t).fdiv(performance_frequency)
      end

      # SDL が起動してからの経過時間をミリ秒で返します。
      # SDL のタイマーを使用しており、49日ほどで 0 に戻ります。
      def ticks = ::SDL.GetTicks
    end
  end
end
