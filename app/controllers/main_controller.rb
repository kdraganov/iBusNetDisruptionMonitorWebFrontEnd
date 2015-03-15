class MainController < ApplicationController
  require 'csv'
  INPUT_FILENAME = "E:\\Workspace\\iBusNetTestDirectory\\DisruptionReports\\Report.csv"

  def view
    logger.debug "File modify time: #{File.mtime(INPUT_FILENAME)}"

    logger.debug params[:version]
    if (params[:version])
      clientVersionTime = Time.parse(params[:version])
    end

    if (File.mtime(INPUT_FILENAME) > clientVersionTime)
      getDisruptions
      @return = {:error => false, :update => true, :partial => render_to_string(:partial => "disruptionList"), :version => File.mtime(INPUT_FILENAME), :timeout => 90000}
    else
      @return = {:error => false, :update => false, :version => File.mtime(INPUT_FILENAME), :time => Time.new.strftime("%m/%d/%Y %H:%M:%S "), :timeout => 30000}
    end
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def index
    getDisruptions
  end

  def about
  end

  private

  def getDisruptions
    @version = File.mtime(INPUT_FILENAME)
    disruptions = []
    CSV.foreach(INPUT_FILENAME, :headers => true, :col_sep => ',') do |row|
      disruptions << Disruption.new(:route => row['Route'],
                                    :direction => row['Direction'],
                                    :fromStopName => row['FromStopName'],
                                    :fromStopCode => row['FromStopCode'],
                                    :toStopName => row['ToStopName'],
                                    :toStopCode => row['ToStopCode'],
                                    :delay => row['DisruptionObserved'],
                                    :routeTotalDelay => row['RouteTotal'],
                                    :trend => row['Trend'],
                                    :timeFirstDetected => row['TimeFirstDetected'])
    end
    #Order descending by disruption time observed
    @disruptions = disruptions.sort_by { |a| [a.delay*-1, a.routeTotalDelay*-1, a.timeFirstDetected] }
    @totalNumberOfDisruptions = disruptions.length
  end


  # def importDisruptions
  #   @time = Time.new.strftime("%m/%d/%Y %H:%M:%S ")
  #   @lastModifiedTime = File.mtime(INPUT_FILENAME)
  #   @tableLastUpdated = Disruption.maximum('updated_at')
  #
  #   if (@tableLastUpdated == nil || @lastModifiedTime > @tableLastUpdated)
  #     Disruption.delete_all
  #     disruptions = []
  #     CSV.foreach(INPUT_FILENAME, :headers => true, :col_sep => ',') do |row|
  #       disruptions << Disruption.new(:route => row['Route'],
  #                                     :direction => row['Direction'],
  #                                     :fromStopName => row['FromStopName'],
  #                                     :fromStopCode => row['FromStopCode'],
  #                                     :toStopName => row['ToStopName'],
  #                                     :toStopCode => row['ToStopCode'],
  #                                     :delay => row['DisruptionObserved'],
  #                                     :routeTotalDelay => row['RouteTotal'],
  #                                     :trend => row['Trend'],
  #                                     :timeFirstDetected => row['TimeFirstDetected'])
  #       list.append({:route => row['Route'],
  #                    :direction => row['Direction'],
  #                    :fromStopName => row['FromStopName'],
  #                    :fromStopCode => row['FromStopCode'],
  #                    :toStopName => row['ToStopName'],
  #                    :toStopCode => row['ToStopCode'],
  #                    :delay => row['DisruptionObserved'],
  #                    :routeTotalDelay => row['RouteTotal'],
  #                    :trend => row['Trend'],
  #                    :timeFirstDetected => row['TimeFirstDetected']})
  #     end
  #
  #     Disruption.import disruptions
  #     Disruption.create(list)
  #   end
  #
  #   Order descending by disruption time observed
  #   @disruptions = Disruption.order(delay: :desc, routeTotalDelay: :desc, timeFirstDetected: :desc).first(20)
  #
  #   @totalNumberOfDisruptions = Disruption.count
  # end

end
