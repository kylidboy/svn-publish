#!/usr/bin/env bash

executepath=$(cd "$(dirname $0)";pwd)

opts="H:u:p:t:d:S:n:r:"

host=
user=
password=
dest=
temp=
svnpath=
svninfo=
revision=
clean_script=

while getopts $opts arg
do
    case $arg in
        H)
            host=$OPTARG
            ;;
        u)
            user=$OPTARG
            ;;
        p)
            password=$OPTARG
            ;;
        t)
            temp=$OPTARG
            ;;
        d)
            dest=$OPTARG
            ;;
        r)
            revision=$OPTARG
            ;;
        n)
            clean_script=$OPTARG
            ;;
        ?)
        printf "Usage: %s [-H host] [-u user] [-p password] [-t temp dir] [-d destination dir] [-r svn reversion] [-n cleanup script] svnpath\n" $(basename $0) >&2
        exit 2
        ;;
    esac
done

_=${host?"host is required"}
_=${user?"user is required"}
_=${password?"password is required"}
_=${dest?"dest is required"}
_=${temp:="/tmp/"}

if [[ ! -z "${revision}" ]];then
    revision="-r ${revision}"
fi

# temp=${temp/\/$/''}
# dest=${dest/\/$/''}
# echo $temp
# echo $dest
# exit

shift $((OPTIND-1))

svnpath=${1?"point to a svn project root path"}

cd $svnpath
if [[ $? -ne 0 ]];then
    echo "svn path doesn't exists"
    exit 1
fi

echo -n "Changing to working directory: "
pwd

svninfo=$(svn info)

if [[ $? -ne 0 ]];then
    echo "This is not a svn repo"
    exit 1
fi

projectname=$(basename $(pwd))

if [[ ! -d "$temp" ]]; then
    echo "temp directory doesn't exists or it is a file"
    exit1
fi

svn export ${revision} ./ ${temp}/${projectname}
echo "$svninfo" > ${temp}/${projectname}/revision.info

tar -czf ${temp}/${projectname}.tar.gz -C ${temp}/ ${projectname}
rm -rf ${temp}/${projectname}


${executepath}/expectpublish $host $user $password ${temp}/${projectname}.tar.gz ${dest}/${projectname}.tar.gz ${clean_script}

rm -f ${temp}/${projectname}.tar.gz

echo "DONE! Bye Bye..."
