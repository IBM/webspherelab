#!/bin/sh

# THIS PRODUCT CONTAINS RESTRICTED MATERIALS OF IBM
# 5655-V64 (C) COPYRIGHT International Business Machines Corp., 2009,2011
# All Rights Reserved * Licensed Materials - Property of IBM
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.

binDir=`dirname $0`

. "$binDir"/mwSetupCmdLine.sh

$AGENT_JAVA_HOME/bin/java  ${XDA_LOGGING} ${XDA_EXT_DIRS} -Dagent.home=${AGENT_HOME} com.ibm.ws.xd.agent.process.ManageServerProcess "$@" -action start

