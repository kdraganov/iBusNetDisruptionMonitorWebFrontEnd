class DisruptionController < ApplicationController
  require 'time'

  def addComment
    id = nil
    commentText = nil
    begin
      id = Integer(params[:id])
      commentText = params[:comment]
    rescue ArgumentError
      render :json => ActiveSupport::JSON.encode({:error => true, :message => "Incorrect parameters."}) and return
    end
    if (commentText == nil)
      render :json => ActiveSupport::JSON.encode({:error => true, :message => "Comment is empty."}) and return
    end
    begin
      disruption = Disruption.find(id)
    rescue ActiveRecord::RecordNotFound
      render :json => ActiveSupport::JSON.encode({:error => true, :message => "Invalid disruption."}) and return
    end
    comment = DisruptionComment.new
    comment.disruptionId = disruption.id
    comment.comment = commentText
    comment.operatorId = 5
    comment.save
    @disruption = Disruption.includes(:comments).find(id)
    @return = {:error => false, :partial => render_to_string(:partial => "comments")}
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def comments
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
      @disruption = Disruption.includes(:comments).find(id)
    rescue ActiveRecord::RecordNotFound
      render text: error and return
    end
    render partial: "comments"
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
    data.push(['Section', 'Section Lost Time', {type: 'string', role: 'annotation'},
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

      tooltip = "From: <strong>"+getLinkToBusStop(section.startStop)+
          "</strong><br>To: <strong>" +getLinkToBusStop(section.endStop)+
          "</strong><br>Number of observation: <strong>" +
          section.latestLostTime.numberOfObservations.to_s+ "</strong>"

      totalTooltip = "Total minutes lost: <strong>"+totalLostTime.to_s+
          "</strong><br>From: <strong>" + getLinkToBusStop(section.startStop) +
          "</strong><br>To: <strong>" +getLinkToBusStop(section.endStop)

      data.push([label, lostTime, lostTime, tooltip, scope, totalLostTime, totalTooltip, true])
    end

    title = 'Route '+@disruption.route+' '+ @disruption.getRunString
    hAxisTitle = 'Total average disruption observed across route '+@disruption.getTotalDelay.to_s+' minutes'
    @return = {:error => false, :update => true, :partial => render_to_string(:partial => "details"), :data => data, :title => title, :hAxisTitle => hAxisTitle}
    render :json => ActiveSupport::JSON.encode(@return)
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
  TIMEOUT = 5000
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
