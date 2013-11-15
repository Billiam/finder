#!/bin/bash
MINUTES=`date +%M`

if [ $(($MINUTES % 20)) == 0 ];then
    (
        cd $OPENSHIFT_REPO_DIR ;
        rake geocode
    )
fi
