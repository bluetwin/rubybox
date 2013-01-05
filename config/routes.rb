Rubybox::Application.routes.draw do
  resources :folders 
  post "/folders/delete_all" => "folders#delete_all"
  post "/folders/move" => "folders#move"
  resources :uploads do
		get "download"
		post "rename"
	end
	post "/uploads/delete_all" => "uploads#delete_all"
	post "/uploads/move" => "uploads#move"
	
  authenticated :user do
    root :to => 'home#index'
  end
	get "/:id" => "home#index"
  root :to => "home#index"

  devise_for :users, :path => "dumont", :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
  
  resources :users
end