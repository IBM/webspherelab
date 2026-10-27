#!/bin/sh
binDir=`dirname ${0}`
. ${binDir}/setupCmdLine.sh
${WAS_HOME}/bin/startServer.sh "$@"
