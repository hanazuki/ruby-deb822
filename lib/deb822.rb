require 'deb822/version'

require 'forwardable'

module Deb822
  class Error < StandardError; end

  class FieldName
    class InvalidName < Error; end

    # > The field name is composed of US-ASCII characters excluding control characters, space, and colon
    # > (i.e., characters in the ranges U+0021 ‘!’ through U+0039 ‘9’, and U+003B ‘;’ through U+007E ‘~’, inclusive).
    # > Field names must not begin with the comment character (U+0023 ‘#’), nor with the hyphen character (U+002D ‘-’).
    PATTERN = /[!"$-,.-9;-~][!-9;-~]*/

    def initialize(name)
      name = name.to_s unless name.is_a?(String)

      unless /\A#{PATTERN}\z/.match?(name)
        raise InvalidName, "Invalid field name: #{name.inspect}"
      end

      @sym = FieldName.canonicalize(name).to_sym
    end

    def to_sym
      @sym
    end

    def to_s
      @sym.to_s
    end

    def hash
      @sym.hash
    end

    def eql?(other)
      other =
        case other
        when FieldName, Symbol
          other
        else
          FieldName.new(other)
        end

      to_sym == other.to_sym
    end

    def ==(other)
      eql?(other)
    end

    def !=(other)
      !eql?(other)
    end

    def inspect
      @sym
    end

    def self.canonicalize(str)
      str.split(?-).each {|s| s.capitalize!(:ascii) }.join(?-)
    end
  end

  class Paragraph
    extend Enumerable
    extend Forwardable

    def initialize(hash = nil)
      @hash = {}
      update(hash) if hash
    end

    def [](key)
      @hash[FieldName.new(key)]
    end

    def []=(key, value)
      @hash[FieldName.new(key)] = value.to_s
    end
    alias :store :[]=

    def fetch(key, *default, &block)
      @hash.fetch(FieldName.new(key), *default, &block)
    end

    def update(other)
      other.each do |k, v|
        store(k, v)
      end
    end

    def_delegators :@hash,
      :each, :each_pair, :each_key, :each_value,
      :empty?, :length, :size,
      :keys, :has_key?, :include?, :key?, :member?,
      :values, :values_at, :has_value?, :value?,
      :inspect, :to_h, :to_hash

  end
end
