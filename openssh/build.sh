#!/usr/bin/env bash

SHELL_DIR=$(dirname $(readlink -f "$0"))

cd $SHELL_DIR

autoscan
aclocal
autoconf
automake --add-missing

BUILD_CPU_CORE=${VKIT_BUILD_CPU_CORE:-$(nproc)}

if [[ $1 == *-DENABLE_INSTALL_PRIVATE* ]];then
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_PRIVATE_DIR --with-privsep-path=$VKIT_PREBUILT_PRIVATE_DIR/var/empty --disable-strip --disable-etc-default-login --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx"
    export PRIVSEP_PATH=$VKIT_PREBUILT_PRIVATE_DIR/data/run
else
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_DIR --with-privsep-path=$VKIT_PREBUILT_DIR/var/empty --disable-strip --disable-etc-default-login --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx"
    export PRIVSEP_PATH=$VKIT_PREBUILT_DIR/data/run
fi

if [ "$VKIT_PLATFORM" = "linux-x86_64" ] || [ "$VKIT_PLATFORM" = "freebsd-x86_64" ] || [ "$VKIT_PLATFORM" = "freebsd-amd64" ];then
    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        if [ -n "$CC" ];then
            export CC="ccache ${CC}"
        else
            export CC="ccache gcc"
        fi
    fi
    $SHELL_DIR/configure -q \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE -s
    make install-files > /dev/null
elif [ "$VKIT_PLATFORM" = "linux-aarch64" ] || [ "$VKIT_PLATFORM" = "freebsd-aarch64" ];then
    export CC=${CC:-${CROSS_COMPILE_PREFIX}gcc}
    export CFLAGS="${CFLAGS} -I${VKIT_PREBUILT_DIR}/include -I${VKIT_PREBUILT_PRIVATE_DIR}/include"
    export LDFLAGS="${LDFLAGS} -L${VKIT_PREBUILT_DIR}/lib -L${VKIT_PREBUILT_PRIVATE_DIR}/lib"

    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        export CC="ccache ${CC}"
    fi

    $SHELL_DIR/configure -q --host=aarch64-linux \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE -s
    make install-files > /dev/null
else
    echo "Not support!"
    exit 1
fi
