class Acl::Path
  YAML.mapping(
    value: String,
  )

  getter value : String
  getter regex : Regex?

  def self.value_to_regex(value : String)
    value_regex = value.gsub('*', ".*")
    value_regex = value_regex.gsub('$', "[a-zA-Z0-9_-]+")
    # TODO: add a context (user)
    Regex.new("^#{value_regex}$")
  end

  def initialize(@value : String)
    @regex = Acl::Path.value_to_regex(@value)
  end

  def acl_match?(other_path : String) : Bool
    @regex ||= Acl::Path.value_to_regex(@value)
    !!@regex.as(Regex).match(other_path)
  end

  def to_s
    @value
  end

  def size
    @value.size
  end

  def ==(rhs)
    self.to_s == rhs.to_s
  end

  def <=(rhs : Path)
    self.size <= rhs.size
  end

  def <(rhs : Path)
    self.size < rhs.size
  end

  def >=(rhs : Path)
    self.size >= rhs.size
  end

  def >(rhs : Path)
    self.size > rhs.size
  end
end
