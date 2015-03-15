module MainHelper
  require 'time'

  def formatDatetimeString(timeString)
    return Time.parse(timeString).strftime("%H:%M:%S")
  end

  def formatDatetimeStringWithDate(timeString)
    return Time.parse(timeString).strftime("%H:%M:%S %m/%d/%Y")
  end

end
