class MainController < ApplicationController
  SPEED_PAUSED = 0
  SPEED_SLOW = 1
  SPEED_NORMAL = 2
  SPEED_FAST = 3
  SPEED_VERY_FAST = 4

  def index
    redirect_to disruption_index_url, status: 301
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

end
