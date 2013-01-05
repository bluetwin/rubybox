module UsersHelper

	def user_show(user)
	
		safe_concat( link_to( "View", user, :class=>"btn i_magnifying_glass icon small"))
		return
	end
	
	def user_list()
		if can?( :manage, User)
			safe_concat( link_to( "User List", users_url, :class=>"btn i_users icon small"))
		end
		return
	end
	
	def user_edit(user)
		if can?( :manage, User) or current_user.id == user.id
			safe_concat( link_to( "Edit", edit_user_url(user), :class=>"btn i_create_write icon small"))
		end
		return
	end
	
	def user_delete(user)
		if user.id != current_user.id and can?(:manager, User)
			safe_concat( link_to("Delete", user, :method=>"DELETE", :confirm => "Are you sure you want to DELETE this user?", :class=>"btn i_cross icon red small") )
		end
		return
	end
	
	def user_buttons(user)
		
		if !(controller.action_name.include?("show"))
			safe_concat( link_to("Password Reset", user_password_reset_url(user) + "?=action#{controller.action_name}", :method=>"PUT", :class=>"btn i_mail icon small"))
			safe_concat( link_to( "View", user, :class=>"btn i_user icon small"))
		end
		user_edit(user)
		user_disable_button(user)
		user_delete(user)

		return
	end
	
	def user_disable_button(user)
		if user.id != current_user.id and can?(:delete, user)
			css_class = "btn "  + ((user.disabled) ? "i_flag icon green small" : "i_access_denied icon red small" )
			disable_text = ((user.disabled) ? "enable" : "disable")
			if user.disabled
				safe_concat( link_to( disable_text, disable_user_path(user), :class=>css_class ) )
			else
				safe_concat( link_to( disable_text, disable_user_path(user), :confirm => "Are you sure you want to DISABLE this user?", :class=>css_class ) )		
			end
		end
		return
	end
	

	
end
