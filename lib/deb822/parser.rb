require 'deb822'
require 'deb822/scanner'

module Deb822
  # High-level parser for deb822 documents
  class Parser
    def initialize(input)
      @scanner = Scanner.new(input)
    end

    def each_paragraph
      return to_enum(:each_paragraph) unless block_given?

      last_par = last_val = nil

      @scanner.each_line do |l|
        case l[0]
        when :paragraph_separator
          yield last_par if last_par
          last_par = last_val = nil
        when :comment
          next
        when :field
          last_par ||= Paragraph.new
          last_par[l[1]] = last_val = l[2]
        when :continuation
          last_val << "\n" unless last_val.end_with?("\n")
          last_val << l[1]
        else
          fail "BUG: unreachable code: #{l.inspect}"
        end
      end

      yield last_par if last_par
    end
    alias :paragraphs :each_paragraph
  end
end
