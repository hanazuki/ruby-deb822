require 'stringio'

module Deb822
  # Low-level parser for deb822 documents
  class Scanner
    def initialize(input)
      @input = input.is_a?(String) ? StringIO.new(input) : input

      @in_paragraph = false
    end

    WS = /[ \t]/

    def next_line
      loop do
        begin
          line = @input.readline
        rescue EOFError
          break
        end

        case line
        when /\A#{WS}*\Z/o
          # > The paragraphs are separated by empty lines.
          # > Parsers may accept lines consisting solely of U+0020 SPACE and U+0009 TAB as paragraph separators
          if @in_paragraph
            @in_paragraph = false
            break [:paragraph_separator]
          else
            next
          end
        when /\A#/
          # > Lines starting with U+0023 ‘#’, without any preceding whitespace are comments lines
          break [:comment, $']
        when /\A(#{FieldName::PATTERN}):#{WS}*/o
          name = $1
          value = $'.chomp
          @in_paragraph = true
          break [:field, name, value]
        when /\A#{WS}\.?/o
          # > The lines after the first are called continuation lines and must start with a U+0020 SPACE or a U+0009 TAB.
          # > Empty lines in field values are usually escaped by representing them by a U+0020 SPACE followed
          # > by a dot (U+002E ‘.’).
          raise FormatError, "Unexpected continuation line: `#{l.chomp}'" unless @in_paragraph
          break [:continuation, $']
        else
          raise FormatError, "Ill-formed line: `#{l.chomp}'"
        end

        return nil
      end
    end

    def each_line(&block)
      Enumerator.new(self, :each_line) unless block

      while l = next_line
        block.call(y)
      end
    end
  end
end
