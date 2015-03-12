class MainController < ApplicationController
  require 'csv'
  INPUT_FILENAME = "E:\\Workspace\\iBusNetTestDirectory\\DisruptionReports\\Report.csv"

  #lastModifiedTime

  def index
    @time = Time.new.strftime("%m/%d/%Y %H:%M:%S ")
    @lastModifiedTime = File.mtime(INPUT_FILENAME)
    @tableLastUpdated = Disruption.maximum('updated_at')

    if(@tableLastUpdated == nil || @lastModifiedTime > @tableLastUpdated)

      Disruption.delete_all
      CSV.foreach(INPUT_FILENAME, :headers => true, :col_sep => ',') do |row|
        Disruption.create(:route => row['Route'],
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
    end

    #Order descending by disruption time observed
    @disruptions = Disruption.order(delay: :desc, routeTotalDelay: :desc, timeFirstDetected: :desc).first(20)

    @totalNumberOfDisruptions = Disruption.count
    @refreshTimeout = 5000 #30seconds
  end

  def about
  end

end
