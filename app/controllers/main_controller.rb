class MainController < ApplicationController
  require 'time'
  require 'gchart'

  def comments
    id = Integer(params[:id])
    if (id != nil)
      render partial: "comments"
    else
      render text: "<h1>No disruption specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    end
  end

  def details
    id = Integer(params[:id])
    if (id != nil)
      #TODO: Load and display more details for the disruptions
      #related routes/disruptions
      #detailed info
      #graph of the sections
      @disruption = Disruption.includes(:fromStop, :toStop).find(id)

      # @sections = Section.includes(:startStop, :endStop, :latestLostTime).where("route = ? AND run = ?", @disruption.route, @disruption.run).order(sequence: :asc)

      @sections = Section.includes(:startStop, :endStop, :latestLostTime).where("route = ? AND run = ? ", @disruption.route, @disruption.run).order(sequence: :asc)

      startIndex = Section.where("route = ? AND run = ? AND \"startStopLBSLCode\" = ?", @disruption.route, @disruption.run, @disruption.fromStopLBSLCode)[0].sequence
      endIndex = Section.where("route = ? AND run = ? AND \"startStopLBSLCode\" = ?", @disruption.route, @disruption.run, @disruption.toStopLBSLCode)[0].sequence

      # @routeTotal = 0
      # @sections.each do |section|
      #   @routeTotal += section.latestLostTime.lostTimeInSeconds
      # end
      # @routeTotal = (@routeTotal / 60).round
      @xaxisLabels = Array.new
      data = Array.new
      maxValue = 0
      @sections.each do |section|
        if (section.sequence >= startIndex - 2 && section.sequence <= endIndex + 2)
          @xaxisLabels.push(section.startStopLBSLCode)
          lostTime = section.latestLostTime.lostTimeInSeconds / 60
          data.push(lostTime)
          if (maxValue < lostTime)
            maxValue = lostTime
          end
        end
      end
      @chart = Gchart.line(
          :size => '700x428',
          :encoding => 'text',
          :title_color => '76A4FB',
          :title => "Time loss per section along route " + @disruption.route + " in " + @disruption.getRunString + " direction",
          :bg => 'efefef',
          :line_colors => '76A4FB',
          :axis_with_labels => [['x'], ['y']],
          :max_value => maxValue,
          :min_value => 0,
          :axis_labels => [@xaxisLabels, 'Mins'],
          :axis_range => [nil, [0, 150, [maxValue/10, 1].max]],
          :data => data)
      render partial: "disruptionDetails"
    else
      render text: "<h1>No disruption specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    end
  end

  def view
    if (params[:lastUpdateTime])
      begin
        clientLastUpdateTime = Time.strptime(params[:lastUpdateTime], " %H:%M:%S %m/%d/%Y")
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
    #disruptions = Disruption.includes(:fromStop, :toStop).order(delayInSeconds: :desc, routeTotalDelayInSeconds: :desc, firstDetectedAt: :desc)
    return disruptions.paginate(:page => params[:page], :per_page => 20)
  end

  def formatDatetimeString(timeString)
    return Time.strptime(timeString, TIME_FORMAT).strftime("%H:%M:%S %d/%m/%Y")
  end

end
