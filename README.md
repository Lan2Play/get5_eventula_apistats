get5_eventula_apistats
===========================
[![GitHub Downloads](https://img.shields.io/github/downloads/Lan2Play/get5_eventula_apistats/total.svg?style=flat-square&label=Downloads)](https://github.com/Lan2Play/get5_eventula_apistats/releases/latest)

**Status: Supported, actively developed.**

Forked from [splewis'](https://github.com/splewis) [get5_apistats](https://github.com/splewis/get5/blob/master/scripting/get5_apistats.sp) plugin.

## CVARs
```
get5_eventula_apistats_url - Set's the server url to send the post request to
get5_eventula_apistats_key - Set's the server key which authenticates the server on the Api
get5_eventula_apistats_available - Checks if the plugin is correctly loaded on the server
```

## Download and Installation

### Requirements
You must have the get5 plugin installed on your Server. Check out the [Get5 Documentation](https://splewis.github.io/get5/installation/) 

### Download
Download a release package from the [releases section](https://github.com/Lan2Play/get5_eventula_apistats/releases/latest)

### Installation
tbc

## Building

You can use Docker to Build get5_eventula_apistats. At first you need to build the container image locally. Therefore go to the repository folder and run:

	docker build get5_eventula_apistats -t get5eventulaapistatsbuild:latest

Afterwards you can build get5_eventula_apistats with the following command: (specify /path/to/your/build/output and /path/to/your/get5src)

	docker run --rm -v $PWD:/get5src -v $PWD/build/output:/get5/builds get5eventulaapistatsbuild:latest
	
