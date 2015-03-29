class DisruptionController < ApplicationController
  require 'time'

  def comments
    id = Integer(params[:id])
    if (id != nil)
      render partial: "comments"
    else
      render text: "<h1>No disruption specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    end
  end

  def details
    error = "<h1>No disruption specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    id = nil
    begin
      id = Integer(params[:id])
    rescue ArgumentError
      render text: error and return
    end

    if (id == nil)
      render text: error and return
    end
    begin
      @disruption = Disruption.includes(:fromStop, :toStop).find(id)
    rescue ActiveRecord::RecordNotFound
      render text: error and return
    end
    @sections = Section.includes(:startStop, :endStop, :latestLostTime).where("route = ? AND run = ? ", @disruption.route, @disruption.run).order(sequence: :asc)
    startIndex = Section.where("route = ? AND run = ? AND \"startStopLBSLCode\" = ?", @disruption.route, @disruption.run, @disruption.fromStopLBSLCode)[0].sequence
    endIndex = Section.where("route = ? AND run = ? AND \"startStopLBSLCode\" = ?", @disruption.route, @disruption.run, @disruption.toStopLBSLCode)[0].sequence
    data = Array.new
    data.push(['Section', 'Section Lost Time',
               {type: 'string', role: 'tooltip', p: {html: true}}, {type: 'boolean', role: 'scope'},
               'Total Lost Time', {type: 'string', role: 'tooltip', p: {html: true}}, {type: 'boolean', role: 'scope'}])
    totalLostTime = 0
    @sections.each do |section|
      scope = false
      if (section.sequence >= startIndex && section.sequence < endIndex)
        scope = true
      end
      if (section.sequence == 1)
        label = capitalizeAll(section.startStop.name)
      elsif (section.sequence == @sections.length)
        label = capitalizeAll(section.endStop.name)
      else
        label = ''
      end
      lostTime = (section.latestLostTime.lostTimeInSeconds / 60).round
      totalLostTime += lostTime
      temp = "</strong><br>From: <strong>" + getLinkToBusStop(section.startStop) +
          "</strong><br>To: <strong>" +getLinkToBusStop(section.endStop) +
          "</strong><br>Number of observation: <strong>" + section.latestLostTime.numberOfObservations.to_s + "</strong>"
      tooltip = "Minutes lost: <strong>"+lostTime.to_s+temp
      totalTooltip = "Total minutes lost: <strong>"+totalLostTime.to_s+temp
      data.push([label, lostTime, tooltip, scope, totalLostTime, totalTooltip, true])
    end

    title = 'Route '+@disruption.route+' '+ @disruption.getRunString
    hAxisTitle = 'Total average disruption observed across route '+@disruption.getTotalDelay.to_s+' minutes'
    @return = {:error => false, :update => true, :partial => render_to_string(:partial => "details"), :data => data, :title => title, :hAxisTitle => hAxisTitle}
    render :json => ActiveSupport::JSON.encode(@return)
    # render partial: "details"
  end

  def list
    if (params[:lastUpdateTime])
      begin
        clientLastUpdateTime = DateTime.parse(params[:lastUpdateTime]).to_i
      rescue ArgumentError
        clientLastUpdateTime = nil
      end
    end
    lastUpdateTime = formatDatetimeString(getLatUpdateTime)
    if (clientLastUpdateTime == nil || clientLastUpdateTime< DateTime.parse(lastUpdateTime).to_i)
      @lastUpdateTime = lastUpdateTime
      @disruptions = getDisruptions
      @return = {:error => false, :update => true, :partial => render_to_string(:partial => "list"), :lastUpdateTime => lastUpdateTime, :timeout => TIMEOUT}
    else
      @return = {:error => false, :update => false, :lastUpdateTime => lastUpdateTime, :timeout => TIMEOUT}
    end
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def index
    @lastUpdateTime = formatDatetimeString(getLatUpdateTime)
    @timeout = TIMEOUT
    @disruptions = getDisruptions
  end

  private
  TIMEOUT = 30000
  TIME_FORMAT = "%Y/%m/%d %H:%M:%S"

  def getLatUpdateTime
    return EngineConfiguration.find("latestFeedTime").value
  end

  def getDisruptions
    disruptions = Disruption.includes(:fromStop, :toStop).where("\"clearedAt\" IS NULL AND NOT \"hide\"").order(delayInSeconds: :desc, routeTotalDelayInSeconds: :desc, firstDetectedAt: :desc)
    # disruptions = Disruption.includes(:fromStop, :toStop).order(delayInSeconds: :desc, routeTotalDelayInSeconds: :desc, firstDetectedAt: :desc)
    return disruptions.paginate(:page => params[:page], :per_page => 20)
  end

  def formatDatetimeString(timeString)
    return Time.strptime(timeString, TIME_FORMAT).strftime("%H:%M:%S %d/%m/%Y")
  end

  def capitalizeAll(string)
    return string.split.map(&:capitalize).join(' ')
  end


  def getURLToBusStop(busStop)
    if (busStop.instance_of?(BusStop))
      return 'http://countdown.tfl.gov.uk/#|searchTerm=' + busStop.code
    end
    return 'Undefined'
  end

  def getLinkToBusStop(busStop)
    if (busStop.instance_of?(BusStop))
      return '<a href="'+getURLToBusStop(busStop) + '" target="_blank">' + capitalizeAll(busStop.name) + '</a>'
    end
    return 'Undefined'
  end

end
