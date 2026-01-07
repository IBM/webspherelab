#!/bin/sh

setWASHome()
{
    if [ "${REPLACE_WAS_HOME:=}" != "" ] && [ -d ${REPLACE_WAS_HOME} ]
    then
        WAS_HOME=${REPLACE_WAS_HOME}
    else
        CUR_DIR=`pwd`
        WAS_DIR=`dirname ${0}`/../
        cd "${WAS_DIR}"
        WAS_HOME=`pwd`
        cd "${CUR_DIR}"
    fi
}
setWASHome

. "$WAS_HOME/bin/sdk/_setupSdk.sh"

PLATFORM=`/bin/uname`
if [ "${FFDCLOG}:=" ]
then
    FFDCLOG="$WAS_HOME"/logs/ffdc/
fi

FSDB_PATH="$WAS_HOME/properties/fsdb"
if [ "$PLATFORM" != "OS/390" ]; then
  DEFAULT_PROFILE_REGISTRY_LOC="$WAS_HOME/properties/profileRegistry.xml"
  if [ ! -f ${DEFAULT_PROFILE_REGISTRY_LOC} ]; then
    FSDB_PATH=`$JAVA_HOME/jre/bin/java -classpath $WAS_HOME/lib/setup.jar com.ibm.ws.setup.SetupFsdbPath $WAS_HOME 2>/dev/null`
  fi
fi

DEFAULT_PROFILE_SCRIPT="$FSDB_PATH"/_was_profile_default/default.sh

ITP_LOC="$WAS_HOME"/deploytool/itp
PROFILE_REGISTRY_LOC="$FSDB_PATH"

ARCH=`/bin/uname -m`

CONFIG_ROOT="$WAS_HOME"/config
SERVERSAS=-Dcom.ibm.CORBA.ConfigURL=file:"$WAS_HOME"/properties/sas.server.props
CLIENT_CONNECTOR_INSTALL_ROOT="$WAS_HOME"/installedConnectors
WAS_LOGGING="-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true"

QUALIFYNAMES=-qualifyHomeName

WAS_PROFILE_NAME=
WAS_PROFILE_FSDB_SCRIPT=
NEXT_IS_PROFILE=0
for arg in "$@" ; do
    if [ $NEXT_IS_PROFILE -eq 1 ]; then
        WAS_PROFILE_NAME=$arg
        break
    fi
    if [ "$arg" = "-profileName" ]; then
        NEXT_IS_PROFILE=1
    fi
done

#Init INV_PRF_SPECIFIED, NO_DFT_PRF_EXISTS and WAS_USER_SCRIPT_FILE_NOT_EXISTS variables
NO_DFT_PRF_EXISTS=false
INV_PRF_SPECIFIED=false
WAS_USER_SCRIPT_FILE_NOT_EXISTS=false

if [ "${WAS_PROFILE_NAME:=}" != "" ]; then
    WAS_PROFILE_FSDB_SCRIPT=${PROFILE_REGISTRY_LOC}/${WAS_PROFILE_NAME}.sh
    if [ ! -f ${WAS_PROFILE_FSDB_SCRIPT} ]; then
       INV_PRF_SPECIFIED=true
    fi
elif [ "${WAS_USER_SCRIPT:=}" = "" ]; then
    WAS_PROFILE_FSDB_SCRIPT=${DEFAULT_PROFILE_SCRIPT}
    if [ ! -f ${WAS_PROFILE_FSDB_SCRIPT} ]; then
       NO_DFT_PRF_EXISTS=true
    fi
fi

if [ "${WAS_PROFILE_FSDB_SCRIPT:=}" != "" ] && [ -f ${WAS_PROFILE_FSDB_SCRIPT} ]; then
    . ${WAS_PROFILE_FSDB_SCRIPT}
fi

if [ "${WAS_USER_SCRIPT:=}" != "" ]; then
    if [ -f ${WAS_USER_SCRIPT} ]; then
        . $WAS_USER_SCRIPT
    elif [ "${INV_PRF_SPECIFIED:=}" = "false" ]; then
        WAS_USER_SCRIPT_FILE_NOT_EXISTS=true
    fi
fi

#Export INV_PRF_SPECIFIED, NO_DFT_PRF_EXISTS and WAS_USER_SCRIPT_FILE_NOT_EXISTS variables
export INV_PRF_SPECIFIED NO_DFT_PRF_EXISTS WAS_USER_SCRIPT_FILE_NOT_EXISTS

PATH="$JAVA_HOME"/ibm_bin:"$JAVA_HOME"/bin/:"$JAVA_HOME"/jre/bin:$PATH
WAS_EXT_DIRS="$JAVA_HOME"/lib:"$WAS_HOME"/classes:"$WAS_HOME"/lib:"$WAS_HOME"/installedChannels:"$WAS_HOME"/lib/ext:"$WAS_HOME"/web/help:"$ITP_LOC"/plugins/com.ibm.etools.ejbdeploy/runtime
WAS_CLASSPATH="$WAS_HOME"/properties:"$WAS_HOME"/lib/startup.jar:"$WAS_HOME"/lib/bootstrap.jar:"$JAVA_HOME"/lib/tools.jar:"$WAS_HOME"/lib/lmproxy.jar:"$WAS_HOME"/lib/urlprotocols.jar
WAS_ENDORSED_DIRS="$WAS_HOME"/endorsed_apis:"$JAVA_HOME"/jre/lib/endorsed
WAS_JAVA_EXT_DIRS="$WAS_HOME"/javaext:"$JAVA_HOME"/lib/ext:"$JAVA_HOME"/jre/lib/ext

DERBY_HOME="$WAS_HOME"/derby

case $PLATFORM in

  AIX)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/en_US/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    ;;

  Linux)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
    JAVA_HIGH_ZIPFDS=200
#    WAS_BOOTCLASSPATH=
    ;;

  SunOS)

    if [ "$LANG" = "" ]
    then
       LANG=C
       export LANG
    fi
    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    if [ $ARCH = "i86pc" ]
    then
      JVM_EXTRA_CMD_ARGS=-d64
    else
       file "$JAVA_NATIVE_LIB_DIR/libWs60ProcessManagement.so" | grep "ELF 64" > /dev/null
       if [ $? = 0 -a -d $JAVA_HOME/jre/bin/sparcv9 ];then
          JVM_EXTRA_CMD_ARGS=-d64
       fi
    fi

    ;;

  HP-UX)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/nls/msg/%L/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    if [ "$ARCH" = "ia64" ]
    then
      JVM_EXTRA_CMD_ARGS="-d64 -Djava.net.preferIPv4Stack=false"
    else
      JVM_EXTRA_CMD_ARGS=-Djava.net.preferIPv4Stack=false
    fi;;

  OS/390)

    LIBPATH=$LIBPATH:"$WAS_HOME"/patches:"$WAS_HOME"/lib/s390x-64:"$WAS_HOME"/lib/s390-31:"$WAS_HOME"/lib/s390-common
    WAS_LIBPATH="$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
    WAS_CLASSPATH="$WAS_CLASSPATH":"$WAS_HOME"/lib/bootstrapws390.jar
    JVM_EXTRA_CMD_ARGS="-Djava.security.properties=$WAS_HOME/properties/java.security"
#    WAS_BOOTCLASSPATH=
    ;;

  *)

    LIBPATH=$LIBPATH:"$WAS_HOME"/lib
    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    WAS_EXT_DIRS="$WAS_EXT_DIRS"
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    ;;

esac

OSGI_INSTALL="-Dosgi.install.area=$WAS_HOME"
OSGI_CFG="-Dosgi.configuration.area=$WAS_HOME/configuration"

export PATH WAS_HOME WAS_CELL WAS_NODE JAVA_HOME ITP_LOC SERVERSAS CLIENT_CONNECTOR_INSTALL_ROOT WAS_LOGGING QUALIFYNAMES WAS_EXT_DIRS WAS_CLASSPATH CONFIG_ROOT NLSPATH JAVA_HIGH_ZIPFDS WAS_LIBPATH JVM_EXTRA_CMD_ARGS LIBPATH OSGI_INSTALL OSGI_CFG WAS_ENDORSED_DIRS WAS_JAVA_EXT_DIRS

if [ "${USER_INSTALL_ROOT:=}" != "" ]; then
    if [ -d ${USER_INSTALL_ROOT} ]; then
        USER_INSTALL_PROP="-Duser.install.root=$USER_INSTALL_ROOT"
        WAS_CLASSPATH=${USER_INSTALL_ROOT}/properties:${WAS_CLASSPATH}
        OSGI_CFG="-Dosgi.configuration.area=$USER_INSTALL_ROOT/configuration"
	export USER_INSTALL_PROP WAS_CLASSPATH OSGI_CFG USER_INSTALL_ROOT
    fi
fi
