class Disruption < ActiveRecord::Base

  RED_COLOR = "#CC3333"
  YELLOW_COLOR = "#FFCC00"
  GREEN_COLOR = "#006633"

  TREND_SYMBOL_POSITIVE = "&#8593;"
  TREND_SYMBOL_NEGATIVE = "&#8595;"
  TREND_SYMBOL_NEUTRAL = "&#8597;"

  def disruptionColor
    if (self.disruptionObserved > 40)
      return RED_COLOR
    else
      return YELLOW_COLOR
    end
  end

  def trendColor
    if (self.trend == 1)
      return GREEN_COLOR
    elsif (self.trend == 0)
      return YELLOW_COLOR
    else
      return RED_COLOR
    end
  end

  def trendSymbol
    if (self.trend == 1)
      return TREND_SYMBOL_NEGATIVE
    elsif (self.trend == 0)
      return TREND_SYMBOL_NEUTRAL
    else
      return TREND_SYMBOL_POSITIVE
    end
  end

end
