class SettingsController < ApplicationController

  def edit
    if (params[:id] != nil)
      @configs = EngineConfiguration.find_by_key(params[:id])
      render partial: "edit"
    else
      render text: "<h1>No configuration parameter specified</h1> <a class=\"close-reveal-modal\">&#215;</a>"
    end
  end

  def save
    #TODO: validate and save value
    #redirect to index and show alert for success else display error in modal
    render text: "YES"
  end

  def index
    configs = EngineConfiguration.all
    @configs = configs.paginate(:page => params[:page], :per_page => 20)
  end

end