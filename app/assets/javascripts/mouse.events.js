$(document).ready(function() {
	var selects = "#original_content,#modal-box,#modal-behind,#modal-overlay,#browse-sort,#browse-root-actions,#new_folder_button";
	
	$(document).mousedown(function (e) {
	    var container = $("#user_dropdown");
  	 	if (!container.is(e.target) && container.has(e.target).length === 0)	
    	{
			container.hide();
    	}
	 	var container = $(selects);
	 	if (!container.is(e.target) && container.has(e.target).length === 0)
    	{
			$(".file-select").each(function() {
       			var el = $(this);
				SelectMonitor.removeItem(el);
    	    	el.removeClass("file-select");
				el.removeAttr("draggable");	
			});
			$(".browse-file div.filename-col form").each(function() {
				console.info("submitting form");
				console.info(this);
				$(this).submit();
			});
	    }
	});
	
});