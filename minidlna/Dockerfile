#
# Dockerfile for compiling minidlna RPM
#

FROM zxgm/ffmpeg-build
MAINTAINER Darell Tan <darell.tan@gmail.com>

WORKDIR /tmp/buildroot

RUN yum -y install rpm-build libexif-devel libjpeg-devel libid3tag-devel flac-devel sqlite-devel libuuid-devel gettext

COPY minidlna* *.patch build-rpm.sh /tmp/buildroot/

