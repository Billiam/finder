#!/bin/bash

# only run if this appears to be the main gear
if [ -a ${OPENSHIFT_DATA_DIR}main_gear ] ; then
  $OPENSHIFT_REPO_DIR/bin/background_jobs.sh
fi