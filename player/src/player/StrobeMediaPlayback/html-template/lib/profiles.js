var profiles = {
	//Settings provide defaults for the profiles to reduce duplication for multiple profiles
	//for similar devices
	settings: [	{type: "desktop", quality: "hd", flashenabled: "true", flashfirst: "true"},
				{type: "tablet", quality: "sd", flashenabled: "false", flashfirst: "false"},
				{type: "smartphone", quality: "mobile", flashenabled: "false", flashfirst: "false"}
			],
	/*
		A profile is a device definition.
		
		name 	- a custom name for this specific profile; can be used in custom callbacks to customize experience
		type 	- desktop|smartphone|tablet //extra information for use in custom callbacks
		quality 	- hd|sd|mobile //suggested quality setting or initial quality in a VBR scenario
	*/
	profiles: [	{name: "ipad", type: "tablet", flashenabled: "false", regex: "ipad"},
				{name: "ipod", type: "smartphone", quality: "mobile", flashenabled: "false", regex: "ipod"},
				{name: "iphone", type: "smartphone", quality: "mobile", flashenabled: "false", regex: "iphone"},
				{name: "xoom", type: "tablet", quality: "sd", flashenabled: "true", flashfirst: "true", regex: "xoom"},
				{name: "sgt", type: "tablet", quality: "sd", flashenabled: "true", flashfirst: "true", regex: "gt\-p1000"},
				{name: "playbook", type: "tablet", quality: "sd", flashenabled: "true", flashfirst: "true", regex: "playbook"},
				{name: "android 2.2", type: "smartphone", quality: "sd", flashenabled: "true", flashfirst: "true", regex: "android 2\.2"},
				{name: "android", type: "smartphone", quality: "sd", flashenabled: "true", flashfirst: "true", regex: "android"},
				{name: "default", type: "desktop", quality: "hd", flashfirst: "true", flashenabled: "true", regex: ".*"}
			]
};