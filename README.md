FFmpeg Build for CentOS 6
===========================
This Docker image builds static ffmpeg libraries (and binaries) for CentOS 6.
Its primary goal is to provide the static libraries that will be compiled into
*minidlna*. The RPMs for ffmpeg on rpmforge are extremely dated and installing
several of those RPMs end up adding a lot of crap (minidlna is the only
consumer of ffmpeg for me), so this exists to solve that problem.

The ffmpeg libraries contain mostly decoders and not encoders. Most of the
dependent libraries are also compiled in statically, except for open-source
projects which have binary RPMs for more recent versions, such as Vorbis.


Usage
------

Use the following command to build a Docker image containing `ffmpeg`:

	git clone https://github.com/geekman/docker-centos-ffmpeg
	docker build -t zxgm/ffmpeg-build docker-centos-ffmpeg

Using the built Docker image, you can run `ffmpeg` or `ffprobe` like so:

	docker run --rm -t -i zxgm/ffmpeg-build ffmpeg

Of course it's useless if you can't operate on any files, so you will need to
use `-v` to mount your volumes.

