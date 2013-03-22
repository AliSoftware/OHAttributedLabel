#!/bin/sh
# thank you gabriel ttps://github.com/gabriel

LIB_NAME="libOHAttributedLabel.a"
BUILD_DIR="./$1"
CONFIGURATION="$2"
LIB_DIR="${BUILD_DIR}/${CONFIGURATION}-Combined"

if [ ! -d "${LIB_DIR}" ]; then
  mkdir -p "${LIB_DIR}"
fi 

# Combine lib files
lipo -create "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${LIB_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${LIB_NAME}" -output "${LIB_DIR}/${LIB_NAME}"
cp -r "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include" "${LIB_DIR}"

# in lieu of a version number
VERSION_FILE="${LIB_DIR}/provenance.txt"
WHO=`whoami`
echo "who:            ${WHO}" > "${VERSION_FILE}"
DATE=$( /bin/date +"%Y-%m-%d %H:%M:%S" )
echo "date:            ${DATE}" >> "${VERSION_FILE}"
gitpath=`which git`
GITREV_SHORT=`$gitpath rev-parse --short HEAD`
GITREV_SHA=`$gitpath rev-parse HEAD`
echo "git rev (short): ${GITREV_SHORT}" >> "${VERSION_FILE}"
echo "git rev:         ${GITREV_SHA}" >> "${VERSION_FILE}"

open "${LIB_DIR}"