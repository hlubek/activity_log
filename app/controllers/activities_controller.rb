class ActivitiesController < ApplicationController
  unloadable

  def index
    @activity_entries = ActivityEntry.recent.paginate :page => params[:page], :per_page => 50
  end
end
