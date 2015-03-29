module ApplicationHelper
  require 'time'
  TIME_FORMAT = "%m/%d/%Y %H:%M:%S"

  def formatDatetimeString(timeString, format = TIME_FORMAT)
    return Time.strptime(timeString, format).strftime("%H:%M:%S")
  end

  def formatDatetimeStringWithDate(timeString, format = TIME_FORMAT)
    return Time.strptime(timeString, format).strftime("%H:%M:%S %m/%d/%Y")
  end

  def capitalizeAll(string)
    return string.split.map(&:capitalize).join(' ')
  end
end
