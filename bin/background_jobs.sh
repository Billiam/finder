#!/bin/bash

echo 'starting clockwork'
cd $OPENSHIFT_REPO_DIR
cmd="clockworkd --dir=${OPENSHIFT_REPO_DIR} --pid-dir=${OPENSHIFT_DATA_DIR} --clock=${OPENSHIFT_REPO_DIR}clock.rb --log --log-dir=${OPENSHIFT_RUBY_LOG_DIR}"

echo $cmd
bundle exec "$cmd stop"
bundle exec "$cmd start"