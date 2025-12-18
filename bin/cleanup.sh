#!/bin/env bash

# This script used to check for unused resources and calculate the estimated cost that can be saved by cleaning them up.

set -eou pipefail

#Sourcing config.env file 
source ../config/config.env


log () { 
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Verifying the AWS Account"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

if [ "$ALLOWED_ACCOUNT_IDS"== "$ACCOUNT_ID"]
    then
        log "Account Found: $ACCOUNT_ID"
else
    log "Unauthorized AWS account found"
    exit 1

RUN_ID = $(date +'%Y-%m-%d %H:%M:%S')
WORDKDIR = "/tmp/cloudResource/$RUNID"

log "Creating Working Directory"
mkdir -p "$WORDKDIR"

log "Collecting AWS Regions information"
$REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
log "Regions: $REGIONS"
echo "$REGIONS" > regions.txt

#Creating EC2 working directory
EC2_DIR="$WORDKDIR/ec2"
mkdir -p $EC2_DIR

log "Starting stopped EC2 instances across regions"

for region in $REGIONS
    do
        aws ec2 describe-instances --region $region --filter Name=instance-state-name,Values=stopped --output json > $EC2_DIR/stopped-instance-$region || {
            log " WARNING: Failed to scan region: $region"
            continue
        }
    done
