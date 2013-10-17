#!/bin/sh

#  host_selector_build_phase.sh
#
#  Created by Tony Ingraldi on 10/14/13.
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