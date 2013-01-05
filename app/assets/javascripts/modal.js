var Modal = {
	box: '',
	title_box: '',
	content_box: '',
	inner_box: '',
	overlay: '',
	behind: '',
	holding_area: '',
	vars : {},
	init: function(selector) {
		this.box = $('div#' + selector);
		this.icon = 
		this.title_box = $('#' + selector + "-title");
		this.content_box = $('#' + selector+ "-content");
		this.inner_box = $('div#' + selector + "-box");
		this.overlay = $('div#' + selector + "-overlay");
		this.behind = $('div#' + selector + "-behind");
		this.holding_area = $("div#" + selector + "-holding");
	},
	title: function(icon, title_contents) {
		var icon_el = $("<img />");
		icon_el.attr("src", "/assets/icon_spacer.gif");
		icon_el.addClass("sprite sprite_web " + icon + " modal-h-img" );
		this.title_box.empty();
		this.title_box.append(icon_el);
		this.title_box.append(title_contents);
	},
	content : function(contents) {
		this.holding_area.empty().append(this.content_box.html());
		this.content_box.empty().append(contents);
	},
	show: function () {//(icon_class, title, content, action, items) {
		/*this.vars['title'] = title;
		this.vars['content'] = content;
		if(action != null) {
			this.vars['action'] = action;
		}
		if(items != null) {
			this.vars['items'] = jQuery.extend(true, {}, items);
		}
		this.vars['icon'] = icon_class;*/
		// get the screen height and width
    // assign values to the overlay and dialog box
		$("#inline-upload-status").hide();
    this.overlay.show();
		this.box.show();
		//var p = this.box.position();
		//console.info(p);
		this.behind.css({height: this.box.height() + 20});
		this.behind.show();
   
		
     
    // display the message
		//var icon_el = $(this.box + '-title').find("img").clone();
		//icon_el.removeClass();
		//icon_el.addClass("sprite sprite_web s_web_" + this.vars['icon'] + "_32 modal-h-img");
		
   // $(this.box + ' h2.#modal-title').html('<div style="text-overflow":clip;"><img class="sprite sprite_web s_web_' + this.vars.icon + '_32 modal-h-img" src="/assets/icon_spacer.gif">' + this.vars.title + '</div>');
		//console.info(content);
		//$(this.box + '-content').empty().append(this.vars.content);
		
	},
	hide: function(event) {
		this.overlay.hide();
    	this.box.hide();
		this.behind.hide();
		var au = $("#advanced-upload-modal");
		if(au.find("ol#upload-files-list li").length > 0) {
			$("#inline-upload-status").show();
	}
		console.info($("#bulk-upload-status div.bulk-upload-info div.files-info").data());;
	},
	advanced_uploader : function(event) {
		var current_folder = $("#current_folder").val();
		var upload_template = $("#advanced-uploader").clone();
		upload_template.show();
		Modal.show("upload", "Upload to '" + current_folder + "'", upload_template,null ,null );
	},
	isVisible : function(){
		return !(Modal.box.is(":reallyhidden"));		
	}
	
};

$.extend(
   $.expr[":"],
   {
       reallyhidden: function (a) {
           var obj = $(a);
           while ((obj.css("visibility") == "inherit" && obj.css("display") != "none") && obj.parent()) {
               obj = obj.parent();
           }
           return (obj.css("visibility") == "hidden" || obj.css('display') == 'none');
       }
   }
 );