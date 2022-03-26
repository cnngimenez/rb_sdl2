module RbSDL2
  class Surface
    module BlendMode
      class << self
        def to_num(obj)
          case obj
          when /\Aadd/ then ::SDL::BLENDMODE_ADD
          when /\Aalpha/, /\Ablend/ then ::SDL::BLENDMODE_BLEND
          when /\Amod/ then ::SDL::BLENDMODE_MOD
          when /\Amul/ then ::SDL::BLENDMODE_MUL
          when /\Anone/, /\Anormal/ then ::SDL::BLENDMODE_NONE
          else
            obj.to_i
          end
        end

        def to_name(num)
          case num
          when ::SDL::BLENDMODE_ADD then "additive"
          when ::SDL::BLENDMODE_BLEND then "alpha"
          when ::SDL::BLENDMODE_MOD then "modulate"
          when ::SDL::BLENDMODE_MUL then "multiply"
          when ::SDL::BLENDMODE_NONE then "normal"
          else
            ""
          end
        end
      end

      def additive_blend_mode? = ::SDL::BLENDMODE_ADD == blend_mode

      def alpha_blend_mode? = ::SDL::BLENDMODE_BLEND == blend_mode

      def modulate_blend_mode? = ::SDL::BLENDMODE_MOD == blend_mode

      def multiply_blend_mode? = ::SDL::BLENDMODE_MUL == blend_mode

      def normal_blend_mode? = ::SDL::BLENDMODE_NONE == blend_mode
    end
  end
end
