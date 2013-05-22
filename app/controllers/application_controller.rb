class ApplicationController < ActionController::Base
  protect_from_forgery
   before_filter :authenticate_user!
 
  
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
	
	def current_controller
		@controller = params[:controller]
	end
	
	def random_sha1(chars=nil)
		seed = Time.now.to_s
		if !(chars.nil?)
			seed += chars.to_s
		end
		((Digest::SHA1.hexdigest(seed))[0,32]).insert(8,"-").insert(13,"-").insert(18,"-").insert(23,"-")		
	end

	
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
	
	
  
end
	
