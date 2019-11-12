require 'deb822'

module Deb822
  # Low-level generator for deb822 document
  class Emitter
    def initialize(output)
      @output = output

      @at_beginning = true
      @in_paragraph = false
    end

    def emit_field(name, value)
      name = Deb822.FieldName(name)

      if value.respond_to?(:each_line)
        enum = value.each_line
      else
        enum = value.to_s.each_line
      end

      if !@at_beginning && !@in_paragraph
        @output << "\n"
      end
      @at_beginning = false
      @in_paragraph = true

      @output << name.to_s << ': '

      begin
        line = enum.next
        @output << line
        @output << "\n" unless line.end_with?("\n")
      rescue StopIteration
        # nop
      else
        loop do
          emit_continuation_line(enum.next)
        end
      end

      self
    end

    def emit_fields(pairs)
      pairs.each_pair do |name, value|
        emit_field(name, value)
      end
    end

    def emit_continuation_line(line)
      if /\A(?:\.|\Z)/.match?(line)
        @output << ' .' << line
      else
        @output << ' ' << line
      end
      @output << "\n" unless line.end_with?("\n")
      self
    end

    def start_paragraph
      @in_paragraph = false
      self
    end
    alias :end_paragraph :start_paragraph
  end
end
