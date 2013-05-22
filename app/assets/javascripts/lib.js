function AssertException(message) { this.message = message; }
AssertException.prototype.toString = function () {
  return 'AssertException: ' + this.message;
}

function assert(exp, message) {
  if (!exp) {
    throw new AssertException(message);
  }
}


function timeLeft (seconds) {
  var date = new Date(seconds * 1000),
      days = parseInt(seconds / 86400, 10),
								left = '';
  if(seconds > 1) {
	days = days ? days + ' days ' : '';
	left = ('' + date.getUTCSeconds()).slice(-2) + " secs";
  }
  else {
	left = (seconds == 0 ? "" : "1 secs");
	days = '';
  }
	left = (('' + date.getUTCMinutes()).slice(-2) > 0) ? ('' + date.getUTCMinutes()).slice(-2) + " mins" : left;
	left = (('' + date.getUTCHours()).slice(-2) > 0) ? ('' + date.getUTCHours()).slice(-2) + " hours" : left;
	
    return days + left +(seconds ==0 ? "" : " left");
}
