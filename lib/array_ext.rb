module Enumerable
  def single?(&block)
    size = block_given? ? select(&block).size : self.size
    size == 1
  end
end


