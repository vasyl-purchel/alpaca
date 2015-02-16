require 'alpaca/entity/font'

module Alpaca
  # The *String* module provides extended methods on strings
  module String
    # Returns _artified_ string
    #
    # +font+:: font name to turn string into ascii art
    def artify(font)
      font = Alpaca::Font.new(font)
      result = artify_message(font)
      result.join("\n").gsub(/\0/, '').gsub(font.hard_blank, ' ')
    end

    def artify_message(font)
      result = []
      each_char do |c|
        o = c.ord
        o = '0' unless font.char?(o)
        font.height.times do |j|
          line = font[o][j]
          result[j] = (result[j] ||= '') + line
        end
      end
      result
    end
  end
end

::String.send(:include, Alpaca::String)
