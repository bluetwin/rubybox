# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'Test User', :email=> "donotreply@bluetwin.com", :username => 'test', :password => 'derezzed3.1415', :password_confirmation => 'derezzed3.1415'
puts 'New user created: ' << user.name
root_folder = Folder.create! :name=>"RubyBox", :user => user
Icon.create! :name=>"word", :ext=>"doc"
Icon.create! :name=>"excel", :ext=>"xls"
Icon.create! :name=>"excel", :ext=>"xlsx"
Icon.create! :name=>"ruby", :ext=>"rb"
Icon.create! :name=>"ruby", :ext=>"erb"
Icon.create! :name=>"html", :ext=>"html"
Icon.create! :name=>"py", :ext=>"py"
Icon.create! :name=>"acrobat", :ext=>"pdf"
Icon.create! :name=>"compressed", :ext=>"zip"
Icon.create! :name=>"picture", :ext=>"gif"
Icon.create! :name=>"picture", :ext=>"bmp"
Icon.create! :name=>"picture", :ext=>"jpg"
Icon.create! :name=>"picture", :ext=>"png"

