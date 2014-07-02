#!/bin/bash
FLEXPATH=../../flex_sdk_4.6
#FLEXPATH=../../../apache_flex_sdk
#FLEXPATH=../../../AIRSDK_Compiler

COMMON_OPT="-library-path+=../lib/as3crypto.swc \
	-use-network=false \
	-optimize=true \
	-incremental=true \
	-static-link-runtime-shared-libraries=true"

echo "Compiling HLSProvider.swc"
$FLEXPATH/bin/compc \
	$COMMON_OPT \
	-include-sources ../src/org/mangui/HLS \
	-output ../lib/HLSProvider.swc \
	-target-player="10.1"

echo "Compiling HLSProvider5.swf"
$FLEXPATH/bin/mxmlc ../src/org/mangui/jwplayer/media/HLSProvider.as \
	-source-path ../src  \
	-o ../test/jwplayer5/HLSProvider5.swf \
	$COMMON_OPT \
	-library-path+=../lib/jw5 \
	-load-externs=../lib/jw5/jwplayer-5-classes.xml \
	-target-player="10.2"

echo "Compiling HLSProvider6.swf"
$FLEXPATH/bin/mxmlc ../src/org/mangui/jwplayer/media/HLSProvider6.as \
	-source-path ../src -o ../test/jwplayer6/HLSProvider6.swf \
	$COMMON_OPT \
	-library-path+=../lib/jw6 \
	-load-externs=../lib/jw6/jwplayer-6-classes.xml \
	-target-player="10.2"

echo "Compiling HLSProviderChromeless.swf"
$FLEXPATH/bin/mxmlc ../src/org/mangui/chromeless/ChromelessPlayer.as \
	-source-path ../src \
	-o ../test/chromeless/HLSProviderChromeless.swf \
	$COMMON_OPT \
	-library-path+=../lib/blooddy_crypto.swc \
	-target-player="11.1" \
	-default-size 480 270 \
	-default-background-color=0x000000


#echo "Compiling HLSProviderBasic.swf"
#$FLEXPATH/bin/mxmlc ../src/org/mangui/basic/Player.as \
#	-source-path ../src \
#	-o ../test/chromeless/HLSProviderBasic.swf \
#	$COMMON_OPT \
#	-target-player="11.1" \
#	-default-size 640 480 \
#	-default-background-color=0x000000

echo "Compiling HLSProviderFlowPlayer.swf"
$FLEXPATH/bin/mxmlc ../src/org/mangui/flowplayer/HLSPluginFactory.as \
	-source-path ../src -o ../test/flowplayer/HLSProviderFlowPlayer.swf \
	$COMMON_OPT \
	-library-path+=../lib/flowplayer \
	-load-externs=../lib/flowplayer/flowplayer-classes.xml \
	-target-player="11.1"

echo "Compiling HLSProviderOSMF.swf"
$FLEXPATH/bin/mxmlc ../src/org/mangui/osmf/plugins/HLSDynamicPlugin.as \
	-source-path ../src \
	-o ../test/osmf/HLSProviderOSMF.swf \
	$COMMON_OPT \
	-library-path+=../lib/osmf \
	-externs org.osmf.net.httpstreaming.HTTPNetStream \
	-target-player="10.1" #-compiler.verbose-stacktraces=true -link-report=../test/osmf/link-report.xml

echo "Compiling HLSProviderOSMF.swc"
$FLEXPATH/bin/compc -include-sources ../src/org/mangui/osmf \
	-output ../lib/HLSProviderOSMF.swc \
	$COMMON_OPT \
	-library-path+=../lib/HLSProvider.swc \
	-library-path+=../lib/osmf \
	-target-player="10.1" \
	-debug=false \
	-external-library-path+=../lib/osmf
