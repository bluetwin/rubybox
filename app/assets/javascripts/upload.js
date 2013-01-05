
function Upload(f, dest, index){
	this.file = f;
	this.idx = index;
	this.el = null;
	this.progress_el = null;
	this.destination = dest;
	this.finished = false;
	this.icon = Sprite.ext_icon(f.name);	
	this.add_to = function(o) { // o is the bulk uploader ol element
		// attach template content t oelement keeping the element.
		 o.append($("#uploader_item_tmpl").render( this ));
	}
	this.done = function(response, time) {
		// add complete class to element
		this.el.addClass("complete");
		this.finished = true
		// switch status to complete image
		this.el.find("div.status-col").empty().append(Sprite.html('web','s_web_synced', {}));
		// add to browse-files list
		this.display(response);
		
	}
	this.isFisined = function() {
		return this.finished;
	}
	this.display = function(response) {
		console.info(response);
		var html = $("#directory_itme_tmpl").render( response );
		$("ol#browse-files").append($("#directory_itme_tmpl").render( response ));
		//createUploadFile(this.file);
	}
	this.progressUpdate = function(progress) {
		this.progress_el .width(progress+"%");
	}
	this.beforeSend = function() {
		this.el = $("li#upload_idx_" + this.idx);
		this.progress_el = $("li#upload_idx_" + this.idx + " div.upload-progress-bar");
		$("li#upload_idx_" + this.idx + " div.status-col").html('<a class="small-x-button"></a>');
	}
	this.eq = function(i, file) {
		var equals = true;
		if(file.name != this.file.name) { equals = false; }
		if(file.size != this.file.size) { equals = false; }
		if(i != this.idx) { equals = false;}
		if(this.el.hasClass("complete")) { equals = false;}
		return equals;
	}

};
