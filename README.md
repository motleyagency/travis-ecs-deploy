# AWS ECS Provisioning scripts for Travis CI

This module contains a set of scripts for automatic building, pushing, and deploying of a Dockerized app to AWS ECS using Travis CI.

## Project setup

The scripts assumes that your  are set up in the following way.

### Environments and Git Branches

Use one git branch per environment you want to deploy, e.g. `production`, `master`. Travis makes the built branch name available through the `$TRAVIS_BRANCH` environment variable, which is used in the scripts.

## ECS Repositories, Clusters, and Services

Create an **ECS Repository** for storing the project's Docker image. Take note of the Repository ARN and Repository URI.

Create one **ECS Task Definition** for each of the environments. The Task Definition should use the image from the created ECS Repository tagged with the branch/environment name.

Create one **ECS Cluster** per environment you want to deploy. The cluster can be shared among several projects, for example if the project consists of a separate frontend and backed. Both projects can use the same clusters, but different services in the clusters. The cluster names are configurable with environment variables (see below).

Create an **ECS Service** in the Cluster for keeping the Task running.

### AWS User

Create an **IAM User** that has permission to use ECR, ECS and logging services. Use the following Permission Policy for granting the user needed access:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecs:List*",
                "ecs:Describe*",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:Submit*",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": [
                "REPOSITORY_ARN"
            ]
        }
    ]
}
```

Replace *REPOSITORY_ARN* with the ARN for the ECR repository/repositories you want to deploy.

Create an **Access Key** for the user and store the `Access key ID` and `Secret access key` in a safe place.

## Configuring the project

The scripts are configured through environment variables that are made available to the Travis build environment.

**NOTE:** Sensitive information such as access keys **should be encrypted** using Travis CLI. See [Defining encrypted variables in .travis.yml](https://docs.travis-ci.com/user/environment-variables/#Defining-encrypted-variables-in-.travis.yml) for instructions.


The following environment variables must be defined and made available to the Travis build process

Name | Description
-----|------------
**IMAGE_NAME** | The name of the Docker image to build, e.g. `some-project`
**DEPLOY_BRANCHES** | Space delimited list of branches to deploy, e.g. `"master production"`
**AWS_REGION** | The region where your ECS services are created, e.g. `eu-central-1`
**AWS_ACCESS_KEY_ID** | The IAM User's Access key ID
**AWS_SECRET_ACCESS_KEY** | The IAM User's Secret access key
**REMOTE_IMAGE_URL** | The ECS Repository image URL (`<id>.dkr.ecr.<region>.amazonaws.com/some-project`)

In addition, a set of the following environment variables must be defined for each branch/environment you want to deploy:

Name | Description
-----|------------
__ECS_CLUSTER_*BRANCH_NAME*__ | The name of the ECS Cluster for the *BRANCH_NAME*, e.g. ECS_CLUSTER_MASTER
__ECS_SERVICE_*BRANCH_NAME*__ | The name of the ECS Service for the *BRANCH_NAME*, e.g. ECS_SERVICE_MASTER

### package.json

Add the following npm/yarn script to your `package.json`

```json
{
    "scripts": {
        "travis-ecs-deploy": "travis-ecs-deploy"
    }
}
```

### .travis.yml

The environment variables are typically defined in the `.travis.yml` file which defines the CI process in Travis. Add the following configuration to the end of your `.travis.yml` file (here shown with encrypted variables, original values as comments):

```yaml
env:
  global:
    - IMAGE_NAME=simple-todo
    - DEPLOY_BRANCHES=master
    - AWS_REGION=eu-central-1
    # AWS_ACCESS_KEY_ID=83460cadb90f034be815
    - secure: "CDvpSjbywrGbrcFx0lwbkjf3..."
    # AWS_SECRET_ACCESS_KEY=73ebce91f95d4939805b-3d1ba967c59d9ba9a7b7701a436ca04d-a0aa972e6642
    - secure: "trVDrcNP+NVBCB0BFwoaDxkH..."
    # REMOTE_IMAGE_URL=648568381338.dkr.ecr.eu-central-1.amazonaws.com/simple-todo
    - secure: "T0303bikzHpHNKIVJekS3yBS..."
    - ECS_CLUSTER_MASTER=simple-todo-master
    - ECS_SERVICE_MASTER=simple-todo

deploy:
  skip_cleanup: true
  provider: script
  script:
    - yarn run travis-ecs-deploy   # or "npm run travis-ecs-deploy"
  on:
    all_branches: true
```


### Example

In this example we'll go through the setup for a typical project called `simple-todo`.

**Git Branches**

The git repository will have two deployable branches, `master` and `production`. Both branches are deployed whenever changes are pushed to the branches.

**ECS Repository**

An ECS Repository `simple-todo` is created. The repository's ARN and URI are

* ARN: `arn:aws:ecr:eu-central-1:648568381338:repository/simple-todo`
* URI: `648568381338.dkr.ecr.eu-central-1.amazonaws.com/simple-todo`

**ECS Task Definition**

Two ECS Task Definitions `simple-todo-master` and `simple-todo-prod` are created. They use the following image identifiers:

* Simple todo master: `648568381338.dkr.ecr.eu-central-1.amazonaws.com/simple-todo:master`
* Simple todo prod: `648568381338.dkr.ecr.eu-central-1.amazonaws.com/simple-todo:production`

**ECS Clusters and Services**

Two ECS Clusters `simple-todo-master` and `simple-todo-prod` are created. Each of them contain one service `simple-todo`, that is configured to run the task definition for the corresponding branch. I.e.:

```
Cluster 'simple-todo-master'
 `- Service 'simple-todo'
    `- Runs Task Definition 'simple-todo-master'

Cluster 'simple-todo-prod'
 `- Service 'simple-todo'
    `- Runs Task Definition 'simple-todo-prod'
```

**IAM User**

An IAM User `simple-todo-travis` is created with the above policy and an Access key is generated:

* Access key ID: `83460cadb90f034be815`
* Secret access key: `73ebce91f95d4939805b-3d1ba967c59d9ba9a7b7701a436ca04d-a0aa972e6642`

