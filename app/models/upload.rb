class Upload
  include Mongoid::Document
  include Mongoid::Paperclip
	include Mongoid::Timestamps
	include Rails.application.routes.url_helpers
	
	belongs_to :user
	belongs_to :folder
	has_mongoid_attached_file :attachment,  :styles => lambda{ |attachment| ["[image/jpeg]", "[image/png]", "[image/gif]"].include?( attachment.content_type ) ? { :thumb => "32x32", :mini => "16x16" } : {}  }
		
	def to_jq_upload
    {
      "name" => name(:trunc=>true),
      "size" => attachment.size,
      "url" => attachment.url,
	  "id" => id,
	  "data_identity" => data_identity,
	  "thumbnail_url" => nil,
      "delete_url" => uploads_path(:id => id),
      "delete_type" => "DELETE",
	  "ext" => extension,
	  "icon" => thumbnail,
	  "modified" => updated
    }
  end
	
	def data_identity()
		"#{self.table_name.split("_").map! {|s| s[0]}.join}_#{self.id}"
	end
	
	def processable?
		false
	end
	
	def table_name
		"uploads"
	end
	
	def name(options={})
		response = self.attachment.original_filename.gsub(/\\|'/) { |c| "\\#{c}" }
		if options[:escape] 
			response = escaped_name
		end
		if options[:trunc] and response.length > 35
			req = response.last(7);
			response = response[0,response.length-8];
			response = response[0,28] + "..." + req;
		end		
		return response
	end
	
	def escaped_name()
		self.attachment.original_filename.gsub(/\\|'/) { |c| "\\#{c}" }
	end
	
	def filename(options={})
		name = self.attachment.original_filename
		if(!options[:clean].nil?)
			name = name.gsub("_"," ")
		end
		if(options[:ext].nil?)
			name = name.split(".")[0]
		end
		name
	end
	
	def rename_attachment(new_file_name)
	 if new_file_name != self.attachment.original_filename
		(attachment.styles.keys+[:original]).each do |style|
    		original = attachment.path(style)
			new_path =  File.join(File.dirname(original), new_file_name)
			Rails.logger.info "Renameing Attachment: original #{original} new_path: #{new_path}"
    		FileUtils.move(original, new_path) unless File.exists?(new_path)
		end
		self.attachment_content_type = MIME::Types.type_for(new_file_name).to_s
		self.attachment_file_name = new_file_name
		return self.save
	 else
			return true
	 end
	end
	
	def extension()
		ext = ''
		parts = self.attachment.original_filename.split(".")
		if parts.size > 1
			ext = parts.last
		end	
		ext
	end
	
	def created()
		self.created_at.localtime.strftime("%m/%d/%Y %I:%M %p")
	end
	
	def updated()
		self.updated_at.localtime.strftime("%-m/%-d/%Y %I:%M %p")
	end
	
	def filesize()
		self.attachment.size
	end
	
	def filetype()
		self.attachment.original_filename.split(".").last
	end
	
	def category()
		"file:" 
	end
	def icon
		response = "page_white"
		icon = Icon.where(ext: self.extension)
		response += "_#{icon.first.name}" unless icon.empty?
		response
	end
	
	def thumbnail
		iclass = "icon"
		src = "/assets/icon_spacer.gif"
		if (attachment.content_type.include?("image"))
			src = attachment.url(:thumb)
		else
			iclass = "sprite sprite_web s_web_#{icon}_32 " + iclass
		end
		return {:class=> iclass, :src => src}
	end
	
	def mini
		iclass = "icon"
		src = "/assets/icon_spacer.gif"
		if (attachment.content_type.include?("image"))
			src = attachment.url(:thumb)
		else
			iclass = "sprite sprite_web s_web_#{icon}_32 " + iclass
		end
		return {:class=> iclass, :src => src}
	end
	
	def modified()
		updated
	end

end
