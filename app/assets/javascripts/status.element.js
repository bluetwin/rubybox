function StatusElement(selector){
	this.el = $(selector);
	this.progress_bar = null;
	this.icon = null;
	this.file_info = {desc: null, size: null, num_errors:null};
	this.status = null;
	this.time_left = null;
	this.init = function(elements) {
		var stat_el = this;
		for (var key in elements) {
			//console.info(key +": " + elements[key]);
			stat_el.add_element(key, elements[key]);
		}
	};
	this.add_element = function(type, selector) {
		var new_el = this.el.find(selector);
		switch(type) {
			case 'progress': 
				this.progress_bar = new_el; //".upload-progress-bar");
				break;
			case 'icon':
				this.icon = new_el; //".num-files");				
				break;
			case 'desc':
				this.file_info.desc = new_el; //".num-files");				
				break;
			case 'size':
				this.file_info.size = new_el;		
				break;
			case 'errors':
				this.file_info.num_errors = new_el;
				break;
			case 'status':
			 	this.status = new_el;
				break;
			case 'time_left':
				this.time_left = new_el;
				break;
			default:
				console.info("Error: invalid obj assignment in StatusElement.add_element(" + type + "," + selector + ")");
		}
	};
	this.reset = function() {
		this.progress(0);
		this.status.html('');
		this.file_info.desc.html('');
		this.file_info.size.html('');
		this.file_info.num_errors.html('');;
		if(this.icon) {
			this.icon.html(Sprite.html('web','s_web_syncing', {}));
		}
		if(this.time_left) {
			this.time_status('');
		}
		this.el.removeClass("complete");
	};
	this.progress = function(p) {
		if(this.progress_bar) {
		 this.progress_bar.css('width', p + '%');
		}
	};
	this.description = function(test) {
		this.file_info.desc.html(test);
	};
	this.count_text = function(c) {
		return c + " file" + (( c > 1) ? "s" : "");
	};
	this.file_size = function(s) {
		this.file_info.size.html(filesize(s));
	};
	this.error = function(e) {
		this.file_info.num_errors.html(e);
	};
	this.status = function(icon) {
		this.status.html(Sprite.html('web',icon, {}));
	};
	this.time_status = function(t) {
		this.time_left.html(t);
	};
	this.show = function() {
		this.el.show();
	};
	this.complete = function(klass) {
		this.el.addClass(klass);
	};
};