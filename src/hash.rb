class Hash
  class << self
    alias allocate new

    def try_convert(obj)
      if obj.is_a? Hash
        obj
      elsif obj.respond_to?(:to_hash)
        obj.to_hash.tap do |hash|
          unless hash.nil? || hash.is_a?(Hash)
            raise TypeError, "can't convert #{obj.inspect} to Hash (#{obj.inspect}#to_hash gives #{hash.inspect})"
          end
        end
      end
    end
  end

  def assoc(arg)
    each do |key, value|
      if arg == key
        return [key, value]
      end
    end
    nil
  end

  def deconstruct_keys(keys)
    self
  end

  def key(value)
    each do |k, v|
      return k if v == value
    end
    nil
  end

  alias index key

  def each_key
    return enum_for(:each_key) unless block_given?

    each do |key, _|
      yield key
    end
  end

  def each_value
    return enum_for(:each_value) unless block_given?

    each do |_, value|
      yield value
    end
  end

  def flatten(level = 1)
    to_a.flatten(level)
  end

  def invert
    new_hash = {}
    each do |key, value|
      new_hash[value] = key
    end
    new_hash
  end

  def rassoc(arg)
    each do |key, value|
      if arg == value
        return [key, value]
      end
    end
    nil
  end

  def reject(&block)
    return enum_for(:reject) unless block_given?

    dup.tap do |new_hash|
      new_hash.reject!(&block)
    end
  end

  def reject!(&block)
    return enum_for(:reject!) unless block_given?

    raise FrozenError, "can't modify frozen #{self.class.name}: #{inspect}" if frozen?

    modified = false
    each do |key, value|
      if block.call(key, value)
        delete(key)
        modified = true
      end
    end

    modified ? self : nil
  end

  def select(&block)
    return enum_for(:select) unless block_given?

    dup.tap { |new_hash| new_hash.select!(&block) }
  end
  alias filter select

  def select!(&block)
    return enum_for(:select!) unless block_given?

    raise FrozenError, "can't modify frozen #{self.class.name}: #{inspect}" if frozen?

    modified = false
    each do |key, value|
      unless yield(key, value)
        delete(key)
        modified = true
      end
    end

    modified ? self : nil
  end
  alias filter! select!

  def shift
    raise FrozenError, "can't modify frozen #{self.class.name}: #{inspect}" if frozen?

    return default(nil) if empty?

    first.tap do |key, _|
      delete(key)
    end
  end

  def transform_keys
    return enum_for(:transform_keys) { size } unless block_given?

    new_hash = {}
    each do |key, value|
      new_hash[yield(key)] = value
    end
    new_hash
  end

  def transform_keys!(&block)
    return enum_for(:transform_keys!) { size } unless block_given?

    raise FrozenError, "can't modify frozen #{self.class.name}: #{inspect}" if frozen?

    # NOTE: have to do it this way due to behavior of break
    duped = dup
    clear
    duped.each do |key, value|
      self[yield(key)] = value
    end
    self
  end

  def transform_values
    return enum_for(:transform_values) { size } unless block_given?

    new_hash = {}
    each do |key, value|
      new_hash[key] = yield(value)
    end
    new_hash
  end

  def to_proc
    lambda do |arg|
      self[*arg]
    end
  end

  def values_at(*keys)
    [].tap do |values|
      keys.each do |key|
        values << self[key]
      end
    end
  end
end
