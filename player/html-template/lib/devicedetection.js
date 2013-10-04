/***********************************************************
 * Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/
 
/**
 * Constructor
 * @param userAgent Override the default detection of the user agent
 */
function DeviceDetection(userAgent){
	/** Storage for callbacks */
	this.callbacks = new Array();
	/** Selected user agent */
	this.userAgent = userAgent && typeof(userAgent) == "string" ? userAgent : navigator.userAgent;
	/** Profiles list */
	this.profiles = [];
	/** Default profile */
	this.selectedProfile = this.profiles[0];
};

/**
 * Loads and parses JSON. If a 'successCallback' is not provided, the 
 * Expected format: <profile name="{string}" mobile="{boolean}" flash="{boolean}">{regex}</profile>
 * @param xml XML to process
 */
DeviceDetection.prototype.addProfiles = function(list){
	var len = list.settings.length;
	var value;
	var settings = {};
	for(var i = 0; i < len; i++){
		value = list.settings[i];
		settings[value.type] = {	quality: value.quality,
							flashenabled: value.flashenabled == "true",
							flashfirst: value.flashfirst == "true"};
	}
	len = list.profiles.length;
	for(var i = 0; i < len; i++){
		value = list.profiles[i];
		//generate a profile object
		profile = {	name: 	value.name,
					type: 	value.type,
					regex: 	value.regex};
		
		var quality = value.quality;
		switch(quality){
			case "hd":
			case "sd":
			case "mobile":
				profile.quality = quality;
			break;
			default:
				profile.quality = settings[profile.type] == null ? "sd" : settings[profile.type].quality;
			break;
		}
		
		profile.flashenabled = value.flashenabled == "undefined" ? settings[profile.type].flashenabled == "true" : value.flashenabled == "true";
		profile.flashfirst = value.flashfirst == "undefined" ? settings[profile.type].flashfirst == "true" : value.flashfirst == "true";
		this.addProfile(profile);
	}
	return this;
}

/**
 * Loads and parses XML. If a 'successCallback' is not provided, the 
 * Expected format: <profile name="{string}" mobile="{boolean}" flash="{boolean}">{regex}</profile>
 * @param xml XML to process
 */
DeviceDetection.prototype.loadProfilesXML = function(url, successCallback){
	if(!jQuery){
		if(console) console.error("Could not find jQuery.");
		return false;
	}
	//create a proxy so it can be accessed inside the jquery loop (each)
	var thisProxy = this;
	//use jquery to load the profiles xml
	$.get(url,
			function(data){ //result function
				var profile;
				var settings = {};
				$(data).find("setting").each(function(index){
					settings[$(this).attr("type")] = {	quality: $(this).attr("quality"),
												flashenabled: $(this).attr("flashenabled") == "true",
												flashfirst: $(this).attr("flashfirst") == "true"};
				});
				$(data).find("profile").each(function(index){ //loop over each profile
					//generate a profile object
					profile = {	name: 		$(this).attr("name"),
								type: 		$(this).attr("type"),
								regex: 		$(this).text()};
					
					var quality = $(this).attr("quality");
					switch(quality){
						case "hd":
						case "sd":
						case "mobile":
							profile.quality = quality;
						break;
						default:
							profile.quality = settings[profile.type] == null ? "sd" : settings[profile.type].quality;
						break;
					}
					
					profile.flashenabled = $(this).attr("flashenabled") == "undefined" ? settings[profile.type].flashenabled == "true" : $(this).attr("flashenabled") == "true";
					profile.flashfirst = $(this).attr("flashfirst") == "undefined" ? settings[profile.type].flashfirst == "true" : $(this).attr("flashfirst") == "true";
					thisProxy.addProfile(profile);
				});
				if(typeof(successCallback) == "function") successCallback(thisProxy);
			}, "xml");
}

/**
 * Adds a callback to handle the execute result
 */
DeviceDetection.prototype.addCallback = function(callback){
	if(typeof(callback) == "function"){
		this.callbacks.push(callback);
	}
	return this; //allow method chaining
}

/**
 * Executes processing of the userAgent
 */
DeviceDetection.prototype.detect = function(){
	var thisProxy = this;
	var len = this.profiles.length;
	var item;
	for(var i = 0; i < len; i++){
		item = this.profiles[i];
		if(thisProxy.userAgent.search(item.regex) != -1){
			this.selectedProfile = item;
			break;
		}
	}
	
	if(this.selectedProfile == null){
		//TODO handle this case
	}
	
	//Protect from user generated errors
	if(this.callbacks && typeof(this.callbacks) == "object" && this.callbacks.length > 0){
		var len = this.callbacks.length;
		for(var i = 0; i < len; i++){
			try{
				this.callbacks[i](this);
			}catch(error){
				if(console) console.log("[Error] " + error.message);
			}
		}
	}
	
	return this; //allow method chaining
};

/**
 * Set a specific profile to override the defaults
 * @param name Profile name
 * @param profile Object containing valid profile values
 */
DeviceDetection.prototype.addProfile = function(profile){
	if(typeof(profile) != "object"){
		if(console) console.error("Setting a profile requires a valid object.");
		return this; //object must be an Object
	}
	
	//TODO require all fields here?
	
	if(typeof(profile.regex) == "string"){
		profile.regex = new RegExp(profile.regex, "i"); //should we make the regex flags dynamic?
	}
	
	this.profiles.push(profile);
	
	return this;
}

//ACCESSORS

DeviceDetection.prototype.profileDetected = function(){
	return this.selectedProfile != null;
}

/**
 * Simple call to determine whether to use Flash or not
 */
DeviceDetection.prototype.useFlash = function(){
	if(this.flashFirst() && this.flashEnabled()) return true;
	else return this.flashEnabled();
}

DeviceDetection.prototype.getProfile = function(){ return this.selectedProfile; }
DeviceDetection.prototype.type = function(){ return this.profileDetected() ? this.selectedProfile.type : null; }
DeviceDetection.prototype.flashEnabled = function(){ return this.profileDetected() ? this.selectedProfile.flashenabled : null; }
DeviceDetection.prototype.flashFirst = function(){ return this.profileDetected() ? this.selectedProfile.flashfirst : null; }
DeviceDetection.prototype.isMobile = function(){ return this.profileDetected() ? this.selectedProfile.type == "mobile" : false; }