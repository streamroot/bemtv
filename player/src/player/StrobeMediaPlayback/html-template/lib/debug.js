if (typeof org == 'undefined') { var org = {}; }
if (typeof org.osmf == 'undefined') { org.osmf = {}; }
if (typeof org.osmf.player == 'undefined') { org.osmf.player = {}; }
if (typeof org.osmf.player.debug == 'undefined') { org.osmf.player.debug = {}; }

org.osmf.player.debug.filter = "StrobeMediaPlayback";
org.osmf.player.debug.propertyFilters = ["farID",  "rtmfpGroupspec", "multicastGroupspec"];


org.osmf.player.debug.logCount = 0;
 
org.osmf.player.debug.log = function(message){
    var re = new RegExp(org.osmf.player.debug.filter);
    var m = re.exec(message);
	if (m == null)
	{
		return;
	}
	
	setTimeout
	( 
		function(){
			org.osmf.player.debug.logCount++;
			var li = document.createElement("p");
		 	li.innerHTML = org.osmf.player.debug.logCount + ". " + message;
		 	var div = document.getElementById("logs");
		 	//div.appendChild(li);   			 	
		 	div.insertBefore(li, div.firstChild);
		 	if (div.childNodes.length>50)
		 	{
		 		div.removeChild(div.lastChild);
		 	}
		}
		, 1
	);				
}

org.osmf.player.debug.logs = function(logMessages){
  	var lines = logMessages.split("###");
	for (var i=0; i<lines.length; i++)
	{
		org.osmf.player.debug.log(lines[i]);	
	}			
}
   			 
org.osmf.player.debug.track = function(jss){
	setTimeout
	( 
		function(){
			var kvps = jss.split("###");
			var kvp;
			for (var i=0; i<kvps.length; i++)
			{
				kvp = kvps[i];				 	
			 	var kv = kvp.split("==");
				if (kv.length < 2)
				{
					continue;
				}
			 	//alert(kv);
			 	var cell = document.getElementById(kv[0]);
			 	if (cell != null)
			 	{
			 		// An element already exists. Replace it's value.
			 		cell.innerHTML = kv[1];
			 	}
			 	else
			 	{
			 		// Add a new element
			 		var ckv = kv[0].split("__");
			 		var panel = document.getElementById(ckv[0]);			 		
			 		if (panel)
			 		{
			 			org.osmf.player.debug.addProperty(panel, ckv[1], kv[0], kv[1]);				 		
			 		}
			 		else if (ckv[0] && ckv[0].length > 0)
			 		{
			 			// Create a new panel
			 			var table = document.createElement("table");
			 			var panel = document.createElement("tbody");
			 			table.appendChild(panel);
			 			panel.setAttribute("id", ckv[0]);
			 			panel.setAttribute("class", "new");
			 			var caption = document.createElement("caption");
			 			caption.innerHTML = ckv[0];
			 			panel.appendChild(caption);	
				 		org.osmf.player.debug.addProperty(panel, ckv[1], kv[0], kv[1]);
				 		document.getElementById("other").appendChild(panel);
			 		}
			 	}
			}
		},
		1
	);
}

org.osmf.player.debug.addProperty = function(panel, propertyName, propertyId, propertyValue)
{

	var originalValue = propertyValue; 
	if (org.osmf.player.debug.propertyFilters.indexOf(propertyName) >= 0)
	{
		// Filter out this property 
		//return;
		propertyValue = propertyValue.substring(0, 10) + " ...";
	}
	var tr = document.createElement("tr");
	var td1 = document.createElement("td");
	var td2 = document.createElement("td");
	td1.innerHTML = propertyName;
	td1.setAttribute("title", originalValue);
	td2.setAttribute("id", propertyId);
	td2.setAttribute("title", propertyName);
	td2.innerHTML = propertyValue;
	tr.appendChild(td1);
	tr.appendChild(td2);
	panel.appendChild(tr);	
}

org.osmf.player.debug.clickclear =  function(thisfield, defaulttext) {
	if (thisfield.value == defaulttext) {
		thisfield.value = "";
	}
}

org.osmf.player.debug.clickrecall = function(thisfield, defaulttext) {
		if (thisfield.value == "") {
			thisfield.value = defaulttext;
		}
		else
		{
			org.osmf.player.debug.filter = thisfield.value;
		}
	}
	
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(needle) {
        for(var i = 0; i < this.length; i++) {
            if(this[i] === needle) {
                return i;
            }
        }
        return -1;
    };
}