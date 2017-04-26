#! /bin/bash

cd "$(dirname "$0")"

export IMAGE_NAME=test
export DEPLOY_BRANCHES="master production"
export AWS_REGION=eu-central-1
export AWS_ACCESS_KEY_ID=123123123123
export AWS_SECRET_ACCESS_KEY=3737373737373737373737373
export REMOTE_IMAGE_URL=123123123123.dkr.ecr.eu-central-1.amazonaws.com/test
export ECS_CLUSTER_MASTER=test-master
export ECS_SERVICE_MASTER=test-master-service
export ECS_CLUSTER_PRODUCTION=test-prod
export ECS_SERVICE_PRODUCTION=test-prod-service

export TRAVIS_JOB_NUMBER=1.1
export TRAVIS_PULL_REQUEST=false
export TRAVIS_BRANCH=master
export DRYRUN=1


../bin/docker_push.sh
