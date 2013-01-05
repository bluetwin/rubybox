module ApplicationHelper
	
		# Get roles accessible by the current user
  #----------------------------------------------------
  def accessible_roles
    @accessible_roles = Role.accessible_by(current_ability,:read)
  end
 
  # Make the current user object available to views
  #----------------------------------------
  def get_user
    @current_user = current_user
  end

  def display_tree(root, level, selected)

   
	root.folders.each do | folder|
		 safe_concat( tag(:div, :style=>"", :class=>"item",:open=>true))
		 safe_concat(link_to_function(image_tag( "icon_spacer.gif", :border=>"0", :class=>"sprite sprite_web s_web_bullet_plus"),"TreeView.toggleNodeAjax(this, '\x2fAccountant')"))
		 safe_concat(link_to_function(image_tag( "icon_spacer.gif", :border=>"0", :class=>"sprite sprite_web  s_web_folder_user link-img")+folder.name,"Event.stop(event); return TreeView.handle(this.rel, this)", :class=>"treeview-folder",:rel=>"/Accountant"))
			safe_concat("<br>")
			safe_concat("</div>")
			safe_concat("<div>")
			display_tree(folder, level+1, selected) if !folder.folders.empty?
			safe_concat("</div>")
			#safe_concat( tag(:li, :class=>"browse-folder",:open=>true))
			#safe_concat( "<span style='padding-left:#{level*5}px;'>&nbsp;</span>")
			#breadcrumb(folder)
			#safe_concat(image_tag( "icon_spacer.gif", :border=>"0", :class=>"sprite sprite_web s_web_folder", :style=>"line-height: 100%;") + " " )
			#safe_concat(link_to(folder.name, folder))
			#display_tree(folder, level+1, selected) if !folder.folders.empty?
			#safe_concat("</li>")
	end
	#safe_concat("</ul>")
	nil
  end
	
	def breadcrumb(folder)
		if folder.folders.empty?
			safe_concat(image_tag( "icon_spacer.gif", :border=>"0",  :style=>"width:8px;line-height: 100%;")+ " " )
		else
			safe_concat(image_tag( "icon_spacer.gif", :border=>"0", :class=>"sprite sprite_web s_web_tick", :style=>"line-height: 100%;")+ " " )
		end	
	end
	
	def event_header_title
		safe_concat( link_to(params[:controller].capitalize, "/#{params[:controller]}" ))
		# clients
		if(params[:controller] == "clients" and !@client.nil?)
			safe_concat(image_tag("icon_spacer.gif", :style=>"line-height: 100%;",  :border=>"0", :alt=>"", :class=>"sprite sprite_web s_web_breadcrumb breadcrumb_spacer ") + @client.name.camelize)
		end
		# users
		if(params[:controller] == "users" and !@user.nil?)
			safe_concat(image_tag("icon_spacer.gif", :style=>"line-height: 100%;",  :border=>"0", :alt=>"", :class=>"sprite sprite_web s_web_breadcrumb breadcrumb_spacer ") + @user.name.camelize)
		end
		# folders
		
	end
	
	def first_day_of_week(params = {})
		fdow = ((params.has_key?(:date)) ? Date.parse(params[:date]) :Date.today )
		(fdow.wday > 0)?(fdow - (fdow.wday - 1)) : (fdow - 6)
	end
	
 def flash_messages
 		message = ""
		types = %w(notice alert warning error)
 		alert_msgs = {"notice"=> "success", "alert" => "warning", "warning" => "warning", "error" => "warning" }
    alert_msgs.each_pair do |msg, type|
			message += "#{type};#{flash[msg.to_sym]}" unless flash[msg.to_sym].blank?
    end
		safe_concat message
		nil
  end
	
	def flash_content
 		message = ""
    %w(notice alert warning error).each do |msg|
			message += "#{flash[msg.to_sym]}" unless flash[msg.to_sym].blank?
    end
		safe_concat message
	
		nil
  end
	
	def flash_messages_hash
		nil
		
	end
  
  def error_messages(subject)
	subject.errors.full_messages.each do |msg|
      concat content_tag(:div, msg, :class => "alert error i_access_denied") unless msg.blank?
    end
	nil
  end
	
	def notify_error(obj)
		obj.errors.full_messages.each do |msg|
			concat msg
		end
		nil
	end
	
	def directory_item_attr(obj)
		safe_concat( "data-identity=\"#{obj.data_identity}\" data-size=\"#{obj.filesize}\" data-model-id=\"#{obj.id}\" data-model=\"#{obj.table_name}\" data-processable=\"#{obj.processable?}\"" )
	end
	

	def directory_link(obj, options ={})
	out = ""
		if(obj.class == Folder)
				out += link_to image_tag("icon_spacer.gif", :class=>"sprite sprite_web s_web_#{obj.icon}_32 icon", :alt=>'excel', :draggable=>"true"), "/#{obj.id}"
				out += link_to obj.name,"/#{obj.id}", :class=>"filename-link", 'draggable'=>"true", 'hidefocus'=>"hideFocus", :title=>"go to ", :target=>"_self"
			else
				out += link_to dir_icon(obj), upload_download_path(obj), :title=>"#{obj.escaped_name()}"
				#out += link_to "<script>Sprite.html('web', ", :alt=>'excel', :draggable=>"true"), "/#{obj.table_name}/#{obj.id}/download"
				out += link_to obj.name(:trunc=>true,:escape=>true), upload_download_path(obj), :class=>"filename-link", 'draggable'=>"true", 'hidefocus'=>"hideFocus", :title=>"#{obj.name()}", :target=>"_self" unless obj.attachment.nil?
			end
			
			return out.html_safe
	end
	
	def dir_icon(obj)
		out= ""
		if(obj.attachment.content_type.include?("image")) 
			out += image_tag(obj.attachment.url(:thumb), :class=>"icon")
		else
		 out += image_tag("icon_spacer.gif", :class=>"sprite sprite_web s_web_#{obj.icon}_32 icon", :alt=>'', :draggable=>"true")
		end
		out.html_safe
	end
	
	
	
	def download(obj, options ={})
		icon = sanitize_as_boolean(options[:icon],false)
		if icon
			safe_concat(link_to image_tag("icons/dark/copy.png"), "/#{obj.class.table_name}/#{obj.id}/download", :class=>"filename-link",:title=>"download copy")
		else
		
			if(obj.class == Folder)
				safe_concat(link_to(image_tag("icon_spacer.gif", :class=>"sprite sprite_web s_web_#{obj.icon}_32 icon", :alt=>'excel', :draggable=>"true"), obj))
					safe_concat(link_to obj.name,obj, :class=>"filename-link", 'draggable'=>"true", 'hidefocus'=>"hideFocus", :title=>"go to ", :target=>"_self")
			else
					safe_concat(link_to(image_tag("icon_spacer.gif", :class=>"sprite sprite_web s_web_#{obj.icon}_32 icon", :alt=>'excel', :draggable=>"true"), "/#{obj.class.table_name}/#{obj.id}/download"))
					safe_concat(link_to obj.name, "/#{obj.class.table_name}/#{obj.id}/download", :class=>"filename-link", 'draggable'=>"true", 'hidefocus'=>"hideFocus", :title=>"download ", :target=>"_self") unless obj.attachment.nil?
			end
		
		end
	
			return
	end
	
	def edit(obj, options ={})
		icon = sanitize_as_boolean(options[:icon],false)
		url =  "/#{obj.class.table_name}/#{obj.id}/edit"
		if icon
			safe_concat(link_to image_tag("icons/dark/create_write.png"), url, :class=>"filename-link",:title=>"edit")
		else
			safe_concat(link_to 'edit', url, :title=>"download ")
		end
			return
	end
  
	def delete(obj, remote = false)
			name = obj.class.table_name.gsub("_"," ").singularize
			safe_concat( link_to(image_tag("icons/dark/trashcan.png"), obj, :method => "DELETE", :remote => remote, :title=>"delete" ,:confirm => "Are you sure you want to DELETE this #{name}?", :class=>"small",:id=>"delete_btn_#{obj.id}", :onClick => "deleting_data_file(#{obj.id});") )
			return
	end
	
  def active_nav(c, a)
  	if a.nil?
	 if (controller.controller_name == c)
	 	"selected"
	 end 
	else
	 if (controller.controller_name == c and controller.action_name == a)
	 	"selected"
	 end 
	end
  end
 	
	def time_stamp(object, type, strf)
		result = Time.now.strftime(strf)
		if object.has_attribute?(type)
			safe_concat(object[type].strftime("#{strf}"))
		end
		return
	end
 
 	def sanitize_as_boolean(val,default = false)
		result = (val.nil? ? false : val)
		((result.is_a?(TrueClass) || result.is_a?(FalseClass) ) ? result : false)
	end
 
end
