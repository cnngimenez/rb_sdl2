module RbSDL2
  class RWOps
    class RWOpsPointer < ::FFI::AutoPointer
      class << self
        def release(ptr)
          # SDL_RWclose() は必ず（エラー時も） SDL_RWOps 構造体を開放する。
          # 2重開放を防ぐため、手動でリソースを開放する場合はこのオブジェクトの free を呼び出すこと。
          err = ::SDL.RWclose(ptr)
          raise RbSDL2Error if err < 0
        end
      end
    end
  end
end
