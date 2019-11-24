# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [0.4.6]
- add KMSMasterKeyID rule

## [0.4.5]
- add passthrough Parameters and AWS::S3::Bucket rules

## [0.4.4]
- add AWS::RDS::DBCluster special rules

## [0.4.3]
- add AWS::RDS::DBInstance special rules

## [0.4.2]
- add AWS::CloudFormation::Init to passthrough keys
- pass through keys with period in them

## [0.4.1]
- respect resource_keys special handling with Type string as well as :type symbol

## [0.4.0]
- add AWS::ApiGateway::Authorizer cases

## [0.3.0]
- camelizer.yml: scope camelizing rules more finely with resource_keys rule
- add NotificationTargetARN
- add AWS::Events::Rule RoleArn
- add VpcZoneIdentifier
- add ScalableTarget

## [0.2.0]
- add AWS special key

## [0.1.0]
- Initial release
