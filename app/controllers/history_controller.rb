class HistoryController < ApplicationController

  def filter
    @disruptions = getDisruptions(params[:from], params[:to])
    render partial: 'list'
  end

  def index
    @disruptions = getDisruptions(params[:from], params[:to])
  end

  def getDisruptions(fromDate, toDate)
    if (toDate)
      begin
        to = Time.strptime(toDate, "%d/%m/%Y %H:%M:%S")
      rescue ArgumentError
        to = nil
      end
    end

    if (fromDate)
      begin
        from = Time.strptime(fromDate, "%d/%m/%Y %H:%M:%S")
      rescue ArgumentError
        from = nil
      end
    end

    whereClause = nil
    # where("\"clearedAt\" IS NULL AND NOT \"hide\"")
    if (to != nil && from != nil)
      whereClause = "\"firstDetectedAt\" >= '"+ getFormatForDB(from)+ "' AND \"firstDetectedAt\" <= '"+getFormatForDB(to)+"'"
      # whereClause = "\"firstDetectedAt\" >= '"+ getFormatForDB(from)+ "' OR \"clearedAt\" <= '"+getFormatForDB(to)+"'"
    elsif (to != nil)
      whereClause = "\"firstDetectedAt\" <= '"+ getFormatForDB(to)+"'"
    elsif (from != nil)
      whereClause = "\"firstDetectedAt\" >= '"+getFormatForDB(from)+"'"
    end
    if (whereClause != nil)
      disruptions = Disruption.includes(:fromStop, :toStop).where(whereClause).order(firstDetectedAt: :asc, delayInSeconds: :desc, routeTotalDelayInSeconds: :desc)
    else
      disruptions = Disruption.includes(:fromStop, :toStop).order(firstDetectedAt: :asc, delayInSeconds: :desc, routeTotalDelayInSeconds: :desc)
    end

    return disruptions.paginate(:page => params[:page], :per_page => 20)
  end

  def getFormatForDB(time)
    return time.strftime("%Y-%m-%d %H:%M:%S")
  end

end