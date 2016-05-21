#!/bin/sh
cd
aws s3 cp s3://${TAR_BUCKET}/version .
DEPLOY_DIR=`sed -n '1p' < version`
TARBALL=`sed -n '2p' < version`
PACKAGE=`sed -n '3p' < version`
if [ ! -e install ]; then
    mkdir install
fi
cd install
if [ -e ${DEPLOY_DIR} ]; then
    # already installed this version
    exit 0
fi
mkdir ${DEPLOY_DIR}
cd ${DEPLOY_DIR}
aws s3 cp s3://${TAR_BUCKET}/${TARBALL} .
mkdir node_modules
npm install ${TARBALL}
cd node_modules
cd ${PACKAGE}

# kill existing server before restarting
pkill -f forever/bin/monitor

LOGDIR=/var/log/papertrail
FOREVER=~/node_modules/forever/bin/forever
${FOREVER} start -a -o ${LOGDIR}/out.log -e ${LOGDIR}/err.log -l ${LOGDIR}/forever.log -c "npm start" ./ &
