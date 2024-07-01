#!/bin/bash

# 获取当前路径
CURRENT_PATH=$(pwd)

BUILD_LIBS=$CURRENT_PATH/libs_build
FFMPEG_BUILD_LIBS=$CURRENT_PATH/build

if [ -d x264 ]; then
    echo "x264 already exists. Skipping download."
else
    git clone --depth 1 https://code.videolan.org/videolan/x264.git
fi
cd x264
echo "x264 configure"
./configure --cross-prefix=x86_64-w64-mingw32- --host=mingw64 --disable-swscale --disable-lavf --enable-pic --enable-static --enable-shared --disable-cli --prefix=$BUILD_LIBS
make -j$(nproc)
make install
cd ..

if [ -f x265_3.3.tar.gz ]; then
    echo "x265 already exists. Skipping download."
    if [ -d x265_3.3 ]; then
        echo "Directory exists. Skipping extract."
    else
        echo "Extracting x265_3.3.tar.gz"
        tar -xf x265_3.3.tar.gz
    fi
else
    curl -L https://bitbucket.org/multicoreware/x265_git/downloads/x265_3.3.tar.gz -o x265_3.3.tar.gz
    echo "Extracting x265_3.3.tar.gz"
    tar -xf x265_3.3.tar.gz
fi
cd x265_3.3/build/msys
echo "x265 configure"
cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain-x86_64-w64-mingw32.cmake -DCMAKE_INSTALL_PREFIX=$BUILD_LIBS ../../source
make -j$(nproc)
make install

cd ../../..

export PKG_CONFIG_PATH=$BUILD_LIBS/lib/pkgconfig:${PKG_CONFIG_PATH}

# Build ffmpeg for Windows and Linux
if [ -f ffmpeg-4.4.4.tar.gz ]; then
    echo "ffmpeg-4.4.4.tar.gz already exists. Skipping download."
    if [ -d ffmpeg-4.4.4 ]; then
        echo "Directory exists. Skipping extract."
    else
        echo "Extracting ffmpeg-4.4.4.tar.gz"
        tar -xf ffmpeg-4.4.4.tar.gz
    fi
else
    curl -L https://ffmpeg.org/releases/ffmpeg-4.4.4.tar.gz -o ffmpeg-4.4.4.tar.gz
    echo "Extracting ffmpeg-4.4.4.tar.gz"
    tar -xf ffmpeg-4.4.4.tar.gz
fi
cd ffmpeg-4.4.4

./configure \
    --disable-everything \
    --enable-demuxer=asf \
    --enable-muxer=mp4 \
    --enable-encoder=libx264 \
    --enable-decoder=wmv3 \
    --enable-parser=h264 \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-iconv \
    --enable-small \
    --target-os=mingw32 \
    --arch=x86_64 \
    --cross-prefix=x86_64-w64-mingw32- \
    --enable-cross-compile \
    --disable-ffprobe \
    --disable-ffplay \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --enable-libx265 \
    --enable-libx264 \
    --enable-gpl \
    --prefix=$FFMPEG_BUILD_LIBS

make -j$(nproc)
make install

# Merge all def files in $FFMPEG_BUILD_LIBS/lib into ffmpeg.def
cd $FFMPEG_BUILD_LIBS/lib
cat *.def > ffmpeg.def

# https://blog.51cto.com/u_15655186/6087352 合并dll 
# https://blog.csdn.net/selivert/article/details/126282342 x265




