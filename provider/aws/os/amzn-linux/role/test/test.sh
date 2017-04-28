#!/usr/bin/env bash
#
# Amazon 'user-data' script for building a www.thig.com server in AWS.

# Global variables
LOG_FILE=/var/log/thig-user-data-output.log
LOG_DATE=$(date +"%Y-%m-%d - %T")

# Function generates the current timestamp in order to log the current time
# based on the date command when executed.
#
# Argumments: None
# Returns: String (date)
log_timestamp () {
  date +"%Y-%m-%d - %T"
}

(
echo "## $(log_timestamp): BEGINNING AWS CLOUD DEPLOYMENT ##"

#==============================================================================#
# Amazonlinux Security Updates/Patches:                                        #
#   First things first...we need to check if there have been any security      #
#   errata patches released since our AMI was created and install them if so.  #
#==============================================================================#
echo "$(log_timestamp): Updating any packages currently with security errata..."
yum repolist
sleep 30
yum --security update -y -q
echo "$(log_timestamp): ...done"

#==============================================================================#
# EPEL yum repo:                                                               #
#   Enabling the EPEL (Extra Packages for Enterprise Linux) yum repo for       #
#   installing some packages not in the main/latest Amazonlinux repo.          #
#==============================================================================#
echo "$(log_timestamp): Enabling the EPEL repo for Amazonlinux..."
yum-config-manager --enable epel
echo "$(log_timestamp): ...done"

#==============================================================================#
# TimeZone configuration:                                                      #
#   The default timezone configured for Amazonlinux in AWS is "UTC" and not a  #
#   zone that's related to an actual geolocation. We need to change that       #
#   configuration and do so with the following script block. This change       #
#   requires us to make 2 seperate changes in order to take effect.            #
#==============================================================================#
echo "$(log_timestamp): Updating the server's configured TimeZone..."
# Update the clock files 'ZONE' value
clock_file="/etc/sysconfig/clock"
sed -i '/ZONE/c\ZONE=\"America\/New_York\"' ${clock_file}
# Replace amznlinux default localtime file with a symlink to America/New_York
localtime_file="/etc/localtime"
ln -sf /usr/share/zoneinfo/America/New_York ${localtime_file}
echo "$(log_timestamp): ...done"

#==============================================================================#
# Hostname configuration:                                                      #
#   We need to set our hostname because subsequent configuration scripts will  #
#   need to know what role the server has and that, among other things, is     #
#   derived from specific sections of the hostname itself.                     #
#==============================================================================#
echo "$(log_timestamp): Updating server's hostname..."
sed -i '/HOSTNAME/c\HOSTNAME=aws-www-test-01.aws.thig.com' /etc/sysconfig/network
sed -i '/^127.0.0.1/s/$/ aws-www-test-01 aws-www-test-01.aws.thig.com/' /etc/hosts
echo "$(log_timestamp): ...done"

) &> ${LOG_FILE}
