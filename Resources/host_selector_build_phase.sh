#!/bin/sh

#  host_selector_build_phase.sh
#
# Copyright (c) 2013 RoleModel Software, Inc
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

PLIST_BUDDY='/usr/libexec/PlistBuddy'
RESOURCE_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
HOSTS_PLIST_PATH="${RESOURCE_PATH}"/Hosts.plist

rms_host_key() {
    RMS_HOST_KEY="production"
    UNESCAPED_GCC_PREPROCESSOR_DEFINITIONS=`echo ${GCC_PREPROCESSOR_DEFINITIONS} | sed "s/\\\\\//g"`
    for DEF in ${UNESCAPED_GCC_PREPROCESSOR_DEFINITIONS}
    do
        KEY=`echo $DEF | cut -f1 -d=`
        if [ $KEY == "RMS_HOST_KEY" ]
        then
            RMS_HOST_KEY=`echo $DEF | cut -f2 -d=`
            echo "Found RMS_HOST_KEY preprocessor definition: $RMS_HOST_KEY" >&2
        fi
    done
    echo $RMS_HOST_KEY
}

if [ "${CONFIGURATION}" == "Release" ]
then
    RMS_HOST_KEY=`rms_host_key`
    PRODUCTION_HOST=`"${PLIST_BUDDY}" -c "Print :${RMS_HOST_KEY}" "${HOSTS_PLIST_PATH}"`

    /bin/rm -f "${HOSTS_PLIST_PATH}"

    if [ "${PRODUCTION_HOST}" != "" ]
    then
        echo "Creating new Hosts.plist with host '""${PRODUCTION_HOST}"'"'
        "${PLIST_BUDDY}" -c "Add :${RMS_HOST_KEY} string \"${PRODUCTION_HOST}\"" "${HOSTS_PLIST_PATH}"
    fi
else
    echo "Not a Release build, leaving Hosts.plist in tact."
fi

echo "*** Hosts.plist contents ***"
"${PLIST_BUDDY}" -c Print "${HOSTS_PLIST_PATH}"

# CocoaPods processing places a copy of this script in the resource folder. Remove it.
/bin/rm -f "${RESOURCE_PATH}"/host_selector_build_phase.sh