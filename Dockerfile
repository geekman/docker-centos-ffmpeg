#
# Dockerfile for compiling FFmpeg libraries for CentOS
# Adapted from https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
#
# Tries to minimize RPMs required from external repos, while keeping
# open-source dependencies (like vorbis). Current build includes only decoder
# libraries, as it is meant for compiling minidlna.
#

FROM centos:centos6
MAINTAINER Darell Tan <darell.tan@gmail.com>

RUN yum -y update && yum clean packages
RUN yum -y install epel-release 
RUN yum -y install gcc gcc-c++ libtool autoconf automake make nasm pkgconfig zlib-devel git curl tar \
	yasm opus-devel libogg-devel libvorbis-devel libvpx-devel freetype-devel libtheora-devel \
	&& \
	yum clean packages

COPY config_make /usr/bin/

WORKDIR /tmp/buildroot

# libx264 - H.264 encoder
RUN git clone --depth 1 git://git.videolan.org/x264 && \
	cd x264 && \
	config_make --enable-static && \
	cd .. && rm -rf x264

# updated libtool for libfdk_aac
RUN yum -y install texinfo help2man xz patch
RUN git clone --depth 1 git://git.savannah.gnu.org/libtool.git && \
	cd libtool && \
	./bootstrap && \
	config_make && \
	cd .. && rm -rf libtool

# libfdk_aac - AAC encoder
RUN git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac && \
	cd fdk-aac && \
	autoreconf -fiv && \
	config_make --disable-shared && \
	cd .. && rm -rf fdk-aac

# libmp3lame - MP3 encoder
RUN curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
	tar xzvf lame-3.99.5.tar.gz && \
	      cd lame-3.99.5        && \
	config_make --disable-shared --enable-nasm && \
	cd .. && rm -rf lame-*

# FFmpeg
#--enable-libx264 --enable-libfdk_aac --enable-libmp3lame \ 
#--enable-libvorbis --enable-libvpx \
RUN git clone --depth 1 git://source.ffmpeg.org/ffmpeg && \
	cd ffmpeg && \
	config_make --enable-gpl --enable-nonfree \
		--enable-libopus && \
	cd .. && rm -rf ffmpeg

