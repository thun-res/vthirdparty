#!/usr/bin/env bash

SHELL_DIR=$(dirname $(readlink -f "$0"))

cd $SHELL_DIR

# autoscan
# aclocal
# autoconf
# automake --add-missing

BUILD_CPU_CORE=${VKIT_BUILD_CPU_CORE:-$(nproc)}

if [[ $1 == *-DENABLE_INSTALL_PRIVATE* ]];then
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_PRIVATE_DIR --enable-shared=no --enable-static=yes --with-pic"
else
    BUILD_TYPE_ARGS="--prefix=$VKIT_PREBUILT_DIR --enable-shared=yes --enable-static=no --with-pic"
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
    --disable-tcl \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE
    make install > /dev/null
elif [ "$VKIT_PLATFORM" = "linux-aarch64" ] || [ "$VKIT_PLATFORM" = "freebsd-aarch64" ];then
    export CC=${CC:-${CROSS_COMPILE_PREFIX}gcc}
    export CFLAGS="${CFLAGS} -I${VKIT_PREBUILT_DIR}/include -I${VKIT_PREBUILT_PRIVATE_DIR}/include"
    export LDFLAGS="${LDFLAGS} -L${VKIT_PREBUILT_DIR}/lib -L${VKIT_PREBUILT_PRIVATE_DIR}/lib"

    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        export CC="ccache ${CC}"
    fi

    $SHELL_DIR/configure -q --host=aarch64-linux \
    --disable-tcl \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE -s
    make install > /dev/null
elif [ "$VKIT_PLATFORM" = "android-x86_64" ];then
    export API=21
    export ARCH_FLAGS="-mthumb"
    export TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
    export CC=${CC:-${TOOLCHAIN}/bin/x86_64-linux-android${API}-clang}
    export CFLAGS="${CFLAGS} -I${VKIT_PREBUILT_DIR}/include -I${VKIT_PREBUILT_PRIVATE_DIR}/include -lm -fpic -ffunction-sections -funwind-tables -fstack-protector-all -fno-strict-aliasing -Wno-unused-command-line-argument"
    export LDFLAGS="${LDFLAGS} -L${VKIT_PREBUILT_DIR}/lib -L${VKIT_PREBUILT_PRIVATE_DIR}/lib"

    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        export CC="ccache ${CC}"
    fi

    $SHELL_DIR/configure -q --host=x86_64-linux \
    --disable-tcl \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE -s
    make install > /dev/null
elif [ "$VKIT_PLATFORM" = "android-aarch64" ];then
    export API=21
    export ARCH_FLAGS="-mthumb"
    export TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
    export CC=${CC:-${TOOLCHAIN}/bin/aarch64-linux-android${API}-clang}
    export CFLAGS="${CFLAGS} -I${VKIT_PREBUILT_DIR}/include -I${VKIT_PREBUILT_PRIVATE_DIR}/include -lm -fpic -ffunction-sections -funwind-tables -fstack-protector-all -fno-strict-aliasing -Wno-unused-command-line-argument"
    export LDFLAGS="${LDFLAGS} -L${VKIT_PREBUILT_DIR}/lib -L${VKIT_PREBUILT_PRIVATE_DIR}/lib"

    if [ "$VKIT_DISABLE_CCACHE" != "1" ] && which ccache >/dev/null 2>&1;then
        export CC="ccache ${CC}"
    fi

    $SHELL_DIR/configure -q --host=aarch64-linux \
    --disable-tcl \
    $(echo $BUILD_TYPE_ARGS)
    make -j$BUILD_CPU_CORE -s
    make install > /dev/null
else
    echo "Not support!"
    exit 1
fi
