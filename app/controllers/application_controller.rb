class ApplicationController < ActionController::Base
  protect_from_forgery
   before_filter :authenticate_user!
  #rescue_from CanCan::AccessDenied do |exception|
  #  flash[:error] = exception.message
  #  redirect_to root_url
  #end
  
  
  def after_sign_out_path_for(resource)
   	return new_user_session_path
  end

	def params_has?(keys)
		result = true
		keys.each do |key|
			result = false if !params.has_key?(key)
		end
		result
	end
  
 
  # Make the current user object available to views
  #----------------------------------------
  def get_user
    @current_user = current_user
	if current_user
		if current_user.disabled
			flash[:alert] = "Your account has been disabled"
			sign_out current_user
			redirect_to new_session_path(), :alert => "Your account has been disabled"
		end
		#only_beci
		
	end
  end
  
	def controller
		params[:controller]
	end
	
  #def only_beci
  #	if !(current_user.client.name.include?("Bald Eagle C.I."))
	#	flash[:alert] = "Access Denied"
	#	sign_out current_user
	#	redirect_to new_session_path(current_user), :alert => "Your account does not have access to Nimbus CMS"
	#end
  #end
  
  #load_and_authorize_resource
  # Get roles accessible by the current user
  #----------------------------------------------------
  #def accessible_roles
  #  @accessible_roles = Role.accessible_by(current_ability,:read)
  #end
	
	def current_controller
		@controller = params[:controller]
	end
	
  def index
  	if !user_signed_in? 
		flash[:alert] = nil
		redirect_to("/users/signin")
		end
	end
	def random_sha1(chars=nil)
		seed = Time.now.to_s
		if !(chars.nil?)
			seed += chars.to_s
		end
		((Digest::SHA1.hexdigest(seed))[0,32]).insert(8,"-").insert(13,"-").insert(18,"-").insert(23,"-")		
	end
	
	#@imp = Importer.new
	#@imp.import(1)
	
	# Function: Converts a DateTime Time stamp to specified format
	# params: object - an model instance
	# 				type - timestamp attribute to fetch (created_at, updated_at, but could be any time related attribute)[NEED TO VALIDATE CLASS]
	#					strf - string format for Time.strftime parameter
	# returns: string representation of Timestamp in 'strf' format
	def time_stamp_strf(object, type, strf)
		result = Time.now.strftime(strf)
		if object.has_attribute?(type)
			result = object[type].strftime("#{strf}")
		end
		result
	end
	
	# Function: Retrieves the Resque::Progress progress attribute
	# params: object - an model instance, which is required to have a 'meta_id' attribute, that is not nil
	# 				worker - the corresponding Worker model to retrieve the progress
	# returns: Resque::Progress::Meta.progress object(Hash)
	#					 [] Empty Array - if 'meta_id' is not an attribute or object.meta_id is nil
	def resque_progress(object, worker)
		result = []
		if object.has_attribute?('meta_id') and !(object.meta_id.nil?)
			meta = worker.constantize.get_meta("#{object.meta_id}")
			result = meta.progress
		end
		result
	end
	
	def parse_dates(search)
		post_date = search['post_date']
		start_date =  DateTime.strptime(post_date['start'],'%m/%d/%Y')
		search['post_date']['start'] = start_date.strftime("%Y-%m-%d")
		end_date = DateTime.strptime(post_date['end'],'%m/%d/%Y')
		search['post_date']['end'] = end_date.strftime("%Y-%m-%d")
		search
	end
	
	def coerce_batch(params)
    if !params['batch'].nil? and params['batch']
			batch = params['batch'] 
	 		batch['tax_code'] = ClientTaxCode.taxable_codified(batch['client_id'])
			# period - using Rails date_select helper
			# parameters sent:
			# 	period(1i) - Year
			# 	period(2i) - Month
			# 	period(3i) - disabled
	 		month = batch["period(2i)"].to_i
			year = batch["period(1i)"].to_i
			last_dom = Date.civil(year, month, -1)
			batch["post_date"] = Hash.new 
			batch["post_date"]["start"] = "#{year}-" + (month < 10 ? "0" : "") + "#{month}-01"
			batch["post_date"]["end"] = "#{year}-" + (month < 10 ? "0" : "") + "#{month}-" + last_dom.strftime("%d")
	  	batch
    else 
      params
    end 
  end 
  
  def spawn_agent(params )
  	agent = QueryAgent.new.pull_invoices(params)
	if !(agent.file_exists?)
		af = AnalysisFile.new({:data_file_name => agent.file_name, :user_id => params['user_id'], :checked_out => 1, :client_id => params['client_id']})
		if af.save
			job = AnalysisExporter.enqueue(params, af.id)
			af.update_attributes({:meta_id => job.meta_id })
			af.save
		end
	end
	agent
  end
	
	def check_out_locations(batch_params)
		# locations(non-corporate)
		@locations = Location.where("client_id = ? AND corporate_location = 0", batch_params['client_id'])
		@locations.each do | location |
			batch_params["location_number"] = [location.number]
			@agent = spawn_agent( batch_params )
		end
	end
	
	def check_out_corp_locations(batch_params)
		#corporate locations grouped by division
		batch_params["location_number"] = Location.arrayify_corp_locations(batch_params['client_id'])
		@divisions = Divisions.where("client_id = ?", batch_params['client_id'])
		@divisions.each do | division |
			batch_params["division_number"] = [division.number]
			@agent = spawn_agent( batch_params )
		end
	end
end
	
