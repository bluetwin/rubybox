class FoldersController < ApplicationController
	layout nil
	protect_from_forgery
    before_filter :get_user, :except =>[:google_cache_code]
	before_filter :authenticate_user!, :except =>[:google_cache_code]

	def index
		@parse 
		@folder = Folder.find(1)
		@folders = Folder.where("parent_id =?",@folder.id)
		@files = AnalysisFile.where("parent_id = ?",@folder.id)
		@files += DataFile.where("parent_id = ?",@folder.id)
		@path= [@folder]
		@clients = Client.active
		@client = @clients.first
		@client_tax_codes = ClientTaxCode.where("client_id = ?", @client.id)
		@divisions = Division.where(:client_id => @client).order("number ASC")
		@locations = Location.active_locations_for_client(@client.id,"number ASC")
		render 'show'
	end
	
	def show 
		@folder = Folder.find(params[:id])
		respond_to do |format|
      format.html # show.html.erb
			format.js # show.html.erb
      format.json { render json: @folder  }
    end
	end
	
  def new
		#name = unique_name(nil, Folder.where(folder_id: params[:parent]), 1)
		@folder = Folder.new(user_id: current_user.id, folder_id: params[:parent], name: "")
		respond_to do |format|
      format.html # new.html.erb
			format.js # new.html.erb
      format.json { render json: @folder  }
    end
	end
	
	def edit
		@folder = Folder.find(params[:id])
		respond_to do |format|
      format.html # new.html.erb
			format.js # new.html.erb
      format.json { render json: @folder  }
    end
	
	end
	
	# POST /folders
  # POST /folders.json
  def create
    @folder = Folder.new(params[:folder])

    respond_to do |format|
      if @folder.save
	  	@msg = "success;Created Folder '#{@folder.name}'"
			format.js {}
      format.json  { render :json => @folder}
      else
	  	#flash[:alert] = @folder.errors.inspect #'Folder not created - '
        format.js { render 'error.js'}
        format.json  { render :json => @folder.errors }
      end
    end
  end
	
	def update
		@folder = Folder.find(params[:id])

	    respond_to do |format|
    		if @folder.update_attributes(params[:folder])
					@items = [@folder]
					flash[:notice] = 'Rename complete'
        	#format.html { redirect_to(@data_file, :notice => 'Folder was successfully updated.') }
					format.js {}
        	format.json  { render :json => @folder}
     		 else
			 			flash[:notice] = 'Folder could not be renamed'
        		#format.html { render :action => "edit" }
						format.js {}
       			format.json  { render :json => @folder.errors }
      		end
    	end
	end
	
	def move
		if params_has?([:folder_id, :items])
			@parent = params[:folder_id]
			if (Folder.exists?(params[:folder_id]))
				@parent = Folder.find(params[:folder_id]).id
			end
			Folder.update_all ['parent_id = ?', @parent], ["id IN (?)", params[:items]]
			items = Folder.find(params[:items])
			@msg = {}
			@msg[:body] = "Folder Moved"
			@msg[:type] = 'success'
			render :partial=> "shared/move_item", :layout => false, :locals => {:items => items}
		else
			render :text => "Invalid input"
		end
	end
	
	def delete_all
		if params_has?([:items])
			errs = ""
			removed = Array.new
			# items format {:folders => [], :files => {:data_files => [], :uploads => [], :analysis_files => []}}
			
			@items = Folder.find(params[:items])
			@items.each do | item |
				Rails.logger.info "#{item.name} #{item.empty?}"
				if item.empty?
					item.destroy		
      		removed << item
				else
					errs += "Cannot remove \"#{item.name}\", its not empty." 
				end				
			end
			@msg = {}
			@msg[:body] = "#{errs}" + (!removed.empty?  ? ("Deleted #{removed.size} Item" + ((removed.size > 1 ) ? "s" : ""))  : "")
			@msg[:type] = (errs.empty? ? 'success' :  'error')
			@items = removed
			render :partial => 'shared/delete_item'
		else
			render :text => "Invalid input"
		end
	end
	
	private
	
	def unique_name(name, folders, i)
		found = false
		name = "New Folder" if name.nil?
		folders.each do | folder |
			if folder.name == name
				found = true
				break
			end
		end
		if found 
			name = "New Folder(#{i})"
			name = unique_name(name, folders, i+1)
		end
		name
			
	end
	
end


