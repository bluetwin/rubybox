$(document).ready(function() {
$("#browse-search-input").bind("keyup", function() {
  var $this = $(this);
  var $form = $this.closest('form');
  if($this.val() == "") {
	$('#search_content').remove();
	$('#original_content').show();
  }	
  if( $this.val().length > 3) {
	  console.debug( $form);
	$.ajax({
  		url: "/live_search",
  		dataType: 'script',
		type: 'post',
 		data: $form.serialize(),
		beforeSend: function() {
			$this.addClass("loading");
		},
		complete: function(){
			$this.removeClass("loading"); // hide the spinner
		}	
	});
  }
}); 
});