module RbSDL2
  class Surface
    module BlendMode
      class << self
        def to_num(obj)
          case obj
          when /\Aadd/ then ::SDL2::SDL_BLENDMODE_ADD
          when /\Aalpha/, /\Ablend/ then ::SDL2::SDL_BLENDMODE_BLEND
          when /\Amod/ then ::SDL2::SDL_BLENDMODE_MOD
          when /\Amul/ then ::SDL2::SDL_BLENDMODE_MUL
          when /\Anone/, /\Anormal/ then ::SDL2::SDL_BLENDMODE_NONE
          else
            obj.to_i
          end
        end

        def to_name(num)
          case num
          when ::SDL2::SDL_BLENDMODE_ADD then "additive"
          when ::SDL2::SDL_BLENDMODE_BLEND then "alpha"
          when ::SDL2::SDL_BLENDMODE_MOD then "modulate"
          when ::SDL2::SDL_BLENDMODE_MUL then "multiply"
          when ::SDL2::SDL_BLENDMODE_NONE then "normal"
          else
            ""
          end
        end
      end

      def additive_blend_mode? = ::SDL2::SDL_BLENDMODE_ADD == blend_mode

      def alpha_blend_mode? = ::SDL2::SDL_BLENDMODE_BLEND == blend_mode

      def modulate_blend_mode? = ::SDL2::SDL_BLENDMODE_MOD == blend_mode

      def multiply_blend_mode? = ::SDL2::SDL_BLENDMODE_MUL == blend_mode

      def normal_blend_mode? = ::SDL2::SDL_BLENDMODE_NONE == blend_mode
    end
  end
end
