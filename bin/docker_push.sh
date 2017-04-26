#! /bin/bash

# import util functions
source "../lib/util.sh"

export PATH=$PATH:$HOME/.local/bin

echo "Logging into ECR..." &&
runCommand "eval $("aws ecr get-login --region $AWS_REGION")" &&
echo "Building Docker image..."
runCommand "docker build -t $IMAGE_NAME ." &&
echo "Pushing image $IMAGE_NAME:$TRAVIS_BRANCH" &&
runCommand "docker tag $IMAGE_NAME:latest $REMOTE_IMAGE_URL:$TRAVIS_BRANCH" &&
runCommand "docker push $REMOTE_IMAGE_URL:$TRAVIS_BRANCH" &&
echo "Successfully built and pushed $REMOTE_IMAGE_URL:$TRAVIS_BRANCH"
