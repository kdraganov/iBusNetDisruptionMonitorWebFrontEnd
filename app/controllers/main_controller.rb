class MainController < ApplicationController
  require 'csv'
  INPUT_FILENAME = "E:\\Workspace\\disruptions\\DisruptionReport.csv"

  #lastModifiedTime

  def index
    @time = Time.new
    @lastModifiedTime = File.mtime(INPUT_FILENAME)
    @tableLastUpdated = Disruption.maximum('updated_at')

    if(@tableLastUpdated == nil || @lastModifiedTime > @tableLastUpdated)

      Disruption.delete_all
      CSV.foreach(INPUT_FILENAME, :headers => true, :col_sep => ';') do |row|
        Disruption.create(:route => row['Route'],
                          :direction => row['Direction'],
                          :startStop => row['SectionStart'],
                          :endStop => row['SectionEnd'],
                          :disruptionObserved => row['DisruptionObserved'],
                          :trend => row['Trend'],
                          :timeFirstDetected => @lastModifiedTime)
      end
    end


    #Order descending by disruption time observed
    @disruptions = Disruption.order(disruptionObserved: :desc)#.first(40)

    @refreshTimeout = 10000 #30seconds
  end

  def about
  end

end
