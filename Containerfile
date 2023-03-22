# Copyright 2023, 2023 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# ======
#
# Purpose: This is not designed for production usage but instead as a debugging
# and learning container.
#
# Notes:
#   * Minimize the number of RUN commands when finalizing a new version because
#     some builders have maximum layer restrictions.

# https://hub.docker.com/_/fedora
FROM docker.io/fedora:latest

LABEL maintainer="kevin.grigorenko@us.ibm.com"

# By default, the Fedora cloud image doesn't install man pages so we disable that and reinstall
# http://docs.projectatomic.io/container-best-practices/#_removing_documentation
RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf && \
    dnf reinstall -y "*" && \
    dnf install -y dnf-plugins-core && \
    dnf debuginfo-install -y \
      glibc
      # We don't install kernel-debuginfo because the underlying kernel won't match

# Notes on the packages:
# * Firefox crashes switching tabs with SIGBUS errors unless we use docker run --shm-size=...
#    https://bugzilla.mozilla.org/show_bug.cgi?id=1338771
RUN dnf install -y \
      arpwatch \
      at \
      atop \
      autoconf \
      bc \
      bcc-tools \
      bind-utils \
      bindfs \
      binwalk \
      bison \
      bison-devel \
      bless \
      bonnie++ \
      cmake \
      collectl \
      dbus-glib.i686 \
      dconf-editor \
      dia \
      dstat \
      e2fsprogs \
      emacs \
      evince \
      fatrace \
      file-devel \
      file-roller-nautilus \
      firefox \
      ftp \
      galculator \
      gcc \
      gcc-c++ \
      gdb \
      git \
      glances \
      gnome-calculator \
      gnupg \
      gnuplot \
      golang \
      gstreamer1-vaapi \
      gwenview \
      hostname \
      htop \
      httpd \
      iftop \
      ImageMagick \
      ioping \
      iotop \
      iperf \
      iperf3 \
      iptraf-ng \
      iproute-tc \
      iputils \
      java-1.8.0-openjdk \
      java-1.8.0-openjdk-devel \
      kcalc \
      kdesu \
      kernel-devel \
      kernel-headers \
      kexec-tools \
      less \
      libnsl \
      libnsl.i686 \
      libreoffice \
      llvm \
      lshw \
      lsof \
      ltrace \
      lzo \
      lzo-devel \
      lzo-minilzo \
      mailx \
      make \
      man \
      man-pages \
      maven \
      meld \
      mlocate \
      mousepad \
      mtr \
      multitail \
      ncdu \
      ncompress \
      ncurses \
      ncurses-devel \
      net-tools \
      nethogs \
      nfs-utils \
      nmap \
      nmap-ncat \
      nmon \
      npm \
      nss-pam-ldapd \
      numactl \
      openldap \
      openldap-clients \
      openldap-devel \
      openldap-servers \
      openssh-server \
      p7zip \
      pandoc \
      patch \
      perf \
      perl \
      php \
      powertop \
      psmisc \
      python3 \
      python3-devel \
      python3-matplotlib \
      python3-numpy \
      python3-pandas \
      python3-pip \
      python3-scipy \
      python3-statsmodels \
      python3-xlsxwriter \
      qt \
      R \
      R-devel \
      redhat-lsb.i686 \
      rsyslog \
      ruby \
      ruby-devel \
      rubygem-mysql2 \
      rubygem-rails \
      rust \
      scala \
      sendmail \
      sos \
      speedtest-cli \
      ssldump \
      supervisor \
      sysstat \
      strace \
      sudo \
      systemtap \
      tcpdump \
      telnet \
      tigervnc \
      tigervnc-server \
      totem \
      traceroute \
      tuned \
      util-linux \
      vim \
      wget \
      wireshark \
      wkhtmltopdf \
      xcalc \
      xeyes \
      @xfce \
      xfce4-calculator-plugin \
      xfce4-cpugraph-plugin \
      xfce4-diskperf-plugin \
      xfce4-netload-plugin \
      xfce4-notes-plugin \
      xfce4-sensors-plugin \
      xfce4-screensaver \
      xfce4-systemload-plugin \
      xrdp \
      xreader \
      xz

RUN sudo dnf remove -y xfce4-power-manager && \
    echo "# Install VS Code: https://code.visualstudio.com/docs/setup/linux" && \
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    printf '[code]\n\
name=Visual Studio Code\n\
baseurl=https://packages.microsoft.com/yumrepos/vscode\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://packages.microsoft.com/keys/microsoft.asc\n\
    ' | sudo tee /etc/yum.repos.d/vscode.repo && \
    sudo dnf install -y code && \
    echo "# Install some Node basics" && \
    sudo mkdir /opt/express && \
    sudo npm install --prefix /opt/express/ express --save && \
    printf "\n\
      const express = require('express')\n\
      const app = express()\n\
      const port = 3000\n\
      \n\
      app.get('/', (req, res) => res.send('Hello World!'))\n\
      \n\
      app.listen(port, () => console.log(`Example app listening on port ${port}!`))\n\
    " | sudo tee /opt/express/app.js && \
    printf '#!/bin/sh\n\
      echo "Starting server at http://localhost:3000/"\n\
      node /opt/express/app.js\n\
    ' | sudo tee /opt/express/run.sh && \
    sudo chmod a+x /opt/express/run.sh

RUN printf 'websphere' > /tmp/remotepassword

RUN dbus-uuidgen > /var/lib/dbus/machine-id && \
    echo "enforcing=0" | sudo tee -a /etc/security/pwquality.conf && \
    groupadd nogroup && \
    echo "###############################################" && \
    echo "# Create the script that can update passwords #" && \
    echo "###############################################" && \
    printf '#!/bin/sh\n\
      read password\n\
      echo "${password}" | sudo tee /root/password.txt\n\
      if [ "${password}" = "" ]; then\n\
        password=$(cat /dev/urandom | tr -dc "a-z0-9" | fold -w 8 | head -n 1)\n\
      fi\n\
      echo -n "${password}" | sudo sh -c "vncpasswd -f > /root/.vnc/passwd" || exit 1\n\
      echo "root:$(echo -n "${password}")" | sudo sh -c "chpasswd" || exit 1\n\
      echo -n "${password}" | sudo sh -c "vncpasswd -f > /home/was/.vnc/passwd" || exit 1\n\
      echo -n "${password}" | sudo sh -c "passwd --stdin was" || exit 1\n\
      sudo sed -i "s/password={SHA}.*/password={SHA}$(echo -n "${password}" | sha1sum | awk "{print \\$1}")/g" /etc/supervisord.conf || exit 1\n\
      sudo chmod 600 /root/.vnc/passwd || exit 1\n\
      sudo chmod -R go-rwx /home/was/.vnc || exit 1\n\
      sudo chown -R was:root /home/was/ || exit 1\n\
    \n' | sudo tee /usr/local/bin/setpassword.sh && chmod +x /usr/local/bin/setpassword.sh && \
    echo "######################################" && \
    echo "# Configure VNC, XRDP, and the users #" && \
    echo "######################################" && \
    echo "# For Remote Desktop issues with Java Swing rendering, use xserverbpp=24:" && \
    echo "# https://stackoverflow.com/a/37428300/1293660" && \
    echo "# Change the default of sudo to use -E and pass all environment variables" && \
    mkdir /root/.vnc && \
    mkdir /root/Desktop && \
    echo "startxfce4" > /root/.Xclients && \
    chmod +x /root/.Xclients && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    adduser -u 1001 -r -g 0 -m was && \
    usermod -a -G wheel was && \
    mkdir /home/was/.vnc && \
    mkdir /home/was/Desktop && \
    echo "startxfce4" > /home/was/.Xclients && \
    chmod +x /home/was/.Xclients && \
    sed -i 's/^%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    sed -i 's/^\(Defaults.*env_reset\)/#\1/g' /etc/sudoers && \
    mkdir /opt/programs/ && \
    sed -i 's/#xserverbpp=24/xserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/code=20/code=20\nxserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    printf '#!/bin/sh\n\
      unset SESSION_MANAGER\n\
      unset DBUS_SESSION_BUS_ADDRESS\n\
      exec xfce4-session\n\
    ' | sudo tee -a /root/.vnc/xstartup && \
    chmod a+x /root/.vnc/xstartup && \
    cp /root/.vnc/xstartup /home/was/.vnc/xstartup && \
    chown was:root /home/was/.vnc/xstartup && \
    echo "#####################" && \
    echo "# Configure rsyslog #" && \
    echo "#####################" && \
    sed -i 's/\(.*imjournal.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/\(.*SysSock.Use.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/imuxsock"/imuxsock")/g' /etc/rsyslog.conf && \
    echo "#########################" && \
    echo "# Configure supervisord #" && \
    echo "#########################" && \
    echo "# https://docs.docker.com/config/containers/multi-service_container/" && \
    printf '\n\
      [supervisord]\n\
      user=root\n\
      logfile=/dev/stdout\n\
      logfile_maxbytes=0\n\
      loglevel=info\n\
      pidfile=/var/run/supervisor/supervisord.pid\n\
      minfds=1024\n\
      minprocs=200\n\
      \n\
      [unix_http_server]\n\
      file=/var/run/supervisor/supervisor.sock\n\
      username=root\n\
      password={SHA}REPLACEPASSWORD\n\
      \n\
      [rpcinterface:supervisor]\n\
      supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface\n\
      \n\
      [supervisorctl]\n\
      serverurl=unix:///var/run/supervisor/supervisor.sock\n\
      \n\
      [include]\n\
      files=/etc/supervisord.d/*.supervisord.conf\n\
    ' | sudo tee /etc/supervisord.conf && \
    printf '\n\
      [program:rsyslog]\n\
      command=/usr/sbin/rsyslogd -n\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      priority=1\n\
    ' | sudo tee /etc/supervisord.d/rsyslog.supervisord.conf && \
    printf '\n\
      [program:xrdp]\n\
      command=/usr/sbin/xrdp -nodaemon\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      priority=20\n\
    ' | sudo tee /etc/supervisord.d/xrdp.supervisord.conf && \
    printf '\n\
      [program:xrdp-sesman]\n\
      command=/usr/sbin/xrdp-sesman --nodaemon\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      priority=25\n\
    ' | sudo tee /etc/supervisord.d/xrdp-sesman.supervisord.conf && \
    printf '\n\
      [program:ssh]\n\
      command=/usr/sbin/sshd -D\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      priority=30\n\
    ' | sudo tee /etc/supervisord.d/ssh.supervisord.conf && \
    printf '\n\
      [program:vncserver1]\n\
      command=/usr/bin/vncserver :1 -fg\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      startsecs=1\n\
      priority=50\n\
    ' | sudo tee /etc/supervisord.d/vncserver1.supervisord.conf && \
    printf '#!/bin/sh\n\
      sleep 5 # Try to avoid deadlock with the root VNC starting at the same time\n\
      /usr/sbin/runuser -l was -c "/usr/bin/vncserver :2 -fg"\n\
    ' | sudo tee /usr/local/bin/startvncwas.sh && \
    sudo chmod +x /usr/local/bin/startvncwas.sh && \
    printf '\n\
      [program:vncserver2]\n\
      command=/usr/local/bin/startvncwas.sh\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      startsecs=1\n\
      priority=51\n\
    ' | sudo tee /etc/supervisord.d/vncserver2.supervisord.conf && \
    printf '\n\
      [program:slapd]\n\
      command=/usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://"\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      priority=60\n\
      startsecs=0\n\
    ' | sudo tee /etc/supervisord.d/slapd.supervisord.conf && \
    echo "# Print environment variables inherited by supervisord-spawned programs" && \
    printf '#!/bin/sh\n\
      #/usr/bin/env\n\
    ' | sudo tee /usr/local/bin/debugsupervisord.sh && chmod a+rx /usr/local/bin/debugsupervisord.sh && \
    printf '\n\
      [program:debugsupervisord]\n\
      command=/usr/local/bin/debugsupervisord.sh\n\
      stdout_logfile=/dev/stdout\n\
      stdout_logfile_maxbytes=0\n\
      redirect_stderr=true\n\
      autorestart=false\n\
      startretries=0\n\
      startsecs=0\n\
      priority=1\n\
      user=was\n\
      environment=\n\
          HOME="/home/was",\n\
          USER="was",\n\
    ' | sudo tee /etc/supervisord.d/debugsupervisord.supervisord.conf && \
    sudo mkdir -p /var/run/supervisor/ && \
    echo "# If a CMD is specified or a program through docker run," && \
    echo "# then start supervisord in the background and run the CMD." && \
    echo "# Otherwise (the default), run supervisord in the foreground." && \
    echo "# This is required to run as root to properly inherit core" && \
    echo "# dump ulimits, so child containers must always go back to" && \
    echo "# USER root before ENTRYPOINT/CMD is run. Attempted" && \
    echo "# with sudo but ulimits don't pass through." && \
    printf '#!/bin/sh\n\
      ssh-keygen -A || exit 1\n\
      \n\
      if [ -e /usr/local/bin/extended_entrypoint.sh ]; then\n\
        chmod a+x /usr/local/bin/extended_entrypoint.sh\n\
        /usr/local/bin/extended_entrypoint.sh || exit 1\n\
      fi\n\
      \n\
      if [ "$#" -gt 0 ]; then\n\
        supervisord -c /etc/supervisord.conf &> /var/log/supervisord.log || exit 1 &\n\
        exec "$@" || exit 1\n\
      else\n\
        supervisord -n -c /etc/supervisord.conf || exit 1\n\
      fi\n\
      \n\
      #Old code when CMD was added as a supervised program\n\
      #if [ "$#" -gt 0 ]; then\n\
      #  printf "[program:cmd]\\ncommand=$@\\nstdout_logfile=/dev/stdout\\nstdout_logfile_maxbytes=0\\nredirect_stderr=true\\n" | tee /etc/supervisord.d/cmd.supervisord.conf > /dev/null\n\
      #fi\n\
      #supervisord -n -c /etc/supervisord.conf || exit 1\n\
    ' | sudo tee -a /usr/local/bin/entrypoint.sh && chmod a+rx /usr/local/bin/entrypoint.sh && \
    echo "######################" && \
    echo "# XFCE configuration #" && \
    echo "######################" && \
    echo "# polkit crashes on login. There is a discussion on the Fedora mailing list with" && \
    echo "# the only workaround being to start vncserver through SSH. Removing it" && \
    echo "# from startup doesn't seem to hurt too much." && \
    mv /etc/xdg/autostart/xfce-polkit.desktop /etc/xdg/autostart/xfce-polkit.desktop.disabled && \
    echo "#############" && \
    echo "# Utilities #" && \
    echo "#############" && \
    echo "# https://ant.apache.org/" && \
    ( \
      cd /opt/ && \
      sudo wget -q https://www.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.zip && \
      sudo unzip -q apache-ant*.zip && \
      sudo rm -f apache-ant*.zip && \
      sudo mv apache-ant* apache-ant \
    ) && \
    echo "# https://github.com/brendangregg/FlameGraph" && \
    sudo git clone https://github.com/brendangregg/FlameGraph /opt/FlameGraph && \
    echo "# https://github.com/nmonvisualizer/nmonvisualizer" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/nmonvisualizer/nmonvisualizer && \
      cd /opt/nmonvisualizer/ && \
      sudo ANT_OPTS=-Dfile.encoding=iso-8859-1 /opt/apache-ant/bin/ant && \
      sudo mv NMONVisualizer*.jar NMONVisualizer.jar && \
      sudo mkdir /home/was/nmon/ && \
      sudo chown -R was:root /home/was/nmon/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=NMON Visualizer\nExec=java -jar /opt/nmonvisualizer/NMONVisualizer.jar\nPath=nmon/\nTerminal=false\n' >> nmonvisualizer.desktop && \
      sudo chmod a+x nmonvisualizer.desktop && \
      sudo ln -s /opt/nmonvisualizer/nmonvisualizer.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/nmonvisualizer.desktop /home/was/Desktop/ \
    ) && \
    echo "# https://www.ibm.com/support/pages/node/72419" && \
    ( \
      sudo mkdir /opt/linperf/ && \
      cd /opt/linperf/ && \
      sudo wget -q -O linperf.sh "https://www.ibm.com/support/pages/system/files/inline-files/linperf.sh" && \
      sudo chmod a+x linperf.sh \
    ) && \
    echo "# https://jmeter.apache.org/" && \
    ( \
      cd /opt/ && \
      sudo wget -q https://www.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.3.zip && \
      sudo unzip -q apache-jmeter*.zip && \
      sudo rm -f apache-jmeter*.zip && \
      sudo mv apache-jmeter* apache-jmeter && \
      cd /opt/apache-jmeter/ && \
      sudo mkdir /home/was/jmeter/ && \
      sudo chown -R was:root /home/was/jmeter/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=JMeter\nExec=/opt/apache-jmeter/bin/jmeter\nPath=jmeter/\nTerminal=false\n' >> jmeter.desktop && \
      sudo chmod a+x jmeter.desktop && \
      sudo ln -s /opt/apache-jmeter/jmeter.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/jmeter.desktop /home/was/Desktop/ && \
      cd /opt/apache-jmeter/lib/ext && \
      sudo wget -q https://bitbucket.org/pjtr/jmeter-websocket-samplers/downloads/JMeterWebSocketSamplers-1.2.1.jar \
    ) && \
    echo "# https://github.com/iovisor/bcc" && \
    echo "# https://github.com/iovisor/bcc/issues/281" && \
    echo "# https://github.com/iovisor/bcc/pull/279/commits/c48f9d9c3d438e839eb2bfe0a2ed1a321b4e946d" && \
    echo "# Some kernels don't have CONFIG_TRACING=y CONFIG_EVENT_TRACING=y, so memleak.py won't work:" && \
    echo "# https://github.com/iovisor/bcc/issues/1530" && \
    sudo git clone https://github.com/iovisor/bcc /opt/bcc && \
    echo "# Some Docker hosts run a different kernel than what gets installed above. The following hack" && \
    echo "# won't always work but it might for some cases (e.g. bcc)." && \
    echo "# Useless anyway without CONFIG_TRACING, so don't bother with the hack." && \
    echo "# See https://github.com/iovisor/bcc/issues/1000" && \
    echo "# We have to stay below Gradle V5 for deprecated/removed Gradle features used by older projects" && \
    ( \
      cd /opt/ && \
      sudo wget -q -O gradle.zip https://services.gradle.org/distributions/gradle-4.10.3-bin.zip && \
      sudo unzip -q gradle.zip && \
      sudo rm -f gradle.zip \
    ) && \
    sudo ln -s /opt/gradle-4.10.3/bin/gradle /usr/local/bin/gradle && \
    echo -n "$(sudo head -n 1 /tmp/remotepassword)" | /usr/local/bin/setpassword.sh && \
    echo "############################" && \
    echo "# Final user configuration #" && \
    echo "############################" && \
    echo "# root's Desktop cannot take links (it doesn't work in this image seemingly because of some D-Bus/XFCE issue)" && \
    sudo chmod a+x /usr/share/applications/firefox.desktop && \
    sudo ln -s /usr/share/applications/firefox.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/org.xfce.mousepad.desktop && \
    sudo ln -s /usr/share/applications/org.xfce.mousepad.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/org.wireshark.Wireshark.desktop && \
    sudo ln -s /usr/share/applications/org.wireshark.Wireshark.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/galculator.desktop && \
    sudo ln -s /usr/share/applications/galculator.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/libreoffice-calc.desktop && \
    sudo ln -s /usr/share/applications/libreoffice-calc.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/libreoffice-writer.desktop && \
    sudo ln -s /usr/share/applications/libreoffice-writer.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/code.desktop && \
    sudo ln -s /usr/share/applications/code.desktop /home/was/Desktop/ && \
    echo "# Strange error trying to launch Wireshark:" && \
    echo "# error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory" && \
    echo "# https://superuser.com/questions/1347723/" && \
    sudo strip --remove-section=.note.ABI-tag /usr/lib64/libQt5Core.so.5 && \
    echo "# Allow the was user to perform Wireshark captures:" && \
    sudo usermod -a -G wireshark was && \
    echo "# Cannot set background before logging in" && \
    printf '#!/bin/sh\n\
      xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 0\n\
    \n' > /home/was/Desktop/reset_desktop_background.sh && chmod a+x /home/was/Desktop/reset_desktop_background.sh && \
    echo "# Set the default browser" && \
    sudo mkdir -p /root/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /root/.config/xfce4/helpers.rc && \
    sudo mkdir -p /home/was/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /home/was/.config/xfce4/helpers.rc && \
    sudo chown -R was:root /home/was/ && \
    echo "################" && \
    echo "# Finalization #" && \
    echo "################" && \
    echo "# Set the default PDF reader to xreader; otherwise, the default" && \
    echo "# becomes LibreOffice Draw which isn't a great PDF viewer." && \
    xdg-mime default evince.desktop application/pdf && \
    echo "# cn=Manager,dc=example,dc=com" && \
    sed -i 's/my-domain/example/g' /usr/share/openldap-servers/slapd.ldif && \
    mkdir -p /var/lib/ldap && \
    rm -rf /etc/openldap/slapd.d/* && \
    slapadd -n 0 -F /etc/openldap/slapd.d -l /usr/share/openldap-servers/slapd.ldif && \
    chown -R ldap:ldap /var/lib/ldap && \
    echo "olcAllows: bind_v2 update_anon" >> '/etc/openldap/slapd.d/cn=config.ldif' && \
    echo "olcLogFile: /var/log/slapd.log" >> '/etc/openldap/slapd.d/cn=config.ldif' && \
    printf 'dn: olcDatabase={2}mdb,cn=config\n\
changetype: modify\n\
replace: olcRootPW\n\
olcRootPW: %s\n\
\n' "$(slappasswd -s "$(echo -n "$(sudo head -n 1 /root/password.txt)")")" | sudo tee /root/openldapadminpwd.ldif && \
    printf 'dn: dc=example,dc=com\n\
objectclass: dcObject\n\
objectclass: organization\n\
o: Example Company\n\
dc: example\n\
\n\
dn: cn=Manager,dc=example,dc=com\n\
objectclass: organizationalRole\n\
cn: Manager\n\
\n' | sudo tee /root/openldapmanager.ldif && \
    echo "Starting slapd" && \
    sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    echo "Running ldapmodify /root/openldapadminpwd.ldif" && \
    cat /root/openldapadminpwd.ldif && \
    sudo ldapmodify -H ldapi:// -Y EXTERNAL -f /root/openldapadminpwd.ldif && \
    echo "Running ldapadd for /root/openldapmanager.ldif" && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/openldapmanager.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/cosine.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/nis.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/inetorgperson.ldif && \
    printf 'dn: ou=Users,dc=example,dc=com\n\
objectClass: organizationalUnit\n\
ou: Users\n\
\n\
dn: cn=Admin1,ou=Users,dc=example,dc=com\n\
cn: Admin1\n\
sn: Admin1\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: Admin1\n\
\n\
dn: cn=User2,ou=Users,dc=example,dc=com\n\
cn: User2\n\
sn: User2\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: User2\n\
\n\
dn: cn=User3,ou=Users,dc=example,dc=com\n\
cn: User3\n\
sn: User3\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: User3\n\
\n\
dn: ou=Groups,dc=example,dc=com\n\
objectClass: organizationalUnit\n\
ou: Groups\n\
\n\
dn: cn=Administrators,ou=Users,dc=example,dc=com\n\
cn: Administrators\n\
objectClass: groupOfNames\n\
member: cn=Admin1,ou=Users,dc=example,dc=com\n\
\n\
dn: cn=Group1,ou=Users,dc=example,dc=com\n\
cn: Group1\n\
objectClass: groupOfNames\n\
member: cn=User2,ou=Users,dc=example,dc=com\n\
member: cn=User3,ou=Users,dc=example,dc=com\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /root/basicorg.ldif && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/basicorg.ldif && \
    echo "# Configure logging: https://www.openldap.org/doc/admin24/slapdconfig.html#loglevel%20%3Clevel%3E" && \
    printf 'dn: cn=config\n\
changetype: modify\n\
replace: olcLogLevel\n\
olcLogLevel: stats stats2\n\
\n\
dn: olcDatabase={2}mdb,cn=config\n\
changetype: modify\n\
add: olcDbMaxSize\n\
olcDbMaxSize: 1073741824\n\
\n' | sudo tee /root/openldaploggingdb.ldif && \
    sudo ldapmodify -H ldapi:// -Y EXTERNAL -f /root/openldaploggingdb.ldif && \
    echo "local4.* /var/log/slapd.log" | sudo tee -a /etc/rsyslog.conf

RUN sudo touch /tmp/tmp.log && \
    sudo chmod a+rw /tmp/tmp.log && \
    printf '#!/bin/sh\n\
      echo "Starting /usr/local/bin/xinit.sh at $(date)" >> /tmp/tmp.log\n\
      sleep 30\n\
      xset s 7200 7200 >> /tmp/tmp.log 2>&1\n\
      echo "Finished /usr/local/bin/xinit.sh at $(date)" >> /tmp/tmp.log\n\
    ' | sudo tee /usr/local/bin/xinit.sh && \
    sudo chmod a+x /usr/local/bin/xinit.sh && \
    mkdir -p /home/was/.config/autostart && \
    printf '[Desktop Entry]\nType=Application\nName=Xinit\nExec=/usr/local/bin/xinit.sh\nPath=~/\nTerminal=false\n' >> /home/was/.config/autostart/xinit.desktop && \
    mkdir -p /home/was/.config/gtk-3.0/ && \
    printf 'tooltip { opacity: 0; }\n' > /home/was/.config/gtk-3.0/gtk.css && \
    chown -R was:root /home/was/.config/gtk-3.0/ && \
    echo "# Weird issue with xfce4-screensaver where pam_unix doesn't work, so just always allow with pam_succeed_if" && \
    sed -i '1 i\auth sufficient pam_succeed_if.so user = was' /etc/pam.d/xfce4-screensaver && \
    mkdir -p /home/was/.config/xfce4/xfconf/xfce-perchannel-xml/ && \
    printf '<?xml version="1.0" encoding="UTF-8"?>\n\
      <channel name="xfce4-screensaver" version="1.0">\n\
        <property name="saver" type="empty">\n\
          <property name="mode" type="int" value="2"/>\n\
          <property name="idle-activation" type="empty">\n\
            <property name="delay" type="int" value="120"/>\n\
          </property>\n\
          <property name="themes" type="empty">\n\
            <property name="list" type="array">\n\
              <value type="string" value="screensavers-xfce-popsquares"/>\n\
            </property>\n\
          </property>\n\
        </property>\n\
      </channel>\n\
    ' > /home/was/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml && \
    echo "Don't auto-start xscreensaver or otherwise the xfce4-screensaver lock gets locked out after a while: https://bugzilla.xfce.org/show_bug.cgi?id=16140" && \
    sudo rm -rf /etc/xdg/autostart/xscreensaver* && \
    sudo rm -f /usr/share/applications/xscreensaver-properties.desktop

# Query file mimetype: xdg-mime query filetype $FILE
RUN xdg-mime default xreader.desktop application/pdf && \
    xdg-mime default mousepad.desktop text/x-log && \
    xdg-mime default mousepad.desktop text/plain

# Random tips:
# * List all available Gnome settings: gsettings list-recursively
# * List all available Xfce settings: for i in $(xfconf-query -l | grep -v Channels); do xfconf-query -c $i -l -v; done
# * Available vncserver options: vncserver --help; Xvnc --help

####################
# Install IBM Java #
####################

# https://github.com/ibmruntimes/ci.docker/blob/master/ibmjava/8/sdk/ubuntu/Dockerfile
COPY --from=docker.io/ibmjava:8-sdk /opt/ibm/java /opt/ibm/java

########################
# Put IBM Java on PATH #
########################

RUN echo "# https://fedoraproject.org/wiki/Alternatives_system" && \
    sudo alternatives --install \
         /usr/bin/java java /opt/ibm/java/bin/java 99999999 \
         --slave /usr/bin/javac javac /opt/ibm/java/bin/javac \
         --slave /usr/bin/jar jar /opt/ibm/java/bin/jar \
         --slave /usr/bin/javah javah /opt/ibm/java/bin/javah \
         --slave /usr/bin/javap javap /opt/ibm/java/bin/javap \
         --slave /usr/bin/javadoc javadoc /opt/ibm/java/bin/javadoc \
         --slave /usr/bin/javaws javaws /opt/ibm/java/bin/javaws \
         --slave /usr/bin/jconsole jconsole /opt/ibm/java/bin/jconsole \
         --slave /usr/bin/jdmpview jdmpview /opt/ibm/java/bin/jdmpview \
         --slave /usr/bin/keytool keytool /opt/ibm/java/bin/keytool \
         --slave /usr/bin/jdb jdb /opt/ibm/java/bin/jdb \
         --slave /usr/bin/ControlPanel ControlPanel /opt/ibm/java/bin/ControlPanel \
         --family ibmjava && \
    sudo alternatives --auto java && \
    echo "###############" && \
    echo "# Install MAT #" && \
    echo "###############" && \
    echo "# Eclipse Memory Analyzer Tool (MAT)" && \
    echo "# https://www.eclipse.org/mat/" && \
    sudo mkdir -p /opt/mat/ibmjava/ && \
    sudo mkdir -p /opt/mat/openj9/ && \
    sudo wget -q -O /opt/mat/ibmjava/mat.tar.gz https://public.dhe.ibm.com/software/websphere/appserv/support/tools/iema/com.ibm.java.diagnostics.memory.analyzer.MemoryAnalyzer.openj9-linux.gtk.x86_64.tar.gz && \
    sudo wget -q -O /opt/mat/openj9/mat-openj9.tar.gz https://public.dhe.ibm.com/software/websphere/appserv/support/tools/iema/com.ibm.java.diagnostics.memory.analyzer.MemoryAnalyzer-linux.gtk.x86_64.tar.gz && \
    ( \
      cd /opt/mat/ibmjava/ && \
      sudo tar xzf mat.tar.gz && \
      sudo rm -f mat.tar.gz && \
      cd /opt/mat/openj9/ && \
      sudo tar xzf mat-openj9.tar.gz && \
      sudo rm -f mat-openj9.tar.gz && \
      sudo mkdir -p /home/was/mat/ibmjava/ && \
      sudo mkdir -p /home/was/mat/openj9/ && \
      sudo chown -R was:root /home/was/mat/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT (IBM Java)\nExec=/opt/mat/ibmjava/MemoryAnalyzer -data matibmjavaworkspace -vm /opt/openjdk11_ibm/jdk/bin/\nPath=mat/ibmjava/\nTerminal=false\n' >> /opt/mat/ibmjava/mat.desktop && \
      sudo chmod a+x /opt/mat/ibmjava/mat.desktop && \
      sudo ln -s /opt/mat/ibmjava/mat.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/mat.desktop /home/was/Desktop/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT (IBM Semeru)\nExec=/opt/mat/openj9/MemoryAnalyzer -data matopenj9workspace -vm /opt/openjdk11_ibm/jdk/bin/\nPath=mat/openj9/\nTerminal=false\n' >> /opt/mat/openj9/mat-openj9.desktop && \
      sudo chmod a+x /opt/mat/openj9/mat-openj9.desktop && \
      sudo ln -s /opt/mat/openj9/mat-openj9.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/mat-openj9.desktop /home/was/Desktop/ \
    ) && \
    sudo mkdir -p /home/was/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown -R was /home/was/matibmjavaworkspace/ && \
    sudo mkdir -p /root/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    printf 'bytes_display=Smart\n\
eclipse.preferences.version=1\n\
hideGettingStartedWizard=false\n\
hide_welcome_screen=true\n\
' > /home/was/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    sudo cp /home/was/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs /root/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown root /home/was/matibmjavaworkspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    sudo mkdir -p /home/was/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown -R was /home/was/matopenj9workspace/ && \
    sudo mkdir -p /root/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    printf 'bytes_display=Smart\n\
eclipse.preferences.version=1\n\
hideGettingStartedWizard=false\n\
hide_welcome_screen=true\n\
' > /home/was/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    sudo cp /home/was/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs /root/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown root /home/was/matopenj9workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    echo "# Increase the default max heap size" && \
    sudo sed -i 's/-Xmx1024m/-Xmx2g/g' /opt/mat/ibmjava/MemoryAnalyzer.ini && \
    sudo sed -i 's/-Xmx1024m/-Xmx2g/g' /opt/mat/openj9/MemoryAnalyzer.ini && \
    echo "# IBM Runtime Diagnostic Code Injection for the Java Platform (RDCI or Java Surgery)" && \
    echo "# https://www.ibm.com/support/pages/ibm-runtime-diagnostic-code-injection-java-platform-java-surgery" && \
    ( \
      sudo mkdir /opt/surgery/ && \
      cd /opt/surgery/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/surgery/surgery.jar \
    ) && \
    echo "# IBM Thread and Monitor Dump Analyzer (TMDA)" && \
    echo "# https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda" && \
    ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca4614.jar && \
      sudo mkdir /home/was/tmda/ && \
      sudo chown -R was:root /home/was/tmda/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca4614.jar\nPath=tmda/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop && \
      sudo ln -s /opt/tmda/tmda.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/tmda.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM ClassLoader Analyzer" && \
    echo "# https://www.ibm.com/support/pages/ibm-classloader-analyzer" && \
    ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo mkdir /home/was/cla/ && \
      sudo chown -R was:root /home/was/cla/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=cla/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop && \
      sudo ln -s /opt/classloaderanalyzer/cla.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/cla.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM HeapAnalyzer" && \
    echo "# https://www.ibm.com/support/pages/ibm-heapanalyzer" && \
    ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha457.jar && \
      sudo mkdir /home/was/ha/ && \
      sudo chown -R was:root /home/was/ha/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha457.jar\nPath=ha/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop && \
      sudo ln -s /opt/heapanalyzer/ha.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/ha.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)" && \
    echo "# https://www.ibm.com/support/pages/ibm-pattern-modeling-and-analysis-tool-java-garbage-collector-pmat" && \
    ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo mkdir /home/was/pmat/ && \
      sudo chown -R was:root /home/was/pmat/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=pmat/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop && \
      sudo ln -s /opt/pmat/pmat.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/pmat.desktop /home/was/Desktop/ \
    ) && \
    echo "###################" && \
    echo "# Install Eclipse #" && \
    echo "###################" && \
    echo "# This should match the latest WDT installed below" && \
    echo "# https://www.eclipse.org/downloads/packages/release/2023-03/r/eclipse-ide-enterprise-java-and-web-developers" && \
    sudo wget -q -O /opt/eclipse.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-03/R/eclipse-jee-2023-03-R-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse.tar.gz && \
      sudo rm -f /opt/eclipse.tar.gz && \
      sudo sed -i 's/-Xmx.*/-Xmx2g/g' /opt/eclipse/eclipse.ini && \
      sudo mkdir /home/was/eclipse/ && \
      sudo chown -R was:root /home/was/eclipse/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Eclipse\nExec=/opt/eclipse/eclipse -data workspace_eclipse\nPath=eclipse/\nTerminal=false\n' >> /opt/eclipse/eclipse.desktop && \
      sudo chmod a+x /opt/eclipse/eclipse.desktop && \
      sudo ln -s /opt/eclipse/eclipse.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/eclipse.desktop /home/was/Desktop/ \
    ) && \
    echo "################" && \
    echo "# Install GCMV #" && \
    echo "################" && \
    sudo mkdir -p /opt/gcmv/ && \
    sudo wget -q -O /opt/gcmv/gcmv.tar.gz https://public.dhe.ibm.com/software/websphere/appserv/support/tools/gcmv/com.ibm.java.diagnostics.visualizer.product-linux.gtk.x86_64.tar.gz && \
    ( \
      cd /opt/gcmv/ && \
      sudo tar xzf gcmv.tar.gz && \
      sudo rm -f gcmv.tar.gz && \
      sudo sed -i 's/-Xmx.*/-Xmx1g/g' /opt/gcmv/gcmv.ini && \
      sudo mkdir /home/was/gcmv/ && \
      sudo chown -R was:root /home/was/gcmv/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=GCMV\nExec=/opt/gcmv/gcmv -data workspace_gcmv -vm /opt/openjdk11_ibm/jdk/bin/\nPath=gcmv/\nTerminal=false\n' >> /opt/gcmv/gcmv.desktop && \
      sudo chmod a+x /opt/gcmv/gcmv.desktop && \
      sudo ln -s /opt/gcmv/gcmv.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/gcmv.desktop /home/was/Desktop/ \
    ) && \
    echo "#########################" && \
    echo "# Install Health Center #" && \
    echo "#########################" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.healthcenter.doc/homepage/plugin-homepage-hc.html" && \
    sudo mkdir -p /opt/hc/ && \
    sudo wget -q -O /opt/hc/hc.tar.gz https://public.dhe.ibm.com/software/websphere/appserv/support/tools/hc/com.ibm.java.diagnostics.healthcenter.rcp-linux.gtk.x86_64.tar.gz && \
    ( \
      cd /opt/hc/ && \
      sudo tar xzf hc.tar.gz && \
      sudo rm -f hc.tar.gz && \
      sudo sed -i 's/-Xmx.*/-Xmx1g/g' /opt/hc/healthcenter.ini && \
      sudo mkdir /home/was/hc/ && \
      sudo chown -R was:root /home/was/hc/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=HealthCenter\nExec=/opt/hc/healthcenter -data workspace_hc -vm /opt/openjdk11_ibm/jdk/bin/\nPath=hc/\nTerminal=false\n' >> /opt/hc/hc.desktop && \
      sudo chmod a+x /opt/hc/hc.desktop && \
      sudo ln -s /opt/hc/hc.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/hc.desktop /home/was/Desktop/ \
    ) && \
    echo "# https://github.com/kgibm/java_miscellaneous" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_miscellaneous \
    ) && \
    echo "# https://github.com/kgibm/SimulateJavaOOM" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/SimulateJavaOOM \
    ) && \
    echo "# Install MAT Source (still requires configuration in Eclipse): https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference" && \
    sudo git clone https://git.eclipse.org/r/mat/org.eclipse.mat.git /usr/local/src/mat && \
    sudo chmod -R a+w /usr/local/src/mat && \
    sudo mkdir /opt/mat/dev/ && \
    ( \
      cd /opt/mat/dev/ && \
      sudo wget -q http://www.eclipse.org/mat/dev/mat_code_formatter.xml && \
      sudo wget -q https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference && \
      sudo wget -O updatesite.zip -q $(curl -s https://www.eclipse.org/mat/downloads.php | grep "Archived Update Site" | sed 's/.*href="//g' | sed 's/".*/\&r=1/g') && \
      sudo unzip -q updatesite.zip && \
      sudo rm -f updatesite.zip \
    )

RUN echo "#####################" && \
    echo "# OpenJDK + HotSpot #" && \
    echo "#####################" && \
    echo "# https://adoptium.net/" && \
    for v in 8 11 17; do \
        for j in hotspot; do \
          ( \
            sudo mkdir /opt/openjdk${v}_${j}/ && \
            echo "# Downloading OpenJDK ${v}_${j}" && \
            sudo curl --silent --output /opt/openjdk${v}_${j}/temurin.tar.gz -L "https://api.adoptium.net/v3/binary/latest/${v}/ga/linux/x64/jdk/${j}/normal/eclipse" && \
            cd /opt/openjdk${v}_${j}/ && \
            sudo tar xzf /opt/openjdk${v}_${j}/temurin.tar.gz && \
            sudo rm /opt/openjdk${v}_${j}/temurin.tar.gz && \
            sudo mv jdk* jdk && \
            sudo alternatives --install \
                /usr/bin/java java /opt/openjdk${v}_${j}/jdk/bin/java 89999999 \
                --slave /usr/bin/javac javac /opt/openjdk${v}_${j}/jdk/bin/javac \
                --slave /usr/bin/jar jar /opt/openjdk${v}_${j}/jdk/bin/jar \
                --slave /usr/bin/javah javah /opt/openjdk${v}_${j}/jdk/bin/javah \
                --slave /usr/bin/javap javap /opt/openjdk${v}_${j}/jdk/javap \
                --slave /usr/bin/javadoc javadoc /opt/openjdk${v}_${j}/jdk/bin/javadoc \
                --slave /usr/bin/javaws javaws /opt/openjdk${v}_${j}/jdk/bin/javaws \
                --slave /usr/bin/jconsole jconsole /opt/openjdk${v}_${j}/jdk/bin/jconsole \
                --slave /usr/bin/jdmpview jdmpview /opt/openjdk${v}_${j}/jdk/bin/jdmpview \
                --slave /usr/bin/keytool keytool /opt/openjdk${v}_${j}/jdk/bin/keytool \
                --slave /usr/bin/jdb jdb /opt/openjdk${v}_${j}/jdk/bin/jdb \
                --slave /usr/bin/ControlPanel ControlPanel /opt/openjdk${v}_${j}/jdk/bin/ControlPanel \
                --family openjdk && \
            sudo alternatives --auto java \
          ) \
        done \
      done && \
    echo "####################" && \
    echo "# OpenJDK + Semeru #" && \
    echo "####################" && \
    echo "# https://developer.ibm.com/languages/java/semeru-runtimes/downloads" && \
    echo "# ibm for Open Edition and ibm_ce for Certified Edition" && \
    for v in 8 11 17; do \
        for j in ibm; do \
          ( \
            sudo mkdir /opt/openjdk${v}_${j}/ && \
            echo "# Downloading Semeru ${v}_${j}" && \
            sudo curl --silent --output /opt/openjdk${v}_${j}/semeru.tar.gz -L "https://www.ibm.com/semeru-runtimes/api/v3/binary/latest/${v}/ga/linux/x64/jdk/openj9/normal/${j}" && \
            cd /opt/openjdk${v}_${j}/ && \
            sudo tar xzf /opt/openjdk${v}_${j}/semeru.tar.gz && \
            sudo rm /opt/openjdk${v}_${j}/semeru.tar.gz && \
            sudo mv jdk* jdk && \
            sudo alternatives --install \
                /usr/bin/java java /opt/openjdk${v}_${j}/jdk/bin/java 89999999 \
                --slave /usr/bin/javac javac /opt/openjdk${v}_${j}/jdk/bin/javac \
                --slave /usr/bin/jar jar /opt/openjdk${v}_${j}/jdk/bin/jar \
                --slave /usr/bin/javah javah /opt/openjdk${v}_${j}/jdk/bin/javah \
                --slave /usr/bin/javap javap /opt/openjdk${v}_${j}/jdk/javap \
                --slave /usr/bin/javadoc javadoc /opt/openjdk${v}_${j}/jdk/bin/javadoc \
                --slave /usr/bin/javaws javaws /opt/openjdk${v}_${j}/jdk/bin/javaws \
                --slave /usr/bin/jconsole jconsole /opt/openjdk${v}_${j}/jdk/bin/jconsole \
                --slave /usr/bin/jdmpview jdmpview /opt/openjdk${v}_${j}/jdk/bin/jdmpview \
                --slave /usr/bin/keytool keytool /opt/openjdk${v}_${j}/jdk/bin/keytool \
                --slave /usr/bin/jdb jdb /opt/openjdk${v}_${j}/jdk/bin/jdb \
                --slave /usr/bin/ControlPanel ControlPanel /opt/openjdk${v}_${j}/jdk/bin/ControlPanel \
                --family openjdk && \
            sudo alternatives --auto java \
          ) \
        done \
      done

RUN echo "# https://adoptium.net/jmc" && \
    sudo mkdir /opt/jmc && \
    cd /opt/jmc && \
    sudo curl --silent --output jmc.tar.gz -L https://github.com/adoptium/jmc-build/releases/download/8.3.0/org.openjdk.jmc-8.3.0-linux.gtk.x86_64.tar.gz && \
    sudo tar xzf jmc.tar.gz && \
    sudo rm jmc.tar.gz && \
    sudo mv JDK\ Mission\ Control/* . && \
    sudo rmdir JDK\ Mission\ Control && \
    sudo sed -i 's/-vmargs/-vm\n\/opt\/openjdk11_hotspot\/jdk\/bin\/\n-vmargs/g' jmc.ini && \
    sudo mkdir /home/was/jmc/ && \
    sudo chown -R was:root /home/was/jmc/ && \
    sudo printf '[Desktop Entry]\nType=Application\nName=Mission Control\nExec=/opt/jmc/jmc -data workspace_jmc\nPath=jmc/\nTerminal=false\n' >> /opt/jmc/jmc.desktop && \
    sudo chmod a+x /opt/jmc/jmc.desktop && \
    sudo ln -s /opt/jmc/jmc.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/jmc.desktop /home/was/Desktop/

# The following Liberty version is used in the liberty-bikes builds. Find the latest version here:
# https://central.sonatype.com/search?smo=true&q=com.ibm.websphere.appserver.runtime%2520wlp-javaee8
ARG MAVEN_LIBERTY_VERSION="23.0.0.2"

# We use JVM_ARGS instead of OPENJ9_JAVA_OPTIONS because otherwise tWAS and all other Java
# executions will pick these options up, but we only want to apply them to Liberty (which
# uniquely parses JVM_ARGS)
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    KEYSTORE_REQUIRED=true \
    RANDFILE=/tmp/.rnd \
    JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ -XX:+UseContainerSupport" \
    PATH=/opt/ibm/wlp/bin:/opt/ibm/helpers/build:/opt/IBM/WebSphere/AppServer/bin:$PATH \
    WAS_CELL=DefaultCell01 \
    NODE_NAME=DefaultNode01 \
    SERVER_NAME=server1 \
    HOST_NAME=localhost \
    PROFILE_NAME=AppSrv01 \
    ADMIN_USER_NAME=wsadmin \
    EXTRACT_PORT_FROM_HOST_HEADER=true \
    ENABLE_BASIC_LOGGING=true \
    TLS=true \
    WLP_LOGGING_CONSOLE_FORMAT=simple

USER was

#####################
# "Install" Liberty #
#####################

# WebSphere Liberty:
#   https://github.com/WASdev/ci.docker/blob/master/ga/latest/kernel/Dockerfile.ubi.ibmjava8
# OpenLiberty:
#   https://github.com/OpenLiberty/ci.docker/blob/master/releases/latest/kernel/Dockerfile.ubi.ibmjava8

COPY --from=icr.io/appcafe/websphere-liberty:latest --chown=was:root /opt/ibm/helpers /opt/ibm/helpers
COPY --from=icr.io/appcafe/websphere-liberty:latest --chown=was:root /opt/ibm/wlp /opt/ibm/wlp
COPY --from=icr.io/appcafe/websphere-liberty:latest --chown=was:root /logs /logs
COPY --from=icr.io/appcafe/websphere-liberty:latest --chown=was:root /licenses /licenses
COPY --from=icr.io/appcafe/websphere-liberty:latest --chown=was:root /etc/wlp /etc/wlp

#############################
# "Install" Traditional WAS #
#############################

# https://github.com/WASdev/ci.docker.websphere-traditional/blob/master/docker-build/9.0.5.x/Dockerfile

COPY --from=icr.io/appcafe/websphere-traditional:latest --chown=was:root /work /work
COPY --from=icr.io/appcafe/websphere-traditional:latest --chown=was:root /licenses/* /licenses/
COPY --from=icr.io/appcafe/websphere-traditional:latest --chown=was:root /opt/IBM /opt/IBM
COPY --from=icr.io/appcafe/websphere-traditional:latest --chown=was:root /etc/websphere /etc/websphere

RUN sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    echo "##################" && \
    echo "# Configure tWAS #" && \
    echo "##################" && \
    echo "* libxcrypt-compat provides /lib64/libcrypt.so.1 needed for things like tWAS; otherwise: java.lang.UnsatisfiedLinkError: Ws60ProcessManagement (Not found in java.library.path)" && \
    echo "https://fedoraproject.org/wiki/Changes/FullyRemoveDeprecatedAndUnsafeFunctionsFromLibcrypt" && \
    sudo dnf install -y libxcrypt-compat && \
    sed -i 's/"9443"/"9444"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7276"/"7277"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7286"/"7287"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9080"/"9081"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"2809"/"2810"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9402"/"9404"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/9080/9081/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i 's/9443/9444/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    echo "# https://github.com/kgibm/problemdetermination" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/problemdetermination \
    ) && \
    printf 'nodeName = AdminControl.getNode()\n\
serverName = AdminServerManagement.listServers()[0]\n\
serverName = serverName[:serverName.find("(")]\n\
#AdminApplication.uninstallApplication("DefaultApplication")\n\
# https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.0/com.ibm.websphere.nd.multiplatform.doc/ae/rxml_taskoptions.html\n\
AdminApp.install("/opt/problemdetermination/swat.ear", ["-appname", "swat", "-node", nodeName, "-server", serverName, "-usedefaultbindings"])\n\
AdminConfig.save()\n' > /work/config/install_app.py && \
    if [ "$(sudo head -n 1 /tmp/remotepassword)" != "" ]; then echo -n "$(sudo head -n 1 /tmp/remotepassword)" > /tmp/PASSWORD; fi && \
    sed -i 's/ps -C.*/awk "\/ADMU3000I\/ { print \\$NF; }" \/opt\/IBM\/WebSphere\/AppServer\/profiles\/AppSrv01\/logs\/server1\/startServer.log)/g' /work/configure.sh && \
    sed -i 's/start_server$/start_server;/g' /work/configure.sh && \
    echo "# Running /work/configure.sh #" && \
    /work/configure.sh && \
    echo "# Finished /work/configure.sh #" && \
    echo "#####################" && \
    echo "# Configure Liberty #" && \
    echo "#####################" && \
    sudo mkdir -p /opt/ibm/wlp/output/defaultServer/.classCache && \
    sudo chown -R was:root /opt/ibm/wlp/output && \
    sudo ln -s /opt/ibm/wlp/output/defaultServer /output && \
    sudo chmod -R a+rx /opt/ibm/wlp/output/defaultServer/.classCache && \
    sudo chown was:root /output && \
    sudo chmod 777 /output && \
    sudo ln -s /opt/ibm/wlp/usr/servers/defaultServer /config && \
    sudo chown was:root /config && \
    sudo ln -s /opt/ibm /liberty && \
    sudo chown was:root /liberty && \
    sudo ln -s /opt/ibm/wlp/usr/shared/resources/lib.index.cache /lib.index.cache && \
    sudo chown was:root /lib.index.cache && \
    echo "# In case the user restarts Liberty from the command line instead of supervisord, we need to set the right envars" && \
    printf '\n\
LOG_DIR=/logs\n\
WLP_OUTPUT_DIR=/opt/ibm/wlp/output\n\
KEYSTORE_REQUIRED=true\n\
TLS=true\n\
RANDFILE=/tmp/.rnd\n\
JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ -XX:+UseContainerSupport"\n\
\n' >> /config/server.env && \
    /opt/ibm/helpers/runtime/docker-server.sh && \
    cp /opt/problemdetermination/swat.ear /config/dropins/ && \
    chown was:root /config/dropins/swat.ear && \
    echo "#################" && \
    echo "# Install Tools #" && \
    echo "#################" && \
    echo "# IBM Trace and Request Analyzer for WebSphere Application Server" && \
    echo "# https://www.ibm.com/support/pages/ibm-trace-and-request-analyzer-websphere-application-server" && \
    ( \
      sudo mkdir /opt/tracerequestanalyzer/ && \
      cd /opt/tracerequestanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/tra/tra303.jar && \
      sudo mkdir /home/was/tra/ && \
      sudo chown -R was:root /home/was/tra/ && \
      printf '[Desktop Entry]\nType=Application\nName=Trace and Request Analyzer\nExec=java -jar /opt/tracerequestanalyzer/tra303.jar\nPath=tra/\nTerminal=false\n' | sudo tee tra.desktop && \
      sudo chmod a+x tra.desktop && \
      sudo ln -s /opt/tracerequestanalyzer/tra.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/tra.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Channel Framework Analyzer" && \
    echo "# https://www.ibm.com/support/pages/ibm-channel-framework-analyzer" && \
    ( \
      sudo mkdir /opt/channelframeworkanalyzer/ && \
      cd /opt/channelframeworkanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/cfa/cfa108.jar && \
      sudo mkdir /home/was/cfa/ && \
      sudo chown -R was:root /home/was/cfa/ && \
      printf '[Desktop Entry]\nType=Application\nName=Channel Framework Analyzer\nExec=java -jar /opt/channelframeworkanalyzer/cfa108.jar\nPath=cfa/\nTerminal=false\n' | sudo tee cfa.desktop && \
      sudo chmod a+x cfa.desktop && \
      sudo ln -s /opt/channelframeworkanalyzer/cfa.desktop /opt/programs/ \
    ) && \
    echo "# IBM Web Server Plug-in Analyzer for WebSphere Application Server (WSPA)" && \
    echo "# https://www.ibm.com/support/pages/ibm-web-server-plug-analyzer-websphere-application-server-wspa" && \
    ( \
      sudo mkdir /opt/webserverpluginanalyzer/ && \
      cd /opt/webserverpluginanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/wspa/wspa35.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip && \
      sudo mkdir /home/was/wspa/ && \
      sudo chown -R was:root /home/was/wspa/ && \
      printf '[Desktop Entry]\nType=Application\nName=Web Server Plug-in Analyzer\nExec=java -jar /opt/webserverpluginanalyzer/wspa35.jar\nPath=wspa/\nTerminal=false\n' | sudo tee wspa.desktop && \
      sudo chmod a+x wspa.desktop && \
      sudo ln -s /opt/webserverpluginanalyzer/wspa.desktop /opt/programs/ \
    ) && \
    echo "# Connection and Configuration Verification Tool for SSL/TLS" && \
    echo "# https://www.ibm.com/support/pages/connection-and-configuration-verification-tool-ssltls" && \
    ( \
      sudo mkdir /opt/tlsverificationtool/ && \
      cd /opt/tlsverificationtool/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/cvt/cvt102.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip && \
      sudo mkdir /home/was/cvt/ && \
      sudo chown -R was:root /home/was/cvt/ && \
      printf '[Desktop Entry]\nType=Application\nName=SSL/TLS Connection and Configuration Verification Tool\nExec=java -jar /opt/tlsverificationtool/cvt102.jar\nPath=cvt/\nTerminal=false\n' | sudo tee cvt.desktop && \
      sudo chmod a+x cvt.desktop && \
      sudo ln -s /opt/tlsverificationtool/cvt.desktop /opt/programs/ \
    ) && \
    echo "# WebSphere Application Server Configuration Visualizer" && \
    echo "# https://www.ibm.com/support/pages/websphere-application-server-configuration-visualizer" && \
    ( \
      sudo mkdir /opt/wsvisualizer/ && \
      cd /opt/wsvisualizer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/wsvisualizer/wsvisualizer_20200123.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip \
    ) && \
    echo "# Problem Diagnostics Lab Toolkit" && \
    echo "# https://www.ibm.com/support/pages/problem-diagnostics-lab-toolkit" && \
    ( \
      sudo mkdir /opt/problemdiagnosticstoolkit/ && \
      cd /opt/problemdiagnosticstoolkit/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/pdlt/ProblemDiagnosticsLabToolkit_1.2.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip \
    ) && \
    echo "# Eclipse SWT" && \
    echo "# https://download.eclipse.org/eclipse/downloads/" && \
    echo "# Click top version under Latest Release, then scroll to SWT Binary and Source, then go to downlod page, then get the 'Direct link to file' link" && \
    ( \
      sudo mkdir /opt/swt/ && \
      cd /opt/swt/ && \
      sudo wget -O swt.zip -q "https://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.16-202006040540/swt-4.16-gtk-linux-x86_64.zip&r=1" && \
      sudo unzip -q *.zip && \
      sudo rm *.zip \
    ) && \
    echo "# Service Integration Bus Explorer" && \
    echo "# https://www.ibm.com/support/pages/service-integration-bus-explorer" && \
    ( \
      sudo mkdir /opt/sibexplorer/ && \
      cd /opt/sibexplorer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/sibexplorer/sibexplorer_1.01b.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip \
    ) && \
    echo "# Service Integration Bus Performance" && \
    echo "# https://www.ibm.com/support/pages/service-integration-bus-performance" && \
    ( \
      sudo mkdir /opt/sibperf/ && \
      cd /opt/sibperf/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/sibperf/sibperf.zip && \
      sudo unzip -q *.zip && \
      sudo rm *.zip \
    ) && \
    echo "# https://www.ibm.com/support/pages/node/227907" && \
    ( \
      sudo mkdir /opt/trapit/ && \
      cd /opt/trapit/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/trapit/trapit.ear \
    ) && \
    echo "# https://github.com/kgibm/java_web_hello_world" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_web_hello_world && \
      cd /opt/java_web_hello_world && \
      sudo mvn -q clean install \
    ) && \
    echo "# https://github.com/kgibm/libertymon" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/libertymon \
    ) && \
    echo "# https://github.com/kgibm/request-metrics-analyzer-next" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/request-metrics-analyzer-next && \
      cd /opt/request-metrics-analyzer-next && \
      sudo mvn -q clean install && \
      sudo mkdir /home/was/rma/ && \
      sudo chown -R was:root /home/was/rma/ && \
      printf '[Desktop Entry]\nType=Application\nName=Request Metrics Analyzer\nExec=java -jar /opt/request-metrics-analyzer-next/target/request-metrics-analyzer-next-2.0.20210805-jar-with-dependencies.jar\nPath=rma/\nTerminal=false\n' | sudo tee rma.desktop && \
      sudo chmod a+x rma.desktop && \
      sudo ln -s /opt/request-metrics-analyzer-next/rma.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/rma.desktop /home/was/Desktop/ \
    ) && \
    echo "# https://www.ibm.com/support/pages/node/711615" && \
    ( \
      sudo mkdir /opt/wasconfigcomparison/ && \
      sudo wget -q -O /opt/wasconfigcomparison/cct.tar.gz "https://github.com/IBM/websphere-cct/releases/download/WCCT-20200914/cct-20200914.tar.gz" && \
      cd /opt/wasconfigcomparison/ && \
      sudo tar xzf cct.tar.gz \
    ) && \
    echo "# https://www.ibm.com/support/pages/node/141227" && \
    ( \
      sudo mkdir /opt/manageprofilesinteractive/ && \
      sudo wget -q -O /opt/manageprofilesinteractive/manageprofilesInteractive.zip "https://www.ibm.com/support/pages/system/files/support/swg/swgtech.nsf/0/d6ca5180f6619c868525776f0069b7b7/\$FILE/ATTQDXZT.zip/manageprofilesInteractive.zip" && \
      cd /opt/manageprofilesinteractive/ && \
      sudo unzip -q manageprofilesInteractive.zip \
    )

RUN echo "#########################" && \
    echo "# Install Liberty Tools #" && \
    echo "#########################" && \
    echo "# This replaces the older Liberty Developer Tools." && \
    echo "# Match eclipse/updates using https://en.wikipedia.org/wiki/Eclipse_(software)#Releases" && \
    sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/liberty-tools-eclipse/latest/repository/,https://download.eclipse.org/releases/2023-03/,https://download.eclipse.org/lsp4jakarta/releases/0.1.0/repository,https://download.eclipse.org/jdtls/milestones/1.5.0/repository,https://download.eclipse.org/justj/epp/release/latest,https://download.eclipse.org/justj/jres/17/updates/release/latest,https://download.eclipse.org/technology/epp/packages/latest/,https://download.eclipse.org/releases/latest,https://download.eclipse.org/lsp4mp/releases/0.5.0/repository,https://download.eclipse.org/eclipse/updates/4.27,https://download.eclipse.org/webtools/repository/latest \
                              -installIU io.openliberty.tools.eclipse.feature.group && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse/configuration && \
    echo "############################" && \
    echo "# Add supervisord programs #" && \
    echo "############################" && \
    echo "# Deployed applications at http://localhost:9080/ and https://localhost:9443/" && \
    printf '\n\
[program:liberty]\n\
command=/opt/ibm/wlp/bin/server run defaultServer --clean\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startretries=0\n\
autorestart=false\n\
startsecs=5\n\
priority=50\n\
user=was\n\
autostart=true\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee /etc/supervisord.d/liberty.supervisord.conf && \
    echo "# https://localhost:9043/ibm/console" && \
    echo "# User = wsadmin" && \
    echo "# Password = /tmp/PASSWORD" && \
    echo "# Deployed applications at http://localhost:9081/ and https://localhost:9444/" && \
    printf '\n\
[program:twas]\n\
command=/work/start_server.sh\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startsecs=180\n\
startretries=0\n\
autorestart=false\n\
priority=50\n\
user=was\n\
autostart=true\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee /etc/supervisord.d/twas.supervisord.conf && \
    echo -n "$(sudo head -n 1 /tmp/remotepassword)" | /usr/local/bin/setpassword.sh && \
    sudo mkdir /tmp/wlp-cache/ && \
    sudo chmod 777 /tmp/wlp-cache/ && \
    echo "# https://github.com/WASdev/sample.daytrader7" && \
    ( \
      sudo git clone https://github.com/WASdev/sample.daytrader7 /opt/daytrader7 && \
      cd /opt/daytrader7 && \
      sudo git checkout 46d65972bcbd39df509e3603fe39db98f30160bf && \
      sudo sed -i 's/maxUsers=.*/maxUsers=15000/g' daytrader-ee7-web/src/main/webapp/properties/daytrader.properties && \
      sudo sed -i 's/maxQuotes=.*/maxQuotes=10000/g' daytrader-ee7-web/src/main/webapp/properties/daytrader.properties && \
      sudo sed -i 's/runtimeMode=.*/runtimeMode=1/g' daytrader-ee7-web/src/main/webapp/properties/daytrader.properties && \
      sudo gradle :daytrader-ee7:ear \
    ) && \
    echo "# Tried to fix the NoSuchEJBException but this didn't help. Instead, we just ignore the warnings in daytrader7logging.xml below." && \
    mkdir -p /config/configDropins/overrides/ && \
    cp /opt/daytrader7/daytrader-ee7/build/libs/daytrader-ee7.ear /config/apps/ && \
    echo "# https://publib.boulder.ibm.com/httpserv/cookbook/" && \
    sudo mkdir /opt/cookbook && \
    sudo wget -q -O /opt/cookbook/WAS_Performance_Cookbook.pdf https://publib.boulder.ibm.com/httpserv/cookbook/WAS_Performance_Cookbook.pdf && \
    sudo ln -s /opt/cookbook/WAS_Performance_Cookbook.pdf /home/was/Desktop/ && \
    sudo dnf install -y postgresql-server postgresql-contrib postgresql-jdbc && \
    sudo dnf install -y mariadb-server mariadb-java-client && \
    sudo mysql_install_db --skip-test-db --user=mysql && \
    printf '\n\
UPDATE mysql.user SET Password = PASSWORD("%s") WHERE User = "root";\n\
FLUSH PRIVILEGES;\n\
CREATE DATABASE TradeDB;\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /var/lib/mysql/init.sql && \
    echo "# https://mariadb.com/kb/en/library/mysqld-options/" && \
    printf '\n\
[program:mysql]\n\
command=/usr/bin/mysqld_safe --init-file=/var/lib/mysql/init.sql\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startsecs=5\n\
startretries=0\n\
autorestart=false\n\
priority=25\n\
user=mysql\n\
autostart=true\n\
stopsignal=KILL\n\
environment=\n\
    HOME="/var/lib/mysql",\n\
    USER="mysql",\n\
\n' | sudo tee /etc/supervisord.d/mysqld.supervisord.conf

RUN sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    echo "# https://github.com/WASdev/sample.daytrader7/blob/master/daytrader-ee7-wlpcfg/servers/daytrader7Sample/server.xml" && \
    printf '\n\
<server>\n\
  <featureManager>\n\
    <feature>transportSecurity-1.0</feature>\n\
    <feature>ejb-3.2</feature>\n\
    <feature>servlet-3.1</feature>\n\
    <feature>jsf-2.2</feature>\n\
    <feature>jpa-2.1</feature>\n\
    <feature>mdb-3.2</feature>\n\
    <feature>wasJmsServer-1.0</feature>\n\
    <feature>wasJmsClient-2.0</feature>\n\
    <feature>cdi-1.2</feature>\n\
    <feature>websocket-1.1</feature>\n\
    <feature>concurrent-1.0</feature>\n\
    <feature>jsonp-1.0</feature>\n\
    <feature>beanValidation-1.1</feature>\n\
    <feature>localConnector-1.0</feature>\n\
    <feature>appSecurity-2.0</feature>\n\
    <feature>ldapRegistry-3.0</feature>\n\
    <feature>federatedRegistry-1.0</feature>\n\
  </featureManager>\n\
  <connectionManager agedTimeout="-1" connectionTimeout="0" id="conMgr1" maxIdleTime="-1" maxPoolSize="100" minPoolSize="100" purgePolicy="FailingConnectionOnly" reapTime="-1"/>\n\
  <authData id="TradeDataSourceAuthData" user="root" password="%s" />\n\
  <authData id="TradeAdminAuthData" user="root" password="%s" />\n\
  <connectionManager agedTimeout="-1" connectionTimeout="0" id="conMgr1" maxIdleTime="-1" maxPoolSize="100" minPoolSize="100" purgePolicy="FailingConnectionOnly" reapTime="-1" />\n\
  <jdbcDriver id="DerbyEmbedded" libraryRef="DerbyLib" />\n\
  <library filesetRef="DerbyFileset" id="DerbyLib" />\n\
  <fileset dir="/opt/derby/lib/" id="DerbyFileset" includes="derby.jar" />\n\
  <dataSource connectionManagerRef="conMgr1" id="DefaultDataSource" isolationLevel="TRANSACTION_READ_COMMITTED" jdbcDriverRef="DerbyEmbedded" jndiName="jdbc/TradeDataSource" statementCacheSize="60">\n\
    <properties.derby.embedded createDatabase="create" databaseName="${shared.resource.dir}/data/tradedb" user="root" password="%s" />\n\
  </dataSource>\n\
  <!--\n\
  <library id="MariaDBLib">\n\
    <file name="/usr/lib/java/mariadb-java-client.jar" />\n\
  </library>\n\
  <dataSource id="DefaultDataSource" jndiName="jdbc/TradeDataSource">\n\
    <jdbcDriver libraryRef="MariaDBLib" />\n\
    <properties databaseName="TradeDB" serverName="localhost" user="root" password="%s" portNumber="3306" />\n\
  </dataSource>\n\
  -->\n\
	<messagingEngine id="defaultME">\n\
		<queue id="TradeBrokerQueue"/>\n\
		<topicSpace id="TradeTopicSpace"/>\n\
	</messagingEngine>\n\
	<jmsQueueConnectionFactory connectionManagerRef="ConMgr3" jndiName="jms/TradeBrokerQCF">\n\
		<properties.wasJms/>\n\
	</jmsQueueConnectionFactory>\n\
	<connectionManager id="ConMgr3" maxPoolSize="20"/>\n\
	<jmsTopicConnectionFactory connectionManagerRef="ConMgr4" jndiName="jms/TradeStreamerTCF">\n\
		<properties.wasJms/>\n\
	</jmsTopicConnectionFactory>\n\
	<connectionManager id="ConMgr4" maxPoolSize="20"/>\n\
	<jmsQueue id="jms/TradeBrokerQueue" jndiName="jms/TradeBrokerQueue">\n\
		<properties.wasJms deliveryMode="NonPersistent" queueName="TradeBrokerQueue"/>\n\
	</jmsQueue>\n\
	<jmsTopic id="TradeStreamerTopic" jndiName="jms/TradeStreamerTopic">\n\
		<properties.wasJms deliveryMode="NonPersistent" topicSpace="TradeTopicSpace"/>\n\
	</jmsTopic>\n\
	<jmsActivationSpec id="eis/TradeBrokerMDB">\n\
		<properties.wasJms destinationRef="jms/TradeBrokerQueue"/>\n\
	</jmsActivationSpec>\n\
	<jmsActivationSpec id="eis/TradeStreamerMDB">\n\
		<properties.wasJms destinationRef="TradeStreamerTopic" destinationType="javax.jms.Topic"/>\n\
  </jmsActivationSpec>\n\
  <basicRegistry id="basic" realm="BasicRealm">\n\
    <user name="wsadmin" password="%s" />\n\
  </basicRegistry>\n\
  <ldapRegistry id="LDAP1" realm="SampleLdapIDSRealm" host="localhost" port="389" ignoreCase="true" \n\
                baseDN="dc=example,dc=com" ldapType="Custom" searchTimeout="60s" recursiveSearch="true"\n\
                bindDN="cn=Manager,dc=example,dc=com" bindPassword="%s">\n\
  </ldapRegistry>\n\
  <federatedRepository>\n\
    <primaryRealm name="PrimaryRealm" allowOpIfRepoDown="true">\n\
      <participatingBaseEntry name="o=BasicRealm"/>\n\
      <participatingBaseEntry name="dc=example,dc=com"/>\n\
    </primaryRealm>\n\
  </federatedRepository>\n\
  <application type="ear" id="daytrader" name="daytrader" location="${server.config.dir}/apps/daytrader-ee7.ear">\n\
    <application-bnd>\n\
      <security-role name="webSecOnly">\n\
        <group name="cn=webSecOnly,ou=Users,dc=example,dc=com" />\n\
      </security-role>\n\
      <security-role name="grp1">\n\
        <group name="cn=grp1,ou=Users,dc=example,dc=com" />\n\
      </security-role>\n\
      <security-role name="AllAuthenticated">\n\
        <special-subject type="ALL_AUTHENTICATED_USERS" />\n\
      </security-role>\n\
    </application-bnd>\n\
  </application>\n\
</server>\n\
' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" > /config/configDropins/overrides/daytrader.xml && \
    echo "# https://openliberty.io/docs/ref/config/#logging.html" && \
    printf '\n\
<server>\n\
    <logging traceSpecification="*=info" maxFileSize="250" maxFiles="4" hideMessage="CNTR0333W,CNTR0019E,CWWJP9991W" />\n\
</server>\n' > /config/configDropins/overrides/daytrader7logging.xml && \
    sed -i '/.*microProfile-3.0.*/d' /config/server.xml && \
    sed -i '/.*javaee-8.0.*/d' /config/server.xml && \
    /opt/ibm/wlp/bin/installUtility install --acceptLicense defaultServer && \
    /opt/ibm/wlp/bin/server start defaultServer --clean && \
    /opt/ibm/wlp/bin/server stop defaultServer && \
    echo "# https://mariadb.com/kb/en/library/identifier-case-sensitivity/" && \
    sudo sed -i 's/\[mysqld\]/[mysqld]\nlower_case_table_names=1/g' /etc/my.cnf.d/mariadb-server.cnf && \
    echo "# https://db.apache.org/derby/" && \
    ( \
      cd /opt/ && \
      sudo wget -q -O /opt/derby.zip https://www.apache.org/dist/db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-bin.zip && \
      sudo unzip -q derby.zip && \
      sudo rm derby.zip && \
      sudo mv *derby* derby \
    ) && \
    echo "# https://github.com/kgibm/jni_web_hello_world" && \
    ( \
      echo "Version 9" && \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/jni_web_hello_world && \
      cd /opt/jni_web_hello_world && \
      sudo mvn -q clean install && \
      cd src/main/c/ && \
      sudo gcc -g -shared -fPIC -o ../../../target/libNativeWrapper.so -I/opt/ibm/java/include/ -I/opt/ibm/java/include/linux/ com_example_NativeWrapper.c && \
      /opt/ibm/wlp/bin/server create test && \
      cp /opt/jni_web_hello_world/target/jni_web_hello_world.war /opt/ibm/wlp/usr/servers/test/dropins/ && \
      cp /opt/problemdetermination/swat.ear /opt/ibm/wlp/usr/servers/test/dropins/ && \
      printf '--' '-Xmx2g\n-Djava.library.path=/opt/jni_web_hello_world/target/\n-DSUPPRESS_INVOKE_MESSAGES=true\n-DJAVA_SURGERY_JAR_FILE=/opt/surgery/surgery.jar\n-DLEAK_TO_LIST=true\n' > /opt/ibm/wlp/usr/servers/test/jvm.options && \
      printf '<?xml version="1.0"?><server><featureManager><feature>webProfile-8.0</feature></featureManager><httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="9082" httpsPort="9445" /></server>' > /opt/ibm/wlp/usr/servers/test/server.xml \
    ) && \
    printf '\n\
[program:liberty2]\n\
command=/opt/ibm/wlp/bin/server start test\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startretries=0\n\
autorestart=false\n\
priority=60\n\
user=was\n\
autostart=true\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
    LOG_DIR="/opt/ibm/wlp/usr/servers/test/logs/",\n\
    WLP_OUTPUT_DIR="/opt/ibm/wlp/usr/servers/",\n\
\n' | sudo tee /etc/supervisord.d/liberty2.supervisord.conf && \
    sudo mkdir /opt/docs/ && \
    mkdir -p /home/was/Desktop && \
    chown was /home/was/Desktop && \
    echo "# https://github.com/OpenLiberty/liberty-bikes" && \
    echo "# We want WebSphere Liberty features like adminCenter so we replace libertyRuntime" && \
    echo "# https://mvnrepository.com/artifact/com.ibm.websphere.appserver.runtime" && \
    ( \
      cd /home/was/ && \
      git clone https://github.com/OpenLiberty/liberty-bikes && \
      cd liberty-bikes && \
      sed -i "s/libertyRuntime.*/libertyRuntime group: 'com.ibm.websphere.appserver.runtime', name: 'wlp-javaee8', version: '${MAVEN_LIBERTY_VERSION}'/g" build.gradle && \
      sudo chmod -R 777 /tmp/wlp-cache/ && \
      ./gradlew libertyPackage game-service:compileTestJava && \
      sudo chmod -R 777 /tmp/wlp-cache/ && \
      ./build/wlp/bin/installUtility install --acceptLicense adminCenter-1.0 && \
      mkdir -p build/wlp/usr/servers/frontendServer/configDropins/overrides/ && \
      printf '<server><featureManager><feature>ssl-1.0</feature></featureManager></server>' > build/wlp/usr/servers/frontendServer/configDropins/overrides/ssl.xml \
    ) && \
    cp /opt/problemdetermination/swat.ear /home/was/liberty-bikes/build/wlp/usr/servers/frontendServer/dropins/ && \
    echo "# Start Liberty which creates the DB, then build the DB tables, restart Liberty, and then populate the DB." && \
    echo "# A benign FFDC is created initially which we can just destroy later." && \
    sudo mkdir -p /opt/ibm/wlp/usr/shared/resources/data/ && \
    sudo chown -R was:root /opt/ibm/wlp/usr/shared/resources/ && \
    /opt/ibm/wlp/bin/server start defaultServer && \
    sleep 30 && \
    curl -u "wsadmin:$(cat /tmp/PASSWORD)" "http://localhost:9080/daytrader/config?action=buildDBTables" && \
    /opt/ibm/wlp/bin/server stop defaultServer && \
    /opt/ibm/wlp/bin/server start defaultServer && \
    sleep 30 && \
    curl -u "wsadmin:$(cat /tmp/PASSWORD)" "http://localhost:9080/daytrader/config?action=buildDB" && \
    /opt/ibm/wlp/bin/server stop defaultServer && \
    rm -rf /logs/ffdc/* && \
    sudo rm /opt/daytrader7/jmeter_files/daytrader7_mojarra.jmx && \
    sudo chmod a+rw /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    printf '#!/bin/sh\n\
sleep 300\n\
echo -e "\\n\\n=========\\n= READY =\\n=========\\n"\n\
\n' | sudo tee /usr/local/bin/finished.sh && sudo chmod +x /usr/local/bin/finished.sh && \
    printf '\n\
[program:finished]\n\
command=/usr/local/bin/finished.sh\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n' | sudo tee /etc/supervisord.d/finished.supervisord.conf

RUN sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    echo "# Configure DayTrader7 on tWAS" && \
    sudo sed -i 's/9082/9080/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/THREADS,50/THREADS,4/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo chmod -R a+w /opt/daytrader7/jmeter_files && \
    sudo sed -i 's/\(ResultCollector.*StatVisualizer.*enabled="\)false/\1true/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/ThreadGroup.scheduler">true/ThreadGroup.scheduler">false/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/AdminUserID/wsadmin/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i "s/\"password\"/\"$(cat /tmp/PASSWORD)\"/g" /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/SecurityEnabled = ".*/SecurityEnabled = "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultProviderType =   .*/DefaultProviderType = "Derby"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultPathName =       .*/DefaultPathName = "\/opt\/derby\/lib\/derby.jar"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultEJBDeployType = ".*/DefaultEJBDeployType = "DERBY_V10"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultTradeAppName = ".*/DefaultTradeAppName = "DayTrader7"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultEarFile =      ".*/DefaultEarFile = "\/opt\/daytrader7\/daytrader-ee7\/build\/libs\/daytrader-ee7.ear"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DerbyPath =             ".*/DerbyPath = "\/opt\/derby\/lib\/derby.jar"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/#\(scope = .*Server.*\)/\1/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i '/.*scope = .*NodeName+"\/".*/d' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultUseMetadata =  "true"/DefaultUseMetadata =  "false"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultRunWSDeploy =  "false"/DefaultRunWSDeploy =  "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultXA = "false"/DefaultXA = "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i '/import sre/d' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/providerId = AdminConfig.createUsingTemplate.*/providerId = AdminTask.createJDBCProvider(["-scope", "Node=DefaultNode01,Server=server1", "-databaseType", "Derby", "-providerType", "Derby JDBC Provider", "-implementationType", "Connection pool data source", "-name", "Derby JDBC Provider", "-classpath", "\/opt\/derby\/lib\/derby.jar", "-nativePath", ""])/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/\(Derby.*\) Only":/\1":/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/\(Derby.*\) Only (XA)":/\1 (XA)":/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/dsId = AdminConfig.createUsingTemplate.*/dsId = AdminTask.createDatasource(providerId, ["-name", datasourceName, "-jndiName", jndiName, "-dataStoreHelperClassName", "com.ibm.websphere.rsadapter.DerbyDataStoreHelper", "-containerManagedPersistence", "true", "-componentManagedAuthenticationAlias", "TradeDataSourceAuthData", "-configureResourceProperties", "[[databaseName java.lang.String TradeDB]]"])/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -usedefaultbindings"/parms += " -usedefaultbindings -defaultbinding.ee.defaults"/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/, "-subscriptio.*/]/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -nodeployejb"/parms += ""/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -nodeployws"/parms += ""/g' /opt/daytrader7/scripts/resource_scripts.py && \
    echo "# For some reason, Derby doesn't like the default locale so we override it." && \
    echo "# Also increase System*.log and trace*log rotation: https://www.ibm.com/support/knowledgecenter/en/SSEQTP_9.0.5/com.ibm.websphere.base.doc/ae/txml_logrotation.html" && \
    printf '\n\
server = AdminConfig.getid("/Cell:DefaultCell01/Node:DefaultNode01/Server:server1/")\n\
jvm = AdminConfig.list("JavaVirtualMachine", server)\n\
AdminConfig.modify(jvm, [["genericJvmArguments", "-Duser.country=US -Duser.language=en -Xnoloa"]])\n\
\n\
log = AdminConfig.showAttribute(server, "outputStreamRedirect")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
log = AdminConfig.showAttribute(server, "errorStreamRedirect")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
trace = AdminConfig.list("TraceService", server)\n\
log = AdminConfig.showAttribute(trace, "traceLog")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
AdminConfig.save()\n\
\n' > /home/was/twas.jy && \
    echo "# wsadmin script after the base DayTrader7 script is run:" && \
    echo "# * Set createDatabase=true custom property" && \
    printf '\n\
for dsName in ["TradeDataSource", "NoTxTradeDataSource"]:\n\
  ds = AdminConfig.getid("/Cell:DefaultCell01/Node:DefaultNode01/Server:server1/JDBCProvider:Derby JDBC Provider/DataSource:" + dsName + "/")\n\
  ps = AdminConfig.showAttribute(ds, "propertySet")\n\
  props = AdminConfig.list("J2EEResourceProperty", ps).splitlines()\n\
  for prop in props:\n\
    propName = AdminConfig.showAttribute(prop, "name")\n\
    if propName == "createDatabase":\n\
      AdminConfig.modify(prop, "[[value create]]")\n\
\n\
AdminConfig.save()\n\
\n' > /home/was/twas_daytrader_finalize.jy && \
    echo "# Initialize tWAS DayTrader" && \
    ( \
      cd /opt/daytrader7/scripts/ && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      echo "# Running twas.jy" && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      echo "# Running daytrader_SILENT_singleServer." && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f daytrader_SILENT_singleServer.py -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      echo "# Running twas_daytrader_finalize.jy" && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas_daytrader_finalize.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      curl "http://localhost:9081/daytrader/config?action=buildDBTables" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      curl "http://localhost:9081/daytrader/config?action=buildDB" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" \
    ) && \
    sudo mv /opt/daytrader7/jmeter_files/daytrader7.jmx /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx && \
    sudo cp /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo sed -i 's/9080/9083/g' /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo chmod a+rw /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    printf "\n\
AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:DefaultCell01/VirtualHost:default_host/'), '[[hostname \"*\"] [port \"9083\"]]')\n\
AdminConfig.save()\n\
\n" > /home/was/twas_config_virtualhost.jy && \
    /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
    /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas_config_virtualhost.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
    /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)"

#################
# "Install" IHS #
#################

COPY --chown=was:root *IHS-ARCHIVE*zip /opt/IBM/

RUN ( \
      cd /opt/IBM && \
      sudo unzip *IHS-ARCHIVE*zip && \
      sudo rm *IHS-ARCHIVE*zip && \
      sudo mv IHS HTTPServer && \
      sudo chown -R was:root /opt/IBM/HTTPServer \
    ) && \
    mv /opt/IBM/HTTPServer/conf/httpd.conf.default /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/Listen @@Port@@/Listen 9083/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/ReportInterval 300/ReportInterval 10/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/@@ServerRoot@@/\/opt\/IBM\/HTTPServer/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/@@User@@/was/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/@@Group@@/root/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/@@ServerName@@/localhost/g' /opt/IBM/HTTPServer/conf/httpd.conf && \
    sed -i 's/@@SERVERROOT@@/\/opt\/IBM\/HTTPServer/g' /opt/IBM/HTTPServer/bin/apachectl-std && \
    sudo ln -s /lib64/libpcre.so.1 /lib64/libpcre.so.0 && \
    sudo mv /opt/IBM/HTTPServer/conf/mime.types.default /opt/IBM/HTTPServer/conf/mime.types && \
    sudo mv /opt/IBM/HTTPServer/conf/magic.default /opt/IBM/HTTPServer/conf/magic && \
    sudo mkdir -p /opt/IBM/WebSphere/Plugins/logs/ && \
    /opt/IBM/WebSphere/AppServer/bin/GenPluginCfg.sh && \
    printf '\n\
LoadModule was_ap24_module /opt/IBM/HTTPServer/plugin/bin/mod_was_ap24_http.so\n\
WebSpherePluginConfig /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/config/cells/plugin-cfg.xml\n\
\n' | sudo tee -a /opt/IBM/HTTPServer/conf/httpd.conf && \
    printf '\n\
[program:ihs]\n\
command=/opt/IBM/HTTPServer/bin/apachectl-std start\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startretries=0\n\
startsecs=0\n\
autorestart=false\n\
priority=70\n\
user=was\n\
autostart=true\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee /etc/supervisord.d/ihs.supervisord.conf

RUN sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    echo "Configure global security" && \
    printf 'dn: cn=wsadminldap,ou=Users,dc=example,dc=com\n\
cn: wsadminldap\n\
sn: wsadminldap\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: wsadminldap\n\
\n\
dn: cn=webSecOnly,ou=Users,dc=example,dc=com\n\
cn: webSecOnly\n\
objectClass: groupOfNames\n\
member: cn=Admin1,ou=Users,dc=example,dc=com\n\
\n\
dn: cn=grp1,ou=Users,dc=example,dc=com\n\
cn: grp1\n\
objectClass: groupOfNames\n\
member: cn=Admin1,ou=Users,dc=example,dc=com\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /root/wsadmin.ldif && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/wsadmin.ldif && \
    printf "\n\
AdminTask.createIdMgrLDAPRepository('[-default true -id LDAP1 -adapterClassName com.ibm.ws.wim.adapter.ldap.LdapAdapter -ldapServerType CUSTOM -sslConfiguration -certificateMapMode exactdn -supportChangeLog none -certificateFilter -loginProperties uid]')\n\
AdminTask.addIdMgrLDAPServer('[-id LDAP1 -host localhost -bindDN cn=Manager,dc=example,dc=com -bindPassword %s -referal ignore -sslEnabled false -ldapServerType CUSTOM -sslConfiguration -certificateMapMode exactdn -certificateFilter -authentication simple -port 389]')\n\
AdminTask.addIdMgrRepositoryBaseEntry('[-id LDAP1 -name dc=example,dc=com -nameInRepository dc=example,dc=com]')\n\
AdminTask.addIdMgrRealmBaseEntry('[-name defaultWIMFileBasedRealm -baseEntry dc=example,dc=com]')\n\
AdminTask.configureAdminWIMUserRegistry('[-realmName defaultWIMFileBasedRealm -verifyRegistry true ]')\n\
AdminTask.configureAdminWIMUserRegistry('[-autoGenerateServerId true -primaryAdminId wsadmin -ignoreCase true -customProperties -verifyRegistry true ]')\n\
AdminTask.mapUsersToAdminRole('[-accessids [user:defaultWIMFileBasedRealm/cn=Admin1,ou=Users,dc=example,dc=com] -userids [Admin1] -roleName administrator]')\n\
AdminTask.mapUsersToAdminRole('[-accessids [user:defaultWIMFileBasedRealm/cn=wsadminldap,ou=Users,dc=example,dc=com] -userids [wsadminldap] -roleName administrator]')\n\
AdminTask.setAdminActiveSecuritySettings('[-appSecurityEnabled true]')\n\
AdminApp.edit('DayTrader7', '[ -MapRolesToUsers [[ AllAuthenticated AppDeploymentOption.No AppDeploymentOption.Yes \"\" \"\" AppDeploymentOption.No \"\" \"\" ]]]')\n\
AdminApp.edit('DayTrader7', '[ -MapRolesToUsers [[ webSecOnly AppDeploymentOption.No AppDeploymentOption.No \"\" webSecOnly AppDeploymentOption.No \"\" group:defaultWIMFileBasedRealm/cn=webSecOnly,ou=Users,dc=example,dc=com ]]]' )\n\
AdminApp.edit('DayTrader7', '[ -MapRolesToUsers [[ grp1 AppDeploymentOption.No AppDeploymentOption.No \"\" grp1 AppDeploymentOption.No \"\" group:defaultWIMFileBasedRealm/cn=grp1,ou=Users,dc=example,dc=com ]]]' )\n\
\n\
AdminConfig.save()\n\
\n" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" > /home/was/twas_config_ldap.jy && \
    /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
    /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas_config_ldap.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
    /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
    sudo sed -i 's/Accept-Language/Authorization/g' /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo sed -i "s/en-us/Basic $(echo -n "Admin1:$(echo -n "$(sudo head -n 1 /root/password.txt)")" | base64)/g" /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo sed -i 's/Accept-Language/Authorization/g' /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx && \
    sudo sed -i "s/en-us/Basic $(echo -n "Admin1:$(echo -n "$(sudo head -n 1 /root/password.txt)")" | base64)/g" /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx && \
    printf '\n\
LOG_DIR=/opt/ibm/wlp/usr/servers/test/logs/\n\
WLP_OUTPUT_DIR=/opt/ibm/wlp/usr/servers/\n\
' >> /opt/ibm/wlp/usr/servers/test/server.env && \
    sudo sed -i 's/-Xmx2g/-Xmx3g/g' /opt/mat/ibmjava/MemoryAnalyzer.ini && \
    sudo sed -i 's/-Xmx2g/-Xmx3g/g' /opt/mat/openj9/MemoryAnalyzer.ini && \
    sudo chmod a+x /opt/sibexplorer/sibexplorer.sh && \
    sudo rm /opt/sibexplorer/*.bat && \
    sudo sed -i 's/SWTJARS=.*/SWTJARS=\/opt\/swt\//g' /opt/sibexplorer/env.sh && \
    sudo sed -i 's/CUR=.*/CUR=\/opt\/sibexplorer\//g' /opt/sibexplorer/env.sh && \
    sudo sed -i 's/WAS\/java/WAS\/java\/8.0/g' /opt/sibexplorer/sibexplorer.sh && \
    sudo sed -i 's/.\/env.sh/\/opt\/sibexplorer\/env.sh/g' /opt/sibexplorer/sibexplorer.sh && \
    printf '[Desktop Entry]\nType=Application\nName=SIB Explorer\nExec=/opt/sibexplorer/sibexplorer.sh\nPath=/opt/sibexplorer/\nTerminal=false\n' | sudo tee /opt/sibexplorer/sibexplorer.desktop && \
    sudo chmod a+x /opt/sibexplorer/sibexplorer.desktop && \
    sudo ln -s /opt/sibexplorer/sibexplorer.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/sibexplorer.desktop /home/was/Desktop/ && \
    printf '#SIBExplorer properties\n\
Y=0\n\
X=0\n\
trustPassword0={xor}CDo9Hgw\\=\n\
jsChain0=BootstrapBasicMessaging\n\
soapPort0=8880\n\
serverIds=0\n\
resyncOnObjCreate=1\n\
jsUserAlternateUserName0=0\n\
maximised=1\n\
protocol0=SOAP\n\
keyLocation0=/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/etc/DummyClientKeyFile.jks\n\
viewSystemObjs=0\n\
jsHost0=\n\
serverName0=tWAS\n\
jsUserName0=\n\
keyPassword0={xor}CDo9Hgw\\=\n\
password0={xor}KDo9LC83Oi06\n\
serverHostName0=localhost\n\
jsPassword0={xor}\n\
createNewSSLStores0=0\n\
securityEnabled0=1\n\
height=400\n\
autoRefresh=0\n\
width=400\n\
jsPort0=7276\n\
userName0=wsadmin\n\
trustLocation0=/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/etc/DummyClientTrustFile.jks\n\
viewTempObjs=0\n\
' > /home/was/.sibExplorer.conf && \
    sudo chown was:root /home/was/.sibExplorer.conf && \
    sudo mv /opt/sibperf/SIBPerf/* /opt/sibperf/ && \
    sudo rmdir /opt/sibperf/SIBPerf/ && \
    sudo chmod a+x /opt/sibperf/sibperf.sh && \
    sudo rm /opt/sibperf/*.bat && \
    sudo sed -i 's/SWTJARS=.*/SWTJARS=\/opt\/swt\//g' /opt/sibperf/env.sh && \
    sudo sed -i 's/SIBPerfDir=.*/SIBPerfDir=\/opt\/sibperf\//g' /opt/sibperf/env.sh && \
    sudo sed -i 's/WAS_HOME=.*/WAS_HOME=\/opt\/IBM\/WebSphere\/AppServer/g' /opt/sibperf/env.sh && \
    sudo sed -i 's/WAS_HOME\/java/WAS_HOME\/java\/8.0/g' /opt/sibperf/sibperf.sh && \
    printf '##SIBPerf Properties file Tue Nov 26 23:42:49 UTC 2019\n\
SHELL_YLEN=746\n\
PORT=8880\n\
USER=wsadmin\n\
MAXIMISE_WINDOW=false\n\
SHELL_XLEN=1030\n\
CONNECTOR=0\n\
HOST=localhost\n\
SHELL_Y=3\n\
SECURITY=true\n\
SHELL_X=0\n\
' | sudo tee /opt/sibperf/sibPerf.properties && \
    sudo chown was:root /opt/sibperf/sibPerf.properties && \
    sudo sed -i 's/.\/env.sh/\/opt\/sibperf\/env.sh/g' /opt/sibperf/sibperf.sh && \
    sudo sed -i 's/^\. \.\/setup.*/. $WAS_HOME\/profiles\/AppSrv01\/bin\/setupCmdLine.sh/g' /opt/sibperf/sibperf.sh && \
    printf '[Desktop Entry]\nType=Application\nName=SIB Performance\nExec=/opt/sibperf/sibperf.sh\nPath=/opt/sibperf/\nTerminal=false\n' | sudo tee /opt/sibperf/sibperf.desktop && \
    sudo chmod a+x /opt/sibperf/sibperf.desktop && \
    sudo ln -s /opt/sibperf/sibperf.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/sibperf.desktop /home/was/Desktop/ && \
    echo "# IBM Database Connection Pool Analyzer for IBM WebSphere Application Server" && \
    echo "# https://www.ibm.com/support/pages/ibm-database-connection-pool-analyzer-ibm-websphere-application-server" && \
    ( \
      sudo mkdir /opt/dbconnpoolanalyzer/ && \
      cd /opt/dbconnpoolanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/jcp/jcp23.zip && \
      sudo unzip -q *.zip && \
      sudo rm -f *.zip *.exe \
    ) && \
    ( \
      echo "# PerformanceTuningToolkit: https://www.ibm.com/support/pages/websphere-application-server-performance-tuning-toolkit" && \
      echo "# SOAP Port: 8880" && \
      sudo mkdir /opt/ptt/ && \
      cd /opt/ptt/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/ptt/com.ibm.ptt-linux.gtk.x86_64.tar.gz && \
      sudo tar xzf *.tar.gz && \
      sudo rm -f *.tar.gz && \
      sudo sed -i 's/-Dcom.ibm.ssl.evaluateHost=true/-Dcom.ibm.ssl.evaluateHost=false/g' /opt/ptt/ptt.ini && \
      printf '#!/bin/sh\n\
        /opt/ptt/ptt -vm /opt/openjdk11_ibm/jdk/bin/ -debug -consoleLog\n\
      ' | sudo tee /opt/ptt/ptt.sh && \
      sudo chmod a+x /opt/ptt/ptt.sh && \
      sudo mkdir /home/was/ptt/ && \
      sudo chown -R was:root /home/was/ptt/ && \
      printf '[Desktop Entry]\nType=Application\nName=Performance Tuning Toolkit\nExec=/opt/ptt/ptt.sh\nPath=ptt/\nTerminal=false\n' | sudo tee /opt/ptt/ptt.desktop && \
      sudo chmod a+x /opt/ptt/ptt.desktop && \
      sudo ln -s /opt/ptt/ptt.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/ptt.desktop /home/was/Desktop/ \
    ) && \
    ( \
      echo "# IBM Service Integration Bus Destination Handler: https://www.ibm.com/support/pages/ibm-service-integration-bus-destination-handler" && \
      sudo mkdir /opt/sibdesthandler/ && \
      cd /opt/sibdesthandler/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/sibdesthandler/SIBDestinationHandler-2.0.20221122.jar && \
      printf '#!/bin/sh\n\
        java -Djavax.net.ssl.trustStore=/IBM/WebSphere/AppServer/profiles/Dmgr01/etc/DummyClientTrustFile.jks -Djavax.net.ssl.trustStorePassword=WebAS -Xmx1g -jar /opt/sibdesthandler/SIBDestinationHandler-2.0.20221122.jar\n\
      ' | sudo tee /opt/sibdesthandler/sibdesthandler.sh && \
      sudo chmod a+x /opt/sibdesthandler/sibdesthandler.sh && \
      sudo mkdir /home/was/sibdesthandler/ && \
      sudo chown -R was:root /home/was/sibdesthandler/ && \
      printf '[Desktop Entry]\nType=Application\nName=SIB Destination Handler\nExec=/opt/sibdesthandler/sibdesthandler.sh\nPath=sibdesthandler/\nTerminal=false\n' | sudo tee /opt/sibdesthandler/sibdesthandler.desktop && \
      sudo chmod a+x /opt/sibdesthandler/sibdesthandler.desktop && \
      sudo ln -s /opt/sibdesthandler/sibdesthandler.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/sibdesthandler.desktop /home/was/Desktop/ \
    ) && \
    /opt/ibm/wlp/bin/server start defaultServer --clean && \
    /opt/ibm/wlp/bin/server stop defaultServer

RUN echo "# Backup and clear Liberty and tWAS logs" && \
    sudo mkdir /backup/ && \
    sudo mkdir /backup/liberty/ && \
    sudo mkdir /backup/twas/ && \
    sudo mkdir /backup/twas/ffdc/ && \
    sudo mv /logs/* /backup/liberty/ && \
    sudo mv /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/server1/* /backup/twas/ && \
    sudo mv /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/ffdc/* /backup/twas/ffdc/ && \
    sudo chown -R was:root /backup/

RUN echo "Example data V20230320" && \
    echo "https://github.com/ibm/webspherelab" && \
    sudo git clone https://github.com/ibm/webspherelab /opt/webspherelab/ && \
    sudo chown -R was:root /opt/webspherelab/ && \
    ln -s /opt/webspherelab/supplemental/exampledata/ /home/was/Desktop/exampledata

# Update lab document by updating the date in the echo and rebuild:
RUN ( \
      echo "Lab Document V20230320" && \
      cd /opt/webspherelab/ && \
      sudo git pull && \
      echo "Don't use --metadata title= here and just ignore the warning about it missing" && \
      sudo pandoc -s -o WAS_Troubleshooting_Perf_Lab.html WAS_Troubleshooting_Perf_Lab.md && \
      ln -s "/opt/webspherelab/WAS_Troubleshooting_Perf_Lab.html" "/home/was/Desktop/" && \
      sudo pandoc -s -o Liberty_Perf_Lab.html Liberty_Perf_Lab.md && \
      ln -s "/opt/webspherelab/Liberty_Perf_Lab.html" "/home/was/Desktop/" \
    )

EXPOSE 3389 5901 5902 8080 8081 8082 9080 9081 9082 9083 9443 9444 9445 12000 12005

# Last statement must be switching to root for supervisord
USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
