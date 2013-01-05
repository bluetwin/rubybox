module FoldersHelper

	def name_field(folder)
		if(controller.action_name == "new" || controller.action_name == "edit")
			safe_concat( 
				form_for(folder, :remote => true, :html=>{:onSubmit=>"return true;"} ) do |f|
					safe_concat( f.text_field :name, :class=>"textinput", :tabindex=>"1", :style=>"width:70%", :data=>{:action=>controller.action_name} )
					safe_concat( hidden_field_tag 'folder[folder_id]', folder.folder_id)
					safe_concat( hidden_field_tag 'folder[user_id]', folder.user_id)
				end
			)
		else 
			safe_concat( link_to(folder.display_name.camelize, folder, :class=>"filename-link", :draggable=>"true", :hidefocus=>"hideFocus"))
		end
		return
	end
end
