class Disruption < ActiveRecord::Base

  MEDIUM_THRESHOLD = 20
  SERIOUS_THRESHOLD = 40
  SEVERE_THRESHOLD = 60

  RED_COLOR = "#CC3333"
  YELLOW_COLOR = "#FFCC00"
  GREEN_COLOR = "#006633"
  ORANGE_COLOR = "#FF6600"

  TREND_SYMBOL_POSITIVE = "&#8593;"
  TREND_SYMBOL_NEGATIVE = "&#8595;"
  TREND_SYMBOL_NEUTRAL = "&#8597;"

  def totalDelayColor
    if (self.routeTotalDelay > SEVERE_THRESHOLD)
      return RED_COLOR
    end
    return YELLOW_COLOR
  end

  def delayColor
    if (self.delay > SEVERE_THRESHOLD)
      return RED_COLOR
    end
    if (self.delay > SERIOUS_THRESHOLD)
      return ORANGE_COLOR
    end
    return YELLOW_COLOR
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
