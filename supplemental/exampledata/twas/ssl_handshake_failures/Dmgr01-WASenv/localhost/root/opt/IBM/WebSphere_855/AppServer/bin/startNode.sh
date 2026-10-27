#!/bin/sh

# All Rights Reserved * Licensed Materials - Property of IBM
# 5724-I63, 5724-H88, 5655-N01, 5733-W60 (C) COPYRIGHT International Business Machines Corp., 1997, 2010
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.

# Configuration Based Node Agent Launcher

# Launch Arguments:
#
# -script [script_file_name]
# -binaryData
# -nowait
# -quiet
# -trace
# -timeout <time>
# -statusport <port>
#

set_script_executable()
{
  scriptfile=start_$1.sh
  while [ "$#" -gt "0" ]
  do
    # check for -script option
    if [ "$1" = "-script" ]
    then
       # check the next argument for explicit script name
       if [ $# -gt "1" ]
       then
          shift
          # if the argument begins with "-", ignore it
          # because it is not a script file name
          if [ `echo "$1" | cut -c 1` != "-" ]
          then
             scriptfile="$1"
          fi
       fi
       # make sure the file does exist before setting exec permission
       if [ -f $scriptfile ]
       then
          chmod +x $scriptfile
       fi
    fi
    shift
  done
}

# Bootstrap values ...
APP_EXT_ID=com.ibm.ws.management.tools.WsServerLauncher

binDir=`dirname $0`
. $binDir/setupCmdLine.sh

#The following is added through defect 236497.1
CMD_NAME=`basename $0`

if [ -f ${JAVA_HOME}/bin/java ]; then
    JAVA_EXE="${JAVA_HOME}/bin/java"
else
    JAVA_EXE="${JAVA_HOME}/jre/bin/java"
fi

if [ "${INV_PRF_SPECIFIED:=}" != "" ] && [ "$INV_PRF_SPECIFIED" = "true" ]
then
    ${JAVA_EXE} -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" -cp "${WAS_HOME}/lib/commandlineutils.jar" com.ibm.ws.install.commandline.utils.CommandLineUtils -specifiedProfileNotExists -profileName $WAS_PROFILE_NAME
    exit 1
elif [ "${WAS_USER_SCRIPT_FILE_NOT_EXISTS:=}" != "" ] && [ "$WAS_USER_SCRIPT_FILE_NOT_EXISTS" = "true" ]
then
    ${JAVA_EXE} -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" -cp "${WAS_HOME}/lib/commandlineutils.jar" com.ibm.ws.install.commandline.utils.CommandLineUtils -wasUserScriptFileNotExists -wasUserScript $WAS_USER_SCRIPT
    exit 1
elif [ "${NO_DFT_PRF_EXISTS:=}" != "" ] && [ "$NO_DFT_PRF_EXISTS" = "true" ]
then
    ${JAVA_EXE} -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" -cp "${WAS_HOME}/lib/commandlineutils.jar" com.ibm.ws.install.commandline.utils.CommandLineUtils -noDefaultProfile -commandName $CMD_NAME
    exit 1
fi

# For debugging the launcher itself
# WAS_DEBUG="-Djava.compiler=NONE -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=7777"

#zOS
# "$JAVA_HOME"/bin/java -Dfile.encoding=ISO8859-1 -Xnoargsconversion \
#   $DEBUG \
#   -Dws.ext.dirs="$WAS_EXT_DIRS" \
#   $CONSOLE_ENCODING \
#   -Djava.ext.dirs="$JAVA_EXT_DIRS" \
#   -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" \
#   -classpath "$WAS_CLASSPATH" \
#   -Dwas.install.root="$WAS_HOME" \
#   -Dwas.serverstart.cell="$WAS_CELL" \
#   -Dwas.serverstart.node="$WAS_NODE" \
#   -Dwas.serverstart.server="nodeagent" \
#   $USER_INSTALL_PROP \
#   $JVM_EXTRA_CMD_ARGS \
#   com.ibm.ws.bootstrap.WSLauncher \
#   $APP_EXT_ID "$CONFIG_ROOT" "$WAS_CELL" "$WAS_NODE" "nodeagent" "$@"

#ASV
# "$JAVA_HOME"/bin/java \
#   $DEBUG \
#   -Dws.ext.dirs="$WAS_EXT_DIRS" \
#   -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" \
#   -classpath "$WAS_CLASSPATH" \
#   -Dwas.install.root="$WAS_HOME" \
#   -Dibm.websphere.preload.classes="true" \
#   $USER_INSTALL_PROP \
#   com.ibm.ws.bootstrap.WSLauncher \
#   $APP_EXT_ID "$CONFIG_ROOT" "$WAS_CELL" "$WAS_NODE" "nodeagent" -nodeagent "$@"

# Setup the initial java invocation;

DELIM=" "

#Common args...
D_NODEAGENT="nodeagent"
D_ARGS="-Dws.ext.dirs="$WAS_EXT_DIRS" $DELIM -Djava.endorsed.dirs="$WAS_ENDORSED_DIRS" $DELIM -Dwas.install.root="$WAS_HOME" $DELIM -Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager $DELIM -Djava.util.logging.configureByServer=true"

#Platform specific args...
PLATFORM=`/bin/uname`
case $PLATFORM in
  AIX)
    EXTSHM=ON
    LIBPATH="$WAS_LIBPATH":$LIBPATH
    export LIBPATH EXTSHM ;;
  Linux)
    LD_LIBRARY_PATH="$WAS_LIBPATH":$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH ;;
  SunOS)
    LD_LIBRARY_PATH="$WAS_LIBPATH":$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH ;;
  HP-UX)
    SHLIB_PATH="$WAS_LIBPATH":$SHLIB_PATH
    export SHLIB_PATH ;;
  OS/390)
    PATH="$PATH":$binDir
    export PATH
    D_ARGS=""$D_ARGS" $DELIM -Dfile.encoding=ISO8859-1 $DELIM -Djava.ext.dirs="$JAVA_EXT_DIRS""
    D_ARGS=""$D_ARGS" $DELIM -Dwas.serverstart.cell="$WAS_CELL""
    D_ARGS=""$D_ARGS" $DELIM -Dwas.serverstart.node="$WAS_NODE""
    D_ARGS=""$D_ARGS" $DELIM -Dwas.serverstart.server="nodeagent""
    X_ARGS="-Xnoargsconversion"
    D_NODEAGENT="nodeagent" ;;
esac

# Server-specific osgi config area:
OSGI_CFG=-Dosgi.configuration.area=$USER_INSTALL_ROOT/servers/$D_NODEAGENT


"$JAVA_HOME"/bin/java \
  "$OSGI_INSTALL" "$OSGI_CFG" \
  $X_ARGS \
  $CONSOLE_ENCODING \
  $WAS_DEBUG \
  $D_ARGS \
  -classpath "$WAS_CLASSPATH" \
  $USER_INSTALL_PROP \
  $JVM_EXTRA_CMD_ARGS \
  com.ibm.ws.bootstrap.WSLauncher \
  $APP_EXT_ID "$CONFIG_ROOT" "$WAS_CELL" "$WAS_NODE" "$D_NODEAGENT" -nodeagent "$@"

launchExit=$?
if [ "$launchExit" = "0" ]
then
  set_script_executable "$D_NODEAGENT" $@
fi
exit `expr $launchExit + $?`
