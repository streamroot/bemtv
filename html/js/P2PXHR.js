/*
var peer5_options =
{
    downloadMode:”hybrid” or "p2p" or "http". default “hybrid”;
}
 */
peer5.Request =  function(peer5_options){
    peer5.Request.prototype = {
        /* -- Attributes -- */
        /*
        The readyState attribute must return the current state, which must be one of the following:
        UNSENT = 0 - Object has been constructed
        OPENED = 1 - The method open() has been properly envoked
        HEADERS_RECEIVED = 2 - All http headers and p2p fileInfo has been received
        LOADING = 3 - The response is being received
        DONE = 4 - The data transfer has been completed
         */
        this.readyState;

        /*
        The response attribute returns a reference to the response entity body
        if responseType is "blobUrl"
            return the blobUrl of the blob response entity body
         */
        this.response;

        /*
        Returns the response type
        Values are: empty string (default), "blobUrl",
         */
        this.responseType;

        /*
        Warning:Not implemented
         */
        this.timeout;

        /*
        Returns the current status of the request
        If an error occured returns:
         peer5.Request.SWARMID_NOT_FOUND_ERR = 650;
         peer5.Request.FILE_SIZE_ERR = 640;
         peer5.Request.FIREFOX_ONLY_SWARM_ERR = 641;
         peer5.Request.CHROME_ONLY_SWARM_ERR = 642;
         or HTTP status codes
         */
        this.status;

        /* -- Methods -- */
        /*
        id - either http url for uploading/downloading to/from a server,
        or a swarmId for p2p only case
        method: “GET” / “POST”
        e.g: peer5Request.open(“GET”,”images.google.com/img1.jpg”)
         */
        open: function(method, id) {},

        /*
        Warning: Not implemented
        e.g: (“range”,”5-10”)
         */
        setRequestHeader:function(header, value) {},

        /*
        sends the request and activates the peer5 process
        e.g: peer5Request.send()
         */
        send: function() {},

        /*
        Warning:Not implemented
        Available only when state >= 2
        content-length,content-range, content-disposition,last-modified
        see http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Responses
         */
        getResponseHeader:function(){},

        /*
        Warning:Not implemented
        Available only when state >=2
        content-length,content-range, content-disposition,last-modified
        see http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Responses
         */
        getAllResponseHeaders:function(){},

        /*
        returns: fileInfo object
         */
        getFileInfo:function(){},

        /*
        This method cancels the download, clears all connections, memory and objects
        offline storage remains
        options =
        {
            leaveSwarm:true or false. default false;
        }
        For example:
        to pause: keeps the connections, keeps the memory/objects, keeps offline storage call abort()
        to stop: terminates connections, memory/objects call abort({leaveSwarm:true})
        to resume in either case create a new request for the same swarmId/url.
        This method triggers the events onabort(),onloadend()
         */
        abort: function() {},


        /* -- EVENTS --
        These events are null and the user needs to set “listen” to them.
         */

        /*
        Dispatched when the readyState attribute is changed
        input: event
         */
        onreadystatechange: function(e) {},

        /*
        Dispatched once when the request starts
        input: progress event
         */
        onloadstart: function(e) {},

        /*
        Dispatched while sending and loading data: each time a p2p block is received and verified or bubbles up xhr’s onprogress
        input: progress event
         */
        onprogress: function(e) {},

        /*
        Dispatched when request was aborted, e.g: envoking abort()
        input: progress event
         */
        onabort: function(e) {},

        /*
        Dispatched when there was an error in the request which prevents it to continue.
        e.g: size of resource is too large, browser unsupported, CORS error, HTTP errors
        The status attribute returns the error number
        input: progress event
         */
        onerror:function(e) {},

        /*
        Dispatched when request was successfully completed
        input: progress event
        */
        onload:function(e) {},

        /*
        Warning: not implemented
        When a ‘timeout attribute’ amount of time has passed before the request could complete
         */
        ontimeout:function(e) {},

        /*
        Dispatched when request was completed (with or without success)
        input: progress event
         */
        onloadend:function(e) {},

        /*
        Dispatched when one of the parameters described in the event are changed
        input: swarm state event
        */
        onswarmstatechange:function(e){}
    }
}

/* -- Objects -- */
event =
{
    currentTarget:peer5RequestObject
}

/*
Inherits from event
 */
progressEvent =
{
    loaded:123, //number of bytes transfered
    loadedHTTP:23, //number of bytes transfered via HTTP
    loadedP2P:100, //number of bytes transfered via WebRTC
    lengthComputable:true, //If the length of the content is known, attribute is set to true
    total:1234, //If lengthComputable is true, total is set to content length
}

swarmStateEvent =
{
    numOfPeers:7 //number of peers connected to the client
}

fileInfo = {
    swarmId:"9t7e8dc1" //An id that uniquely identifies the content in the tracker
}

/*  --  Advanced options and methods    --  */
    /*
     peer5.DATACHANNELS_ERROR = 0;
     peer5.WEBSOCKETS_ERROR = 1;
     peer5.FILESYSTEM_ERROR = 2;

     return: Array of error numbers
    */
    peer5.getCompatabilityStatus = function(){};

    /*
    Warning: not impelemented
    only the options that are specified will be overwritten
    options:
    {
        inMemory:true or false; if set to true, Peer5 will not use any available disk but only RAM. Suitable for small files mostly. default false.
        spaceReqPrompt:true or false; - if set to true, when needed will request authorization to use diskspace, else size limit, firefox = 250MB, chrome = 10% free diskspace. default true.
        downLinkLimit:#; in bytes/seconds
        upLinkLimit:#; in bytes/seconds
    }
    */
    peer5.setGlobalOptions = function(options) {};


    /*
    Warning: not implemented
    Resource =
    {
        fileSize
        swarmId
        name?
        numOfBlocks
        numOfBlocksDownloaded
        status? (play,pause,stop)
    }
    resourceId - Either swarmId or url used when creating the resource
    */
    peer5.removeResource(resourceId)

    /*
    Warning: not implemented
    resources =
    {
        resourceId:Resource
    }
     cb(resources)
     */
    peer5.getAllLocalResources(cb)

    /*
    Warning: not implemented
    resourceId - Either swarmId or url used when creating the resource
    cb(resources) - only 1 resourceId in the resources object
     */
    peer5.getLocalResource(resourceId,cb)
