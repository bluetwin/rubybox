function toggle_history(id, speed) {
	$('#afhist' + id).slideToggle( speed);
}

function poll_data_files() {
	
	var progress_bars = $('div[id*="prg-df"]');
	var active = false;
	if ($('div[id*="prg-df"]')) {
		$('div[id*="prg-df"]').each(function(index) {
			
			var el = $("#" + this.id);
			//console.log(el);
			if(el.data("active")) {
   			var df_id = this.id.replace("prg-df","");
				data_File_status(df_id);
				active = true;
			}
		});
	}
	return active;
}



function data_File_status(id) {
	
	$.ajax({
      url: config.rails.root + "/data_files/" + id + "/status",
      type: "GET",
	  dataType : "script",
  	  success: function(response){
  		}
	});		
}


function select_all_data_files() {
	var checked = $('#select_all').is(':checked'); 
	$('input[name*="df_process"]').each(function(index) {
		var ele = $(this);
		ele.attr("checked",checked);
		if (checked) {
			ele.parent().addClass('checked');
		}
		else {
			ele.parent().removeClass('checked');
		}
	});
}

function set_progress_label(o, id, value) {
	var ele = $("#dfp_" + id);
	var child = ele.children();
	child.text(value + "% complete");
}

function process_selected() {
	$('input[name*="df_process"]').each(function(index) {
		var ele = $(this);	
		if(ele.is(':checked')) {
			//alert("processing Datafile " + this.id.replace("df_cbx_",""));
			process_file( this.id.replace("df_cbx_",""));
		}																		 
	});
	
}

function show_deleting(id) {
	$('#' + id).replaceWith("<span>deleting...<img src='/nimbus/images/ajax-loader.gif'></span>");
}
function deleting_data_file(id) {
	$('#process_file_#{data_file.id}').hide();
	show_deleting('delete_btn_#{data_file.id}');
	return true;
}



function toggle_checkbox(o) {
	var checked = !(o.is('checked'))
	o.attr("checked",checked);

}



function fetch_import_item(file) {
	$.ajax({
      url: config.rails.root + "/data_files/import_item/" + file.id,
	  	complete: function(data, textStatus, jqXHR) {
				$('#browse-files').prepend(data);
		 		//$("#process_btn_" + id).remove();
				//$('#fileprocesspool').prepend(data);
				$("#df_" + file.id).effect("highlight", {color:"#1F59AB"}, 3000);
	  	},
  	   success: function(data, textStatus, jqXHR){
				 $('#browse-files').prepend(data);
  		}
		});			
}

function display_loading_dialog(e, data) {
	$(".alert").remove();
	$.wl_Alert('Uploading File(s)..', 'info', '#title_footnotes', '#title_footnotes');
	$(".alert").delay(1000).fadeOut("fast");
}

function upload_complete_dialog(e, data) {
	/*$(".alert").remove();
	var file = $.parseJSON(data.result);
	file = file[0];
	$.wl_Alert('Files Successfully uploaded.', 'success', '#title_footnotes', '#title_footnotes');
	$(".alert").delay(2000).fadeOut("fast");*/
}
function objectToString(o){
    
    var parse = function(_o){
    
        var a = [], t;
        
        for(var p in _o){
        
            if(_o.hasOwnProperty(p)){
            
                t = _o[p];
                
                if(t && typeof t == "object"){
                
                    a[a.length]= p + ":{ " + arguments.callee(t).join(", ") + "}";
                    
                }
                else {
                    
                    if(typeof t == "string"){
                    
                        a[a.length] = [ p+ ": \"" + t.toString() + "\"" ];
                    }
                    else{
                        a[a.length] = [ p+ ": " + ((t != null) ? t.toString(): "")];
                    }
                    
                }
            }
        }
        
        return a;
        
    }
    
    return "{" + parse(o).join(", ") + "}";
    
}
function save_invoice_field_order(event, ui) {

 var fields = $('#sortable').sortable('serialize');
 $.ajax({
      url: "/sales_tax/update_invoice_field_order",
			type: "POST",
			data: fields,
	  beforeSend: function() {
		 
  	  },
	  complete: function() {
		  
	  },
  	   success: function(response){
				$.wl_Alert("Position Order Saved", 'success', "#sortable" ).delay(300);

  		}
	});		
	
}


function refresh_form(id, model) {
	$.ajax({
          	 type: "GET",
						 dataType: "script",
           	 url: '/' + model + '/' + id + "/edit",
						 beforeSend:  function() {
							 $("#division-content").hide();
						 		$("#ajax-content").show();
								},
             		complete: function(data, textStatus, jqXHR){
                 $("#ajax-content").html(data.responseText);
								 
                }
         });
}


function switch_client_check_out(e) {
	var client_id = $("#search_client_id").val();
	// update divisions
	update_list(client_id, e, "divisions");
	// update locations
	update_list(client_id, e, "locations");
	// update tax codes
	update_tax_codes(client_id);
	
}

function switchLocations(ms_obj) {
	var client_id = $("#" + ms_obj+ "_client_id").val();
	var divisions = $("#" + ms_obj + "_divisions").val();
	divisions = (divisions == null) ? [] : divisions;
	var el = $("#" + ms_obj + "_locations");
	var loading  = $("#loading-" + ms_obj  + "-locations");
	el.find('option').remove();
	el.multiselect('refresh');
	$.ajax({
      url: config.rails.root + "/locations/for_division/",
			type: "POST",
			data : { 'divisions' : divisions,
							 'client_id' : client_id },
    beforeSend: function() {
		 	el.multiselect("disable");
			loading.show();
  	  },
	  complete: function() {
		  el.multiselect('refresh');
			el.multiselect("enable");
			loading.hide();
	  },
  	   success: function(data, textStatus, jqXHR){
				
				var items = jQuery.parseJSON(data);
				
				$.each(items, function(index, value) { 
					 var number = value.number, name = value.name, opt = $('<option />', {
									 value: number,
									 text: name
						});
						opt.appendTo( el );
  			});
  		}
	});		
	
}

function update_list(client_id, element, model) {
	var id = "#" + element + "_" + model;
	var el = $(id);
	var loading  = $("#loading_" + element + "_" + model);
	el.find('option').remove();
	el.multiselect('refresh');
	 $.ajax({
      url: config.rails.root + "/" + model + "/list/" + client_id,
			type: "GET",
    beforeSend: function() {
		 	el.multiselect("disable");
			loading.show();
  	  },
	  complete: function() {
		  el.multiselect('refresh');
			el.multiselect("enable");
			loading.hide();
	  },
  	   success: function(data, textStatus, jqXHR){
				
				var items = jQuery.parseJSON(data);
				
				$.each(items, function(index, value) { 
					 var number = value.number, name = value.name, opt = $('<option />', {
									 value: number,
									 text: name
						});
						opt.appendTo( el );
  			});
  		}
	});		
	 
}





function update_tax_codes(client_id) {
	var el = $("#search_tax_code");
	el.find('option').remove();
	el.multiselect('refresh');
	 $.ajax({
      url: config.rails.root + "/client_tax_codes/list/" + client_id,
			type: "GET",
		
	  beforeSend: function() {
		 	el.multiselect("disable");
			$("#loading_tax_code").show();
  	  },
	  complete: function() {
		  el.multiselect('refresh');
			el.multiselect("enable");
			$("#loading_tax_code").hide();
	  },
  	   success: function(data, textStatus, jqXHR){
				var items = jQuery.parseJSON(data);
				$.each(items, function(index, value) { 
					 var id = value.id, code = value.code, opt = $('<option />', {
									 value: code,
									 text: code
						});
						opt.appendTo( el );
  			});
  		}
	});		
}

function readable_filesize(file) {
		if(file.size) {
			return filesize(file.size);
		}
		else {
			return '';
		}
}

function filesize(filesize) {
		if(filesize) {
			var size = filesize/1024; // Kilobytes
			return( (size > 1000) ? (filesize/1048576).toFixed(2) + "Mb" : size.toFixed(2) + "Kb");
		}
		else {
			return '';
		}
}


function hide_container(el) {
	$(el).hide();
}

function show_loading(el) {
	$(el).show();
	$(el).html("<%=image_tag('icons/ajax-loading.gif')%>");
}

function hide_show_loading( el_to_hide, el_show_loading) {
	hide_container(el_to_hide);
	show_loading(el_show_loading);
}
	
	
function move_division(lid, did) {
		console.info("prepare ajax for transfer "  + lid + " moving to " + did);
		$.ajax({
      url: config.rails.root + "/locations/" + lid + "/update_division",
			type: "put",
			method: "PUT",
			data : {_method : "PUT", 'id' : lid, 'location' : 
							{ division_id : did	}
						 },
  	   success: function(data, textStatus, jqXHR){
				// update division number
					var div_num = $("#drop-div-" + did).data("divisionNum");
					console.info("new division : " + div_num);
					$("#location-" + lid + " div:last-child").html(div_num);
					$("li#location-" + lid).effect("highlight", {}, 1000);
					refresh_location_table(did,lid);
			 }
	});		
}

function refresh_location_table(did,lid) {
	var active_div = $("#division_id").val();
	var old_div = $("#location-" + lid).data("locationDiv");
	console.info(active_div + " == " + did + " or " + old_div + " == " + active_div);
	if($("#division_id").val() == did || old_div == $("#division_id").val()) {
	$.ajax({
      url: config.rails.root + "/divisions/"+ did + "/facility_table",
			type: "get",
			data : {'id' : did},
			beforeSend: function() {
				$("#facility-list-container").html("<img id='facility-list' src='/assets/icons/ajax-loading.gif' />");
			},
  	   complete: function(data, textStatus, jqXHR){
				// update division number
				$("#facility-list-container").html(data.responseText);
			 }
	});		
	}
}

function remove_from_division(lid) {
		var loc_id = lid;
		$( "#dialog-confirm" ).dialog({
            resizable: false,
            height:200,
            modal: true,
            buttons: {
                "Remove from Division": function() {
									$.ajax({
      		url: config.rails.root + "/locations/" + loc_id + "/update_division",
					type: "put",
					method: "PUT",
					data : {_method : "PUT", 'id' : loc_id, 'location' : 
							{ division_id : '0'	}
						 },
  	   		complete: function(data, textStatus, jqXHR){
				// update division number
					$("#locations_for_division_" + lid).fadeOut('fast');
			 }
	});					$( this ).dialog( "close" );
								},
                Cancel: function() {
                    $( this ).dialog( "close" );
                }
            }
        });

	
}

function notify(msg, type) {
	var status = type;
	
	if(type != null) {
		status = type;
	}	
	if(type == 'warning') {
		status = "error";
	}
	console.info(msg  + ": " + status);
	$("#notify-msg").html(msg);
	$("span#notify").removeClass().addClass("server-" + status);
	$("#notify-wrapper").show();
	$("#notify-wrapper").delay(5000).fadeOut('slow');
}	

function check_for_messages() {
	if( $("span#notify-msg").text() != "")  {
		console.info($("span#notify-msg").text());
		msgs = $("span#notify-msg").text().split(":");
		$.each(msgs, function(index) {
			
			var parts = this.split(";");
			
			notify(parts[1],parts[0]);
		});
	}	
}

function centerTrim(text) {
	if(text.length > 24) {
		var req = text.substr(-7);
		text = text.slice(0,length-8);
		console.info(text);
		text = text.slice(0,17) + "..." + req;
		console.info(text);
	}
	return text;
}

function show_saving(model, id) {
	var input = $('form#edit_' + model + '_' + id + ' input#' + model + '_name');
	$("Saving...").insertAfter(input);
	input.hide();
	return true;
}
