# FROM appium/appium:v1.22.3-p1

# LABEL maintainer "Budi Utomo <budtmo.os@gmail.com>"

# #=============
# # Set WORKDIR
# #=============
# WORKDIR /root

# #==================
# # General Packages
# #------------------
# # xterm
# #   Terminal emulator
# # supervisor
# #   Process manager
# # socat
# #   Port forwarder
# #------------------
# #  NoVNC Packages
# #------------------
# # x11vnc
# #   VNC server for X display
# #       We use package from ubuntu 18.10 to fix crashing issue
# # openbox
# #   Windows manager
# # feh
# #   ScreenBackground
# # menu
# #   Debian menu
# # python-numpy
# #   Numpy, For faster performance: https://github.com/novnc/websockify/issues/77
# # net-tools
# #   Netstat
# #------------------
# #  Video Recording
# #------------------
# # ffmpeg
# #   Video recorder
# # jq
# #   Sed for JSON data
# #------------------
# #    KVM Package
# # for emulator x86
# # https://help.ubuntu.com/community/KVM/Installation
# #------------------
# # qemu-kvm
# # libvirt-bin
# # ubuntu-vm-builder
# # bridge-utils
# #==================
# ADD docker/configs/x11vnc.pref /etc/apt/preferences.d/
# RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
#     xterm \
#     supervisor \
#     socat \
#     x11vnc \
#     openbox \
#     feh \
#     menu \
#     python-numpy \
#     net-tools \
#     ffmpeg \
#     jq \
#     qemu-kvm \
#     libvirt-bin \
#     ubuntu-vm-builder \
#     bridge-utils \
#  && apt clean all \
#  && rm -rf /var/lib/apt/lists/*

# #=======
# # noVNC
# # Use same commit id that docker-selenium uses
# # https://github.com/elgalu/docker-selenium/blob/236b861177bd2917d864e52291114b1f5e4540d7/Dockerfile#L412-L413
# #=======
# ENV NOVNC_SHA="b403cb92fb8de82d04f305b4f14fa978003890d7" \
#     WEBSOCKIFY_SHA="558a6439f14b0d85a31145541745e25c255d576b"
# RUN  wget -nv -O noVNC.zip "https://github.com/kanaka/noVNC/archive/${NOVNC_SHA}.zip" \
#  && unzip -x noVNC.zip \
#  && rm noVNC.zip  \
#  && mv noVNC-${NOVNC_SHA} noVNC \
#  && wget -nv -O websockify.zip "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
#  && unzip -x websockify.zip \
#  && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
#  && rm websockify.zip \
#  && ln noVNC/vnc_auto.html noVNC/index.html

# #======================
# # Install SDK packages
# #======================
# # ARG ANDROID_VERSION=11.0
# # ARG API_LEVEL=30

# # ARG ANDROID_VERSION=R
# # ARG API_LEVEL=R

# ARG ANDROID_VERSION=5.0.1
# ARG API_LEVEL=21

# ARG PROCESSOR=x86_64
# ARG SYS_IMG=x86_64
# ARG IMG_TYPE=google_apis
# ARG BROWSER=android
# ARG CHROME_DRIVER=2.40
# ARG GOOGLE_PLAY_SERVICE=12.8.74
# ARG GOOGLE_PLAY_STORE=11.0.50
# ARG APP_RELEASE_VERSION=1.5-p0
# ENV ANDROID_VERSION=$ANDROID_VERSION \
#     API_LEVEL=$API_LEVEL \
#     PROCESSOR=$PROCESSOR \
#     SYS_IMG=$SYS_IMG \
#     IMG_TYPE=$IMG_TYPE \
#     BROWSER=$BROWSER \
#     CHROME_DRIVER=$CHROME_DRIVER \
#     GOOGLE_PLAY_SERVICE=$GOOGLE_PLAY_SERVICE \
#     GOOGLE_PLAY_STORE=$GOOGLE_PLAY_STORE \
#     GA=true \
#     GA_ENDPOINT=https://www.google-analytics.com/collect \
#     GA_TRACKING_ID=UA-133466903-1 \
#     GA_API_VERSION="1" \
#     APP_RELEASE_VERSION=$APP_RELEASE_VERSION \
#     APP_TYPE=Emulator
# ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

# RUN yes | sdkmanager --licenses && \
#     sdkmanager "platforms;android-${API_LEVEL}" "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" "emulator"

# #==============================================
# # Download proper version of chromedriver
# # to be able to use Chrome browser in emulator
# #==============================================
# RUN wget -nv -O chrome.zip "https://chromedriver.storage.googleapis.com/${CHROME_DRIVER}/chromedriver_linux64.zip" \
#  && unzip -x chrome.zip \
#  && rm chrome.zip

# #================================================================
# # Download Google Play Services APK and Play Store from apklinker
# #================================================================
# #Run wget -nv -O google_play_services.apk "https://www.apklinker.com/wp-content/uploads/uploaded_apk/5b5155e5ef4f8/com.google.android.gms_${GOOGLE_PLAY_SERVICE}-020700-204998136_12874013_MinAPI21_(x86)(nodpi)_apklinker.com.apk"
# #Run wget -nv -O google_play_store.apk "https://www.apklinker.com/wp-content/uploads/uploaded_apk/5b632b1164e31/com.android.vending_${GOOGLE_PLAY_STORE}-all-0-PR-206665793_81105000_MinAPI16_(armeabi,armeabi-v7a,mips,mips64,x86,x86_64)(240,320,480dpi)_apklinker.com.apk"

# #================================================
# # noVNC Default Configurations
# # These Configurations can be changed through -e
# #================================================
# ENV DISPLAY=:0 \
#     SCREEN=0 \
#     SCREEN_WIDTH=1600 \
#     SCREEN_HEIGHT=900 \
#     SCREEN_DEPTH=24+32 \
#     LOCAL_PORT=5900 \
#     TARGET_PORT=6080 \
#     TIMEOUT=1 \
#     VIDEO_PATH=/tmp/video \
#     LOG_PATH=/var/log/supervisor

# #================================================
# # openbox configuration
# # Update the openbox configuration files to:
# #   + Use a single virtual desktop to prevent accidentally switching 
# #   + Add background
# #================================================
# ADD images/logo_dockerandroid.png /root/logo.png
# ADD src/.fehbg /root/.fehbg
# ADD src/rc.xml /etc/xdg/openbox/rc.xml
# RUN echo /root/.fehbg >> /etc/xdg/openbox/autostart

# #======================
# # Workarounds
# #======================
# # Fix emulator from crashing when running as root user.
# # See https://github.com/budtmo/docker-android/issues/223
# ENV QTWEBENGINE_DISABLE_SANDBOX=1

# #===============
# # Expose Ports
# #---------------
# # 4723
# #   Appium port
# # 6080
# #   noVNC port
# # 5554
# #   Emulator port
# # 5555
# #   ADB connection port
# #===============
# EXPOSE 4723 6080 5554 5555

# #======================
# # Add Emulator Devices
# #======================
# COPY devices ${ANDROID_HOME}/devices

# #===================
# # Run docker-appium
# #===================
# COPY src /root/src
# COPY supervisord.conf /root/
# RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf

# HEALTHCHECK --interval=2s --timeout=40s --retries=1 \
#     CMD timeout 40 adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

# RUN ln -s ${ANDROID_HOME}/emulator/emulator /usr/bin/

# CMD /usr/bin/supervisord --configuration supervisord.conf




FROM ubuntu:18.04 AS bu
RUN apt-get update \
    && apt-get install -y wget unzip openjdk-8-jdk

ENV ANDROID_SDK=/usr/local/android_tools
RUN mkdir -p /usr/local/android_tools \
    && cd $ANDROID_SDK \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
    && unzip -q sdk-tools-linux-4333796.zip \
    && rm sdk-tools-linux-4333796.zip

ENV ANDROID_KVM=system-images;android-28;google_apis_playstore;x86_64
ENV ANDROID_ARM=system-images;android-24;default;arm64-v8a

RUN mkdir -p $HOME/.android \
    && touch $HOME/.android/repositories.cfg \
    && yes | $ANDROID_SDK/tools/bin/sdkmanager "platform-tools" "platforms;android-28" "emulator" "build-tools;28.0.2" "tools" "$ANDROID_ARM" "$ANDROID_KVM"

RUN echo "no" | $ANDROID_SDK/tools/bin/avdmanager create avd -n aName -k  "$ANDROID_ARM" -c 300M

EXPOSE 5554
CMD ($ANDROID_SDK/tools/emulator @aName -no-skin -no-audio -no-window)


FROM bu
ENV DEBIAN_FRONTEND=noninteractive
ARG ROOT_PASSWORD
RUN sed -i.bak -e "s%http://us.archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# Install packages
RUN apt-get update \
    && \
    # Install the required packages for display    
    apt-get install -y --no-install-recommends \
      supervisor \
      openssh-server \
      xvfb \
      x11vnc \
      # && \
    # Install utilities(optional).
    # apt-get install -y \
      git \
      sudo \
      wget \
      curl \
      net-tools \
      vim-tiny \
      # && \
    #python packages
    # apt-get install -y \
      python3-pip \
      python-opengl \
      python3-setuptools \
      && \
    # Clean up
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN pip3 install gym

# set up ssh
RUN mkdir -p /var/run/sshd
RUN echo root:${ROOT_PASSWORD}| chpasswd

RUN sed -i 's/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# add user
RUN useradd -m -s /bin/bash user
RUN echo user:${ROOT_PASSWORD}| chpasswd
WORKDIR /home/user/workspace

USER root
WORKDIR /root

RUN echo "export DISPLAY=:0"  >> /etc/profile
EXPOSE 8080 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
# CMD ["/startup.sh"]

