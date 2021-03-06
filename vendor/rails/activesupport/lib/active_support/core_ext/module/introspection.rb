class Module
  # Return the module which contains this one; if this is a root module, such as
  # +::MyModule+, then Object is returned.
  def parent
    parent_name = name.split('::')[0..-2] * '::'
    parent_name.empty? ? Object : parent_name.constantize
  end

  # Return all the parents of this module, ordered from nested outwards. The
  # receiver is not contained within the result.
  def parents
    parents = []
    parts = name.split('::')[0..-2]
    until parts.empty?
      parents << (parts * '::').constantize
      parts.pop
    end
    parents << Object unless parents.include? Object
    parents
  end

  if RUBY_VERSION < '1.9'
    # Return the constants that have been defined locally by this object and
    # not in an ancestor. This method is exact if running under Ruby 1.9. In
    # previous versions it may miss some constants if their definition in some
    # ancestor is identical to their definition in the receiver.
    def local_constants
      inherited = {}

      ancestors.each do |anc|
        next if anc == self
        anc.constants.each { |const| inherited[const] = anc.const_get(const) }
      end

      constants.select do |const|
        !inherited.key?(const) || inherited[const].object_id != const_get(const).object_id
      end
    end
  else
    def local_constants #:nodoc:
      constants(false)
    end
  end

  # Returns the names of the constants defined locally rather than the
  # constants themselves. See <tt>local_constants</tt>.
  def local_constant_names
    local_constants.map(&:to_s)
  end
end
