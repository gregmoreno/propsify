require 'uuid'

module StringExtensions

  def self.included(mod)
    mod.extend(StringClassExtensions)
  end

  def splitfire
    s = self.gsub(/[,\-\+]+/, ' ').split
  end

  module StringClassExtensions
    def random(l=0)
      uuid = UUID.new
      code = uuid.generate(:compact)
      l > 0 ? code[0, l] : code
    end
  end
end


class String
  include StringExtensions
end
