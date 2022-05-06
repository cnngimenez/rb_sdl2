module RbSDL2
  class Audio
    module AudioSpecReader
      require 'forwardable'
      extend Forwardable
      def_delegators :spec,
                     *%i(big_endian? bitsize float? signed? channels format frequency samples)
    end
  end
end
