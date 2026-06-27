#!/usr/bin/env bash

OLD_DIR=$(pwd)

trap "cd $OLD_DIR" EXIT

SHELL_DIR=$(dirname $(readlink -f "$0"))

cd $SHELL_DIR

[ ! -f ./b2 ] && ./bootstrap.sh

BOOST_COMPONENTS="
--with-system
--with-filesystem
--with-thread
--with-log
--with-chrono
--with-regex
--with-log
--with-timer
--with-date_time
--with-atomic
--with-serialization
--with-program_options
--with-exception
--with-iostreams
--with-locale
--with-test
"

BUILD_CPU_CORE=${VKIT_BUILD_CPU_CORE:-$(nproc)}

if [[ $1 == *-DENABLE_INSTALL_PRIVATE* ]];then
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_PRIVATE_DIR link=static"
else
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_DIR link=static"
fi

if [ "$VKIT_PLATFORM" = "qnx-aarch64" ];then
    ./b2 --quiet install \
        toolset=qcc target-os=qnxnto \
        cxxflags="-fPIC -Vgcc_ntoaarch64le -Y_cxx -D_QNX_SOURCE=1 -D_LITTLE_ENDIAN" \
        linkflags="-Vgcc_ntoaarch64le -Y_cxx -lang-c++" \
        threadapi=pthread link=static variant=release \
        --layout=system --build-type=minimal \
        $(echo $BUILD_TYPE_ARGS) \
        $(echo $BOOST_COMPONENTS) \
        -j$BUILD_CPU_CORE -d0 -q
elif [ "$VKIT_PLATFORM" = "qnx-x86_64" ];then
    ./b2 --quiet install \
        toolset=qcc target-os=qnxnto \
        cxxflags="-fPIC -Vgcc_ntox86_64 -Y_cxx -D_QNX_SOURCE=1 -D_LITTLE_ENDIAN" \
        linkflags="-Vgcc_ntox86_64 -Y_cxx -lang-c++" \
        threadapi=pthread link=static variant=release \
        --layout=system --build-type=minimal \
        $(echo $BUILD_TYPE_ARGS) \
        $(echo $BOOST_COMPONENTS) \
        -j$BUILD_CPU_CORE -d0 -q
elif [ "$VKIT_PLATFORM" = "android-aarch64" ];then
    PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH && \
    ./b2 --quiet install \
        toolset=clang target-os=android \
        cxxflags="-fPIC -target aarch64-linux-android30" \
        threadapi=pthread link=static variant=release \
        --layout=system --build-type=minimal \
        $(echo $BUILD_TYPE_ARGS) \
        $(echo $BOOST_COMPONENTS) \
        -j$BUILD_CPU_CORE -d0 -q
elif [ "$VKIT_PLATFORM" = "android-x86_64" ];then
    PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH && \
    ./b2 --quiet install \
        toolset=clang target-os=android \
        cxxflags="-fPIC -target x86_64-linux-android30" \
        threadapi=pthread link=static variant=release \
        --layout=system --build-type=minimal \
        $(echo $BUILD_TYPE_ARGS) \
        $(echo $BOOST_COMPONENTS) \
        -j$BUILD_CPU_CORE -d0 -q
elif [ "$VKIT_PLATFORM" = "linux-aarch64" ] || [ "$VKIT_PLATFORM" = "freebsd-aarch64" ];then
    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        export CC="ccache ${CC}"
        export CXX="ccache ${CXX}"
    fi

    if [ ! -z "${CROSS_COMPILE_PREFIX}" ];then
        sed -i "s#using gcc ;#using gcc : aarch64 : ${CROSS_COMPILE_PREFIX}gcc ;#g" ./project-config.jam
        ./b2 --quiet install \
            toolset=gcc target-os=linux \
            cxxflags="-fPIC" \
            threadapi=pthread link=static variant=release \
            --layout=system --build-type=minimal \
            $(echo $BUILD_TYPE_ARGS) \
            $(echo $BOOST_COMPONENTS) \
            -j$BUILD_CPU_CORE -d0 -q
    elif [ ! -z "${CC}" ];then
        sed -i "s#using gcc ;#using gcc : aarch64 : ${CC} ;#g" ./project-config.jam
        ./b2 --quiet install \
            toolset=gcc target-os=linux \
            cxxflags="-fPIC" \
            threadapi=pthread link=static variant=release \
            --layout=system --build-type=minimal \
            $(echo $BUILD_TYPE_ARGS) \
            $(echo $BOOST_COMPONENTS) \
            -j$BUILD_CPU_CORE -d0 -q
    else
        echo "Not support!"
        exit 1
    fi
elif [ "$VKIT_PLATFORM" = "linux-x86_64" ] || [ "$VKIT_PLATFORM" = "freebsd-x86_64" ] || [ "$VKIT_PLATFORM" = "freebsd-amd64" ];then
    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        if [ -n "$CC" ];then
            export CC="ccache ${CC}"
            export CXX="ccache ${CXX}"
        else
            export CC="ccache gcc"
            export CXX="ccache g++"
        fi
    fi

    ./b2 --quiet install \
        toolset=gcc target-os=linux \
        cxxflags="-fPIC" \
        threadapi=pthread link=static variant=release \
        --layout=system --build-type=minimal \
        $(echo $BUILD_TYPE_ARGS) \
        $(echo $BOOST_COMPONENTS) \
        -j$BUILD_CPU_CORE -d0 -q
else
    echo "Not support!"
    exit 1
fi
