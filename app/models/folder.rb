class Folder
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :user
 	belongs_to :folder
	has_many  :folders
	field :name,:type => String, :default => "New Folder"
	validates_presence_of :name
	validates_uniqueness_of :name, :scope => [:folder]

	def empty?
		(content_size==0 and folders.count == 0)
	end
	
	def files
		[] + Upload.where(folder_id: self.id)
	end
	def sub_folders 
		Folder.where(folder_id: self.id)
	end
	
	def processable?
		false
	end	
	

	
	def table_name
		"folders"
	end
	
	def data_identity
		"f_#{self.id}"
	end
	
	def parent_identity
		(self.folder_id.nil? ? "null" : self.folder_id.data_identity )
	end
	
	def filesize
		content_size
	end
	
	def content_size
		size = 0
		self.files.each do | f |
			size += f.filesize unless f.nil?
		end
		self.folders.each do | f |
			size += f.content_size
		end
		
		size
	end
	
	def display_name
		(self.name.nil? ? "" : self.name)
		
	end
	
	def filetype()
		" "
	end
	
	def category()
		"folder" 
	end
	def icon
		"folder"
	end
	
	def created()
		self.created_at.localtime.strftime("%m/%d/%Y %I:%M%p")
	end
	
	def updated()
		self.updated_at.localtime.strftime("%m/%d/%Y %I:%M %p")
	end
	
	def modified()
		"--"
	end
	
end
