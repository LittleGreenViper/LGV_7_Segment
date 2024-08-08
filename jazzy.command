#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

echo "Creating Docs for the LGV_7_Segment Library\n"
rm -drf docs/*

jazzy  --readme ./README.md \
       --github_url https://github.com/LittleGreenViper/LGV_7_Segment \
       --title "LGV_7_Segment Doumentation" \
       --min_acl public \
       --theme fullwidth \
       --build-tool-arguments -scheme,"LGV_7_Segment",-target,"LGV_7_Segment"
cp ./icon.png docs/
cp ./img/* docs/img
