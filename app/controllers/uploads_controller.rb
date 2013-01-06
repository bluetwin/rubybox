class UploadsController < ApplicationController
  layout nil
  #protect_from_forgery
  before_filter :get_user
  before_filter :authenticate_user!
# GET /uploads
  # GET /uploads.xml
  def index
    @uploads = Upload.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploads }
    end
  end

  # GET /uploads/1
  # GET /uploads/1.xml
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
     format.html {render :partial=>"shared/directory_item" , :collection=> [@upload], :layout => false}
     format.js  { }
    end
  end

  # GET /uploads/new
  # GET /uploads/new.xml
  def new
    @upload = Upload.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # GET /uploads/1/edit
  def edit
		@upload = Upload.find(params[:id])
		respond_to do |format|
      format.html # new.html.erb
			format.js # new.html.erb
      format.json { render json: @upload  }
    end
	
	end

  # POST /uploads
  # POST /uploads.xml
  def create
    upload_params = coerce(params)
    @upload = Upload.new(upload_params[:upload])
	
	if @upload.save
	respond_to do |format|
        format.html {                                         
		#(html response is for browsers using iframe sollution)
          render :json => [@upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => [@upload.to_jq_upload].to_json
        }
			end
		else
      		render :json => [{:error => "custom_failure"}], :status => 304
    	end
  end

  # PUT /uploads/1
  # PUT /uploads/1.xml
  def update
    @upload = Upload.find(params[:id])
		
    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        format.html { redirect_to(@upload, :notice => 'Upload was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end
	
  def rename
	@upload = Upload.find(params[:upload_id])
	respond_to do |format|
    if @upload.rename_attachment(params[:upload][:escaped_name])
		flash[:notice] = 'Rename complete'
		format.js {}
      	format.json  { render :json => @upload}
     else
	 	flash[:notice] = 'File could not be changed'
		format.js {}
      	format.json  { render :json => @upload.errors }
      end
    end
  end
  
  # DELETE /uploads/1
  # DELETE /uploads/1.xml
  def destroy
    @upload = Upload.find(params[:id])
    @upload.destroy

    respond_to do |format|
      format.html { redirect_to(uploads_url) }
      format.xml  { head :ok }
    end
  end

	
  def delete_all
		
		if params_has?([:items])
			@msg = Hash.new
			@items = Upload.find(params[:items])
			@items.each do | upload |
				upload.destroy
			end
			@msg[:body] = "Deleted #{@items.size} Item" + ((@items.size > 0 ) ? "s" : "")
			@msg[:type] = 'success'
			render :partial => 'shared/delete_item'
		else
			render :text => "Invalid input"
		end
	end
  
  
 
	def move
		if params_has?([:folder_id, :items])
			@parent = Folder.find(params[:folder_id])
			
			#Upload.update_all ['parent_id = ?', @parent.id], ["id IN (?)", params[:items]]
			Upload.where(:id.in => params[:items]).update_all(:folder_id => @parent.id)
			items = Upload.find(params[:items])
			@msg = {}
			@msg[:body] = "Moved #{items.size} Item #{((items.size > 1) ? "s " : " ")}to the #{@parent.name.camelize} Folder" 
			@msg[:type] = 'success'
			render :partial=> "shared/move_item", :layout => false, :locals => {:items => items}
		else
			render :text => "Invalid input"
		end
	end
 
 
  # GET /data_files/download/1
  # GET /data_files/download/1.xml
	def download
		@upload = Upload.find(params[:upload_id])
    send_file @upload.attachment.path
	end
 
  private 
   
  def coerce(params)
    if !params[:file].nil? and params[:file]
			h = Hash.new
			h[:upload] = params[:upload]
      h[:upload][:attachment]= params[:file]
      h[:upload][:attachment].content_type = MIME::Types.type_for(h[:upload][:attachment].original_filename).to_s
			h
    else 
      params
    end 
  end
end
