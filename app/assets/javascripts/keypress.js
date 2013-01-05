$(document).ready(function() {
	
	$(document).keyup(function (e) {
   
		if (e.keyCode == 46) { // backspace key pressed
     		SelectMonitor.delete_selected();
    	}
		if (e.keyCode == 113) { // F2 key pressed
			SelectMonitor.rename();
		}
		if (e.keyCode == 27) { // esc key pressed
			SelectMonitor.deselect_all();
			SelectMonitor.cancel_edit();
		}
	});
	
});
