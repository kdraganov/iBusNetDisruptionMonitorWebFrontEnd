module ApplicationHelper
  require 'time'
  TIME_FORMAT = "%m/%d/%Y %H:%M:%S"

  def formatDatetimeString(timeString)
    return Time.strptime(timeString, TIME_FORMAT).strftime("%H:%M:%S")
  end

  def formatDatetimeStringWithDate(timeString)
    return Time.strptime(timeString, TIME_FORMAT).strftime("%H:%M:%S %m/%d/%Y")
  end

  def capitalizeAll(string)
    return string.split.map(&:capitalize).join(' ')
  end
end
