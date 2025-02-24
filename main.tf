#############################
# Data: Availability Zones  #
#############################

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
