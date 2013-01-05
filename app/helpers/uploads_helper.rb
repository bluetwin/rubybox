module UploadsHelper

	def upload_form_field(o)
		if(controller.action_name == "new" || controller.action_name == "edit")
			safe_concat( 
				form_for(o, :url => upload_rename_path(o),:remote => true,:method => :post, :html=>{:onSubmit=>"show_saving(upload," + o.id + ");"} ) do |f|
					f.text_field :escaped_name, :class=>"textinput", :tabindex=>"1", :style=>"width:70%"
				end
			)
		else 
			safe_concat( link_to(o.name.camelize, folder, :class=>"filename-link", :draggable=>"true", :hidefocus=>"hideFocus"))
		end
		return
	end
end
