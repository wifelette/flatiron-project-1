module Canddiates
  class YesNoError < StandardError
    def message
      "Whoops! The only valid options here are yes, no, true and false. Try again?"
    end
  end
end