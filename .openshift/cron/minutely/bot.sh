#!/bin/bash
MINUTES=`date +%M`

if [ $(($MINUTES % 5)) == 0 ];then
    (
        cd $OPENSHIFT_REPO_DIR ;
        rake poll_bot
    )
fi
