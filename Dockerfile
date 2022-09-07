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





FROM openjdk:8

MAINTAINER javavirys@gmail.com
USER root

ARG android_compile_sdk
ARG android_build_tools
ARG android_sdk_tools


ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-$android_sdk_tools.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=$android_compile_sdk \
    PROJECT_NAME=$project_name \
    ANDROID_BUILD_TOOLS_VERSION=$android_build_tools

ENV ANDROID_SDK=$ANDROID_HOME

RUN export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$PATH

RUN apt-get update 

RUN apt-get -y install unzip
RUN apt-get -y install curl wget
RUN apt-get -y install software-properties-common
RUN apt-get -y install libgl1-mesa-glx

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Install Android Build Tool and Libraries
RUN $ANDROID_HOME/tools/bin/sdkmanager --update | grep -v = || true
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools" | grep -v = || true

RUN $ANDROID_HOME/tools/bin/sdkmanager emulator | grep -v = || true
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-29;google_apis;x86" | grep -v = || true
RUN $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-25;google_apis;armeabi-v7a" | grep -v = || true

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

RUN $ANDROID_HOME/tools/bin/avdmanager create avd -n mynexus -k "system-images;android-29;google_apis;x86" --tag "google_apis" --device "Nexus 5"
RUN $ANDROID_HOME/tools/bin/avdmanager create avd -n mynexus -k "system-images;android-25;google_apis;armeabi-v7a" --tag "google_apis" --device "Nexus 5 armeabi"

RUN apt-get update && apt-get -y install android-tools-adb android-tools-fastboot
