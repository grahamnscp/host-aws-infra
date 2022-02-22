#!/bin/bash

# Read in the parameters
source params.sh


CWD=`pwd`
TMP_FILE=/tmp/generate-hosts.tmp.$$

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac
#echo OS is ${MACHINE}


# ---------------------------------------
# Collect output variables from terraform
# ---------------------------------------
echo ">>> Collecting variables from terraform output.."

cd tf
terraform output > $TMP_FILE
cd $CWD

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g' |sed 's/\"//g' |sed 's/,*$//g'`
  #echo ENTRY: $var_name = $var_value

  case $var_name in
    "route53_domain")
      BASEDOMAIN=$var_value
      ;;

    "route53_subdomain")
      SUBDOMAIN=$var_value
      ;;

    "route53-infra")
      INFRA_PUBLIC_HOSTNAME=$var_value
      ;;

    "infra-instance-public-ip")
      INFRA_IP=$var_value
      ;;

    "region")
      AWS_REGION=$var_value
      ;;
  esac
done


# Variables
DOMAIN=${SUBDOMAIN}.${BASEDOMAIN}

# ---------------------------------
# Generate hosts file from template
# ---------------------------------
echo ">>> Generating hosts file from hosts.template.."

cp templates/hosts.template ansible/hosts
sed -i $SEDBAK "s/##BASEDOMAIN##/$BASEDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##SUBDOMAIN##/$SUBDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##INFRA_IP##/$INFRA_IP/" ansible/hosts
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##DOCKERHUB_USER##/$DOCKERHUB_USER/" ansible/hosts
sed -i $SEDBAK "s/##CENTOS_PASSWORD##/$CENTOS_PASSWORD/" ansible/hosts
sed -i $SEDBAK "s/##NTP_PRIVATE_SUBNET##/$NTP_PRIVATE_SUBNET/" ansible/hosts
sed -i $SEDBAK "s/##KUBERNETES_PACKAGE_VERSION##/$KUBERNETES_PACKAGE_VERSION/" ansible/hosts
echo "" >> ansible/hosts


# --------
# All done
# --------
echo ">>> done."
/bin/rm $TMP_FILE
rm ansible/hosts.bak

exit 0

