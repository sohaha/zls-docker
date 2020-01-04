#!/bin/sh

DESTTAR='http://resources.swoole-cloud.com/getClient/trial/2.8.3'
MD5HASH='7e7f83b4684a447bbac22bf4b1b10bf4'
SHA1HASH='7ccd82fea10c1d18e05004f04a1473562c777a97'
FILESIZE='10446650'
MAGICSTRING='OTgxMA=='

tmpprefix=.
tmpdest=${tmpprefix}/swoole-tracker
tmpfile=${tmpdest}.tar.gz

fetchtar()
{
    if type wget 2>&1 >/dev/null
    then
        wget $DESTTAR -O ${tmpfile}
    elif type curl 2>&1 >/dev/null
    then
        curl $DESTTAR -o ${tmpfile}
    else
        printf "No supported downloader (wget or curl) found.\n"
        printf "Please install one of them, or manually download\n"
        printf "\n\t${DESTTAR}\n\n"
        printf "as ${tmpfile}"
        exit 22
    fi
}

checktar()
{
    if type stat 2>&1 >/dev/null
    then
        [ x`stat ${tmpfile} -c "%s"` = x$FILESIZE ] || return 1
    fi
    if type sha1sum 2>&1 >/dev/null
    then
        printf "${SHA1HASH}  ${tmpfile}\n" | sha1sum -c - && return 0 || return 1
    elif type md5sum 2>&1 >/dev/null
    then
        printf "${MD5HASH}  ${tmpfile}\n" | md5sum -c - && return 0 || return 1
    else
        printf "Neither sha1sum nor md5sum found,\n"
        printf "downloaded file cannot be verified.\n"
        return 0
    fi
}

extracttar()
{
    mkdir -p ${tmpdest}
    tar -xvf ${tmpfile} -C ${tmpdest}
}

if [ -f ${tmpfile} ]
then
    checktar || rm ${tmpfile}
fi
if [ ! -f ${tmpfile} ]
then
    fetchtar
    checktar ||
    {
        rm ${tmpfile}
        printf "Verification failed, please download again swoole-tracker-install.sh\n"
        exit 22
    }
fi

extracttar
cd ${tmpdest}
echo $MAGICSTRING > ./app_deps/node-agent/magicstring
exec ./deploy_env.sh

