# CHANGELOG

## Version 3.0.0

### Changed

* __(POSSIBLY) BREAKING CHANGE__: Add --no-include-email to ECR login. The -e flag was deprecated a while ago, which made the
deploys fail after AWS/ECS updated their docker instances. (#1)

## Version 2.0.0

### Changed

* __BREAKING CHANGE__: Renamed bin script from `ecs-deploy` to `travis-ecs-deploy` to conform with the new project name

## Version 1.0.0

* First stable version
