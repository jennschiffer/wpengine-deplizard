#!/usr/bin/env bash

# Run this script to setup WP Engine Git remotes for your local clone per
# http://wpengine.com/git/ then deploy using one of the following commands.
#
# Push to staging:
#   git push staging master
#   git push staging localbranchname:master
#
# Push to production:
#   git push production master

git remote add production git@git.wpengine.com:production/deplizard.git
git remote add staging git@git.wpengine.com:staging/deplizard.git
