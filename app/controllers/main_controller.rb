class MainController < ApplicationController
  require 'time'

  def details
    @id = Integer(params[:id])
    if (@id != nil)

      #TODO: Load and display more details for the disruptions
      #related routes/disruptions
      #detailed info
      #graph of the sections

      render partial: "disruptionDetails"
    else
      render text: "<h1>No disruption specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    end
  end

  def view
    if (params[:lastUpdateTime])
      begin
        clientLastUpdateTime = Time.parse(params[:lastUpdateTime])
      rescue ArgumentError
        clientLastUpdateTime = false
      end
    end

    lastUpdateTime = getLatUpdateTime
    if (clientLastUpdateTime == false || clientLastUpdateTime < Time.parse(lastUpdateTime))
      @lastUpdateTime = lastUpdateTime
      @disruptions = getDisruptions
      @return = {:error => false, :update => true, :partial => render_to_string(:partial => "disruptionList"), :lastUpdateTime => formatDatetimeString(lastUpdateTime), :timeout => TIMEOUT}
    else
      @return = {:error => false, :update => false, :lastUpdateTime => formatDatetimeString(lastUpdateTime), :timeout => TIMEOUT}
    end
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def index
    @lastUpdateTime = formatDatetimeString(getLatUpdateTime)
    @timeout = TIMEOUT
    @disruptions = getDisruptions
  end

  def about
  end

  def speed
    feedThreadPaused = EngineConfiguration.find("feedThreadPaused")
    feedThreadPaused.value = "false"
    feedThreadSpeedInMilliSeconds = EngineConfiguration.find("feedThreadSpeedInMilliSeconds")
    speed = Integer(params[:speed])
    if (speed == SPEED_SLOW)
      feedThreadSpeedInMilliSeconds.value = 10000
    elsif (speed == SPEED_FAST)
      feedThreadSpeedInMilliSeconds.value = 2500
    elsif (speed == SPEED_NORMAL)
      feedThreadSpeedInMilliSeconds.value = 5000
    elsif (speed == SPEED_VERY_FAST)
      feedThreadSpeedInMilliSeconds.value = 1000
    else
      feedThreadPaused.value = "true"
      feedThreadSpeedInMilliSeconds.value = 5000
    end

    feedThreadPaused.save
    feedThreadSpeedInMilliSeconds.save

    @return = {:success => true}
    render :json => ActiveSupport::JSON.encode(@return)
  end

  private

  TIMEOUT = 30000
  SPEED_PAUSED = 0
  SPEED_SLOW = 1
  SPEED_NORMAL = 2
  SPEED_FAST = 3
  SPEED_VERY_FAST = 4
  TIME_FORMAT = "%Y/%m/%d %H:%M:%S"

  def getLatUpdateTime
    return EngineConfiguration.find("latestFeedTime").value
  end

  def getDisruptions
    #TODO: improve ordering
    disruptions = Disruption.includes(:fromStop, :toStop).where("\"clearedAt\" IS NULL AND NOT \"hide\"").order(delayInSeconds: :desc, routeTotalDelayInSeconds: :desc, firstDetectedAt: :desc)
    return disruptions.paginate(:page => params[:page], :per_page => 20)
  end

  def formatDatetimeString(timeString)
    return Time.strptime(timeString, TIME_FORMAT).strftime("%H:%M:%S %m/%d/%Y")
  end

end
