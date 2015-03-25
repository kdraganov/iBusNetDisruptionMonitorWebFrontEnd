class MainController < ApplicationController
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
    @lastUpdateTime = EngineConfiguration.find("latestFeedTime").value
    @timeout = TIMEOUT
    getDisruptions
  end

  def about
  end

  private

  def getDisruptions
    disruptions = Disruption.order(delayInSeconds: :desc, routeTotalDelayInSeconds: :desc, firstDetectedAt: :desc).all
    @disruptions = disruptions.paginate(:page => params[:page], :per_page => 20)
  end

end
