class HomeController < ApplicationController
	 before_filter :authenticate_user!
  def index
		@root = Folder.where(folder_id: nil).first
		if Folder.where(_id: params[:id]).exists?
				@folder = Folder.find(params[:id])
		else
			@folder = Folder.where(user_id: current_user.id, folder_id: nil).first
		end
		
		@path = Array.new
		crawler = @folder
		@path << crawler if crawler.folder.nil?
		while crawler.folder != nil
			@path << crawler
			crawler = crawler.folder
		end
		@path.reverse!
		@folders = Folder.where(user_id: current_user.id, folder_id: @folder.id)
		@files = Upload.where(user_id: current_user.id, folder_id: @folder.id)
  end
end
