#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

echo "Creating Docs for the LGV_MeetingSDK Package\n"
rm -drf docs/*

jazzy  --readme ./README.md \
       --github_url https://github.com/LittleGreenViper/LGV_MeetingSDK \
       --title "LGV_MeetingSDK Doumentation" \
       --min_acl private \
       --theme fullwidth
cp ./icon.png docs/
cp ./img/* docs/img
