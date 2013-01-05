var SelectMonitor = {
	selected: {},
	selector: null,
	size: 0,
	last_clicked : null,
	editing: null,
	new_flag: false,
	init: function(selector) {
		var $monitor = this;
		$monitor.selector = selector;
		$(selector).not("#parent_folder").each(function() {
			$monitor.bind_events($(this));
		});
		
	},
	bind_events: function(el) {
		var $monitor = SelectMonitor;
		el.on("click", function(event){
			var $this = $(this);
			var target  = $(event.target);
			if (target.is('a')) {
				return true;
			}
			else {
				console.info("Calling SelectMonitor.handleClick");
				SelectMonitor.handleClick(el,event);
			}
        });

		if(el.data("model") == "folders") {
			el.droppable({
				hoverClass: "dragover" ,
      			drop: function( event, ui ) {
					SelectMonitor.drop(this, event, ui);
        		}
			});
		}
	},
	handleClick: function(el, event) {
		SelectMonitor.cancel_edit();
		var drag_attr = el.attr("draggable");
		
		// if we have ctrl down we toggle selected but dont unselect currently selected;
		if(event.ctrlKey) {
			if (typeof drag_attr !== 'undefined' && drag_attr !== false) {
				SelectMonitor.removeItem(el);
			} else {

				SelectMonitor.addItem(el);
				
			}
		}else if(event.shiftKey) {
			SelectMonitor.shiftSelect(el);
		} else {
			// if we dont have the ctrl down, deselect all selected and select $this
			SelectMonitor.deselect_all_but(el);
		}
	},
	shiftSelect: function(el) {
		var trigger = false;
		var monitor = SelectMonitor;

		$(monitor.selector).each(function() {
			var $this = $(this);
			if(this.id == el[0].id || this.id == monitor.last_clicked[0].id ) {
				trigger = !(trigger); 	
				monitor.addItem($this);
			}
			else {
	
				if(trigger) {
					monitor.addItem($this);
				}
			}
		});
	},
	deselect_all: function() {
	  $(".file-select").each(function() {
      var $this = $(this);
			SelectMonitor.removeItem($this);
	  });
		SelectMonitor.last_clicked = null;
	},
	deselect_all_but: function(el) {
	  $(".file-select").each(function() {
       	var $this = $(this);
		if($this != el) {
			
			SelectMonitor.removeItem($this);
		}
	  });
		SelectMonitor.last_clicked = el;
		SelectMonitor.addItem(el);
	},
	setEditing: function(id) {
		this.editing = id;
	},
	download: function() {
		$.ajax({
  		url: self.url,
  		dataType: 'json',
			type: 'post',
 		 	data: {'items' : self.selected},
  			success: function(data) {
				//console.info(data);
    			$.each(data, function(i,item){
					$("#" + item.id).progressWatch('set',item.progress);
       			});
			}
		});
	},
	drop: function(drop_el, ui, event) {
		var monitor = SelectMonitor;
		var parent_id = $(drop_el).data("modelId");
		
		//if(parent_id != null) {
		//	parent_id = parent_id.split("_")[2];
		//}
		var sendData = new Array();

		sendData = new Array();
		for (var key in monitor.selected) {
			//$.each(monitor.selected[key], function(index) {
				if(monitor.selected[key].length > 0 ){
					$.ajax({
  						url: '/' + key +'/move',
  						dataType: 'script',
						type: 'post',
 		 				data: {'folder_id' : parent_id,
						 	'items' : monitor.selected[key]}
					});
				}
				
			//});
			
		}

	},
	display_helper : function(e) {
		var $monitor = SelectMonitor;
		var container = $('<div class="drag-box" id="drag_display" style="top: ' + e.pageX + 'px;left:' +  e.pageY + 'px"></div>');
		
		//var list  = $("#browse-files").clone();
		//list.attr("style", "padding-top: 0px !important;opacity: .20");
		//list.empty();
		//list.width(380);
		var limit = 4;
		var shown = 0
		console.info(e.pageX +', '+ e.pageY);
		for (var key in $monitor.selected) {
			$.each($monitor.selected[key], function(index) {
				
				var icon = $("#" + gen_element_id(this, key) + " img.icon").clone();

				icon.attr("style", "position:absolute");
				console.info(icon.attr("src").indexOf("spacer"));
				if(icon.attr("src").indexOf("spacer") == -1) {
					icon.addClass("image-brdr");
				}
				if(shown < limit) {
					icon.css("top", (2*(shown+1)) + "px");
					icon.css("left",(2*(shown+1)) + "px");
					container.prepend(icon);
				}
				shown += 1;
			});
		}
		container.append("<span>" + $monitor.item_count() + "</span>");
		//container.append(list);
		//container.height(list.height());
		//alert(e.pageX);
		container.attr("style", "position:absolute;top: " + e.pageX + "px;left:" +  e.pageY + "px");
		console.info(container.position());
		return container;
	},
	rename: function() {

		var monitor = SelectMonitor;
		console.info(monitor.item_count);
		if(monitor.item_count() == 1) {
		
			for (var key in monitor.selected) {
			$.each(monitor.selected[key], function(index) {
				var id = gen_element_id(monitor.selected[key], key);
				var  el = $("#" +  id);
				monitor.editing = id;
				el.find(".filename-col").append("<img src='/assets/icons/ajax-loading-small.gif' />");
				if(monitor.selected[key].length > 0 ){
					$.ajax({
  						url: '/' + key +'/' + el.data("modelId") + "/edit" ,
  						dataType: 'script',
						type: 'get',
					});
				}
				
				//sendData.push(this);
			//});
			});
			monitor.deselect_all();
		}
			
		}
	},
	cancel_edit: function() {
		
		var monitor = SelectMonitor;
		console.info("cancel edit" + monitor.editing);
		if(monitor.editing != null) {
			
			var el = $("#" + monitor.editing);
			console.info(el.find("form"));
			var form = el.find("form");
			if(el.find("form").length > 0) {
				var input = form.find("input.textinput");
				console.info($(input));
				form.submit();
				if(input.data('action') == 'new') {
					//el.fadeOut('fast').remove();
				}
				/*$.ajax({
  						url: '/' + el.data("model") +'/' + el.data("modelId") ,
  						dataType: 'script',
						type: 'get',
					});*/
			}
			//monitor.editing = null;
			//monitor.new_flag  = false;
		}
		
	},
	new_folder: function(fid, e) {
		var monitor = SelectMonitor;
		console.info("cancel edit" + monitor.editing);
		
		if(monitor.new_flag == false ) {
			monitor.new_flag = true;
			$.ajax({
  			url: '/folders/new',
  						dataType: 'script',
						data: {'parent': fid},
						type: 'get',
						beforeSend: function(jqXHR, settings){}
					});
		}
		//e.preventDefaults();
	},
	hide_folder_form: function() {
		$("#" + SelectMonitor.editing).fadeOut('fast').remove();
		SelectMonitor.editing = null;
		SelectMonitor.new_flag = false;
	},
	replace_new: function(id, new_el) {
		var monitor = SelectMonitor;
		console.info("cancel edit" + monitor.editing);
		if(monitor.editing != null) {
			var el = $("#" + monitor.editing);
			el.replaceWith(new_el);
			monitor.deselect_all();
			monitor.addItem(new_el);
			//$(id).addClass('file-select');
			monitor.bind_events($(id));
			monitor.editing = null;
			
		}
	},
	delete: function() {
		var monitor = SelectMonitor;
		var sendData = new Array();
		for (var key in monitor.selected) {
			$.each(monitor.selected[key], function(index) {
					var  el = $("#" +  gen_element_id(monitor.selected[key], key));
					monitor.deselect_element(el);
					monitor.highlight(el, 'deleting');
					el.addClass('deleting');
			});
			if(monitor.selected[key].length > 0 ){
				$.ajax({
  					url: '/' + key +'/delete_all',
  					dataType: 'script',
					type: 'post',
 		 			data: {'items' : monitor.selected[key]}
				});
			}
		}
		
	},
	highlight :function(el, klass) {
		el.addClass(klass);
	},
	delete_selected: function() {
		// prompt confirmation
		// display overlay
		var monitor = SelectMonitor;
		var sendData = new Array();
		
		var content = $("#delete_items_tmpl").render({filename: SelectMonitor.delete_text()});
		Modal.content(content);
		Modal.title("s_web_delete_32", "Delete " + SelectMonitor.selected_text() + " ?");
		Modal.vars['action'] = SelectMonitor.delete;
		Modal.show();
	},
	delete_text: function() {
		var response = "";
		var monitor = SelectMonitor;
		var count = monitor.item_count();
		if(count == 1) {
			response = "file";
			for (var key in monitor.selected) {
    		if (monitor.selected.hasOwnProperty(key)) {
					var target =  $("#" + gen_element_id(monitor.selected[key],key));

     	 	response = "'"  + target.find("div.filename-col a:last").text() + "'";
    		}
			}
		}
		else {
			response = monitor.selected_text();
		}

		return response; 
		
	},
	addItem: function(el) {
		//SelectMonitor.bind_events(el);
		SelectMonitor.last_clicked = el;
		var id = el.data("modelId");
		var model =  el.data("model");
		var size =  parseInt(el.data("size"));
		if(this.selected[model] == undefined) {
			this.selected[model] = [];
		}
		if(this.selected[model].indexOf(id) == -1) {
			this.selected[model].push(id);
		}

		this.select_element(el);
		this.size += size;

		this.update();
	},
	removeItem: function(el, delete_it) {
		var id = el.data("modelId");
		var size =  parseInt(el.data("size"));
		var model = el.data("model");
		if(this.selected[model] != undefined) {
			var idx = this.selected[model].indexOf(id);
			if(idx >= 0) {
				this.selected[model].splice(idx,1);
			}
			this.deselect_element(el);
			this.size -=  size;
		
			
			this.update();
		}
		if(delete_it == true ) {
			el.css("background-color","#D46D66").delay(1000).fadeOut('fast').remove();
		}	
	},
	empty: function() {
		var monitor = SelectMonitor;
		
		for (var key in monitor.selected) {
			if (monitor.selected.hasOwnProperty(key)) {
				console.info(monitor.selected[key]);
				$.each(monitor.selected[key], function(index) {
					if (this!= undefined){
						var el = $("#" + gen_element_id(this,key));
						monitor.removeItem(el);
					}
				});
				monitor.selected[key] = [];
			}
		}
		monitor.update();
	},
	select_element: function(el) {
		var $montior = SelectMonitor;
		el.addClass("file-select");
		el.attr("draggable","true");
		el.draggable({cursor: "move", zIndex:2700,
			cursorAt: { top: -12, left: -20 },helper: $montior.display_helper,stop: function( event, ui ) {$(ui.helper).fadeOut('fast');}}); //appendTo : '#browse-files',
	},
	deselect_element: function(el) {
		el.removeClass("file-select");
		el.removeAttr("draggable");
		//el.draggable("destroy");
	},
	update: function() {
		var count = this.item_count();
		var rename_el = $('button[data-value="rename"]');
		var box = $("#browse-box");
		if(count > 0) {
			if(!box.hasClass("selected")) {
				box.addClass("selected");
			}
			$("#browse-root-actions").children("span.filesize").html(filesize(this.size));
			$("#browse-root-actions").children("span.description").html(this.selected_text());
			
			if(count > 1){
				rename_el.parent().hide();
			}else{
				rename_el.parent().show();
			}
		}else {
			box.removeClass("selected");
		}
	},
	item_count: function() {
		var count = 0;
		for (var key in this.selected) {
    	if (this.selected.hasOwnProperty(key)) {
       count += this.selected[key].length;
    	}
		}
		return count;
		
	},
	selected_text: function() {
		var count = this.item_count();
		return(count + " Item" + ((count > 1) ? "s" : ""));
	}
	
	
};

function gen_element_id(id, model) {
	var model_words = model.split("_");
	var prefix = "";
	$.each(model_words, function(index) {
		prefix += this[0];
	});
	return (prefix + "_" + id);
}