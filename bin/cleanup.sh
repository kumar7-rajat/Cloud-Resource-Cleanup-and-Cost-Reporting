#!/usr/bin/env bash

# This script used to check for unused resources and calculate the estimated cost that can be saved by cleaning them up.

set -euo pipefail

#Sourcing config.env file 
source "../config/config.env"


log () { 
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Verifying the AWS Account"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

if [ "$ALLOWED_ACCOUNT_IDS" == "$ACCOUNT_ID" ]
    then
        log "Account Found: $ACCOUNT_ID"
else
    log "Unauthorized AWS account found"
    exit 1
fi

RUN_ID=$( date +'%Y-%m-%d %H:%M:%S' )
WORKDIR="/tmp/cloudResource/$RUN_ID"

log "Creating Working Directory"
mkdir -p "$WORKDIR"

log "Collecting AWS Regions information"
REGIONS=$( aws ec2 describe-regions --query "Regions[].RegionName" --output text )
log "Regions: $REGIONS"
echo "$REGIONS" > regions.txt

#Creating EC2 working directory
EC2_DIR="$WORKDIR/ec2"
mkdir -p "$EC2_DIR"

log "Starting stopped EC2 instances across regions"

count=1
for region in $REGIONS
    do
        temp_file="$EC2_DIR/tmp.json"
        aws ec2 describe-instances --region $region --filter Name=instance-state-name,Values=stopped --output json > "$temp_file"
        INSTANCE_COUNT=$( jq '[.Reservations[].Instances[] | select(.State.Name=="stopped")] | length' "$temp_file" )
        if [ $INSTANCE_COUNT -gt 0 ]
            then
                log "$count Stopped instance found in $region"
                mv "$temp_file" "$EC2_DIR/stopped-$region.json"
                count=$(( $count+1 ))
            else
                log "No Stopped instance found in $region"
                rm -rf $temp_file
        fi
done

log "Script Exiting..."