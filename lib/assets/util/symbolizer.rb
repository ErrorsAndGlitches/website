module Symbolizer
  def self.symbolize_hash(hash)
    hash.inject({}) { |memo, (k, v)|
      memo[k.to_sym] = symbolize_obj(v)
      memo
    }
  end

  def self.symbolize_array(array)
    array.inject([]) { |memo, ele|
      memo <<= symbolize_obj(ele)
      memo
    }
  end

  def self.symbolize_obj(obj)
    if obj.is_a? Hash
      obj = symbolize_hash(obj)
    elsif obj.is_a? Array
      obj = symbolize_array(obj)
    end

    obj
  end
end