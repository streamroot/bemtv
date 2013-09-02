1. Logging and Conditional Compilation

Along with the introduction of the logging framework, the media framework also starts to use conditional employee. Currently, CONFIG::LOGGING is defined to include or exclude the TraceLogger as the default logger for the Log class. The rationale is that when an OSMF developer is developing a media player, the developer may need to have a logger by default, and when the development work is done, the default logger may become unnecessary. Excluding a default logger can decrease the size of the media player. 

By default, CONFIG::LOGGING is defined to be false for the downloadable binary. This can be considered a release version of the media framework. One may choose to set CONFIG::LOGGING to be true and build a debug version.

There are two ways to use the media framework. One is to include the OSMF.swc in the project. In this case, no special handling is needed for the OSMF application project. The other way is to include the source code of the media framework in the project. In this case, the developer needs to define CONFIG::LOGGING to be either true or false in the project setting. This must be done with both Flex Builder and Flash Authoring tool. Otherwise, a compilation error will occur.
