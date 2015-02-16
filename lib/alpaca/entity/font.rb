module Alpaca
  # The *Font* class provides representation of .flf fonts so they
  # can be used
  class Font
    attr_reader :height, :hard_blank
    FONTPATH = File.expand_path(File.dirname(__FILE__) + '/../data')

    # Creates instance of class
    #
    # +name+:: font name(currently 'doom' or 'lean' exist)
    def initialize(name)
      @filename = File.join FONTPATH, name + '.flf'
      File.open(@filename, 'rb') do |f|
        header = f.gets.strip.split(/ /)
        @hard_blank = header[0]
        @height = header[1].to_i
        load_characters f
      end
    end

    # Returns true if font have representation for char.ord
    #
    # +ord+:: character code(char.ord)
    def char?(ord)
      @characters.key? ord
    end

    # Returns array of lines that represent current character
    #
    # +ord+:: character code(char.ord)
    def [](ord)
      @characters[ord]
    end

    private

    def load_characters(file)
      @characters = {}
      load_ascii_characters file
      load_german_characters file
      load_extended_characters file
    end

    def load_ascii_characters(file)
      (32..126).each { |i| @characters[i] = load_char(file) }
    end

    def load_german_characters(file)
      [91, 92, 93, 123, 124, 125, 126].each do |i|
        char = load_char(file)
        return unless char
        @characters[i] = char
      end
    end

    def load_extended_characters(file)
      until file.eof?
        i = file.gets.strip.split(/ /).first
        if i && i.empty?
          next
        else
          char = load_char(file)
          return unless char
          @characters[i] = char
        end
      end
    end

    def load_char(file)
      char = []
      @height.times do
        return false if file.eof?
        char << load_line(file)
      end
      char
    end

    def load_line(file)
      line = file.gets.rstrip
      match = /(.){1,2}$/.match(line)
      line.gsub!(match[1], '') if match
      line << "\x00"
      line
    end
  end
end
