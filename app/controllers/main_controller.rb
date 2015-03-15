class MainController < ApplicationController
  require 'csv'
  INPUT_FILENAME = "E:\\Workspace\\iBusNetTestDirectory\\DisruptionReports\\Report.csv"
  INPUT_COLUMN_SEPARATOR = ','
  TIMEOUT = 5000

  def speed
    path = "E:\\Workspace\\iBusNetTestDirectory\\busNetwork\\speedControl.txt"
    File.open(path, "w") do |f|
      f.write(params[:speed])
    end
    @return = {:success => true}
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def view
    if (params[:version])
      begin
        clientVersionTime = Time.parse(params[:version])
      rescue ArgumentError
        clientVersionTime = ""
      end
    end

    if (File.exists? INPUT_FILENAME)
      version = File.mtime(INPUT_FILENAME)
    else
      version = ""
    end

    if (clientVersionTime != version ||(version != "" && File.mtime(INPUT_FILENAME) > clientVersionTime))
      update = true
    else
      update = false
    end

    if (update)
      getDisruptions
      @return = {:error => false, :update => true, :partial => render_to_string(:partial => "disruptionList"), :version => version, :timeout => TIMEOUT}
    else
      @return = {:error => false, :update => false, :version => version, :time => Time.new.strftime("%m/%d/%Y %H:%M:%S "), :timeout => TIMEOUT}
    end
    render :json => ActiveSupport::JSON.encode(@return)
  end

  def index
    if (File.exists? INPUT_FILENAME)
      @version = File.mtime(INPUT_FILENAME)
    else
      @version = ""
    end
    @timeout = TIMEOUT
    getDisruptions
  end

  def about
  end

  private

  def getDisruptions
    disruptions = []
    if (File.exists? INPUT_FILENAME)
      CSV.foreach(INPUT_FILENAME, :headers => true, :col_sep => INPUT_COLUMN_SEPARATOR) do |row|
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
      disruptions = disruptions.sort_by { |a| [a.delay*-1, a.routeTotalDelay*-1, a.timeFirstDetected] }
    end
    @disruptions = disruptions.paginate(:page => params[:page], :per_page => 20)
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
