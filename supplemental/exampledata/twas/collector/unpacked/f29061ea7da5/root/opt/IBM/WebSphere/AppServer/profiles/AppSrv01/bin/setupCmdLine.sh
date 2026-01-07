#!/bin/sh
# @(#) 1.21 CFG/ws/code/profile.templates/src/bin/setupCmdLine.sh, WAS.config.base, WASX.CFG 5/8/06 13:29:35 [8/3/06 15:11:05]

WAS_USER_SCRIPT="/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin/setupCmdLine.sh"
export WAS_USER_SCRIPT
USER_INSTALL_ROOT="/opt/IBM/WebSphere/AppServer/profiles/AppSrv01"
WAS_HOME="/opt/IBM/WebSphere/AppServer"
#JAVA_HOME="$WAS_HOME"/java
# Assign JAVA_HOME via pluggable sdk architecture
. `dirname ${WAS_USER_SCRIPT}`/sdk/_setupSdk.sh
WAS_CELL=DefaultCell01
WAS_NODE=DefaultNode01

#ulimit -n 10000

OSGI_INSTALL="-Dosgi.install.area=$WAS_HOME"
OSGI_CFG="-Dosgi.configuration.area=$USER_INSTALL_ROOT/configuration"

ITP_LOC="$WAS_HOME"/deploytool/itp
CONFIG_ROOT="$USER_INSTALL_ROOT"/config

CLIENTSAS=-Dcom.ibm.CORBA.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/sas.client.props
STDINCLIENTSAS=-Dcom.ibm.CORBA.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/sas.stdinclient.props
SERVERSAS=-Dcom.ibm.CORBA.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/sas.server.props
CLIENTSOAP=-Dcom.ibm.SOAP.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/soap.client.props
CLIENTIPC=-Dcom.ibm.IPC.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/ipc.client.props
JAASSOAP=-Djava.security.auth.login.config="$USER_INSTALL_ROOT"/properties/wsjaas_client.conf
CLIENT_CONNECTOR_INSTALL_ROOT="$USER_INSTALL_ROOT"/installedConnectors
CLIENTSSL=-Dcom.ibm.SSL.ConfigURL=file:"$USER_INSTALL_ROOT"/properties/ssl.client.props
FFDCLOG="${USER_INSTALL_ROOT}"/logs/ffdc/
WAS_LOGGING="-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true"

QUALIFYNAMES=-qualifyHomeName
PATH="$JAVA_HOME"/ibm_bin:"$JAVA_HOME"/bin/:"$JAVA_HOME"/jre/bin:$PATH
WAS_EXT_DIRS="$JAVA_HOME"/lib:"$WAS_HOME"/classes:"$WAS_HOME"/lib:"$WAS_HOME"/installedChannels:"$WAS_HOME"/lib/ext:"$WAS_HOME"/web/help:"$ITP_LOC"/plugins/com.ibm.etools.ejbdeploy/runtime
WAS_CLASSPATH="$WAS_HOME"/properties:"$WAS_HOME"/lib/startup.jar:"$WAS_HOME"/lib/bootstrap.jar:"$WAS_HOME"/lib/lmproxy.jar:"$WAS_HOME"/lib/urlprotocols.jar:"$JAVA_HOME"/lib/tools.jar
WAS_JAVA_EXT_DIRS="$WAS_HOME"/javaext:"$JAVA_HOME"/lib/ext:"$JAVA_HOME"/jre/lib/ext

PLATFORM=`/bin/uname`
case $PLATFORM in

  AIX)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    NLSPATH=/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/en_US/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    if test "x$LIBPATH" = "x"; then
      LIBPATH="$WAS_HOME"/nulldllsdir
    fi 
    ;;

  Linux)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
    JAVA_HIGH_ZIPFDS=200
#    WAS_BOOTCLASSPATH=
    if test "x$LD_LIBRARY_PATH" = "x"; then
      LD_LIBRARY_PATH="$WAS_HOME"/nulldllsdir
    fi
    ;;

  SunOS)

    if [ "$LANG" = "" ]
    then
       LANG=C
       export LANG
    fi
    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    if test "x$LD_LIBRARY_PATH" = "x"; then
      LD_LIBRARY_PATH="$WAS_HOME"/nulldllsdir
    fi    
    ;;

  HP-UX)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    NLSPATH=/usr/lib/nls/msg/%L/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    if test "x$SHLIB_PATH" = "x"; then
      SHLIB_PATH="$WAS_HOME"/nulldllsdir
    fi 
    ;;

  *)

    WAS_LIBPATH="$JAVA_NATIVE_LIB_DIR":"$WAS_HOME"/bin
    NLSPATH=/usr/lib/locale/%L/LC_MESSAGES/%N:${NLSPATH:=}
#    WAS_BOOTCLASSPATH=
    ;;

esac

export PATH WAS_HOME WAS_CELL WAS_NODE JAVA_HOME ITP_LOC CLIENTSAS CLIENTSSL STDINCLIENTSAS SERVERSAS CLIENTSOAP CLIENT_CONNECTOR_INSTALL_ROOT WAS_LOGGING QUALIFYNAMES WAS_EXT_DIRS WAS_CLASSPATH CONFIG_ROOT NLSPATH JAVA_HIGH_ZIPFDS WAS_LIBPATH OSGI_INSTALL OSGI_CFG WAS_JAVA_EXT_DIRS

