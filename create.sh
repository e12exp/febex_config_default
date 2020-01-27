#!/bin/bash
cd $(dirname $0)
echo "Running create.sh to create config/febex.db from text files"
if test "$1" == "--update"
then
    UPDATE="1"
    shift
fi

if test -z "$1"
then
    HOSTNAME=$(echo $HOSTNAME | tr A-Z a-z | sed s/[.].*// )
    shift
else
    HOSTNAME=$1
fi

git branch | grep $HOSTNAME || git checkout -b $HOSTNAME
git checkout $HOSTNAME 2>&1 | grep -v already
DB=febex.db

rm -f *.out
../setpar --empty $DB batchfile febex.h || exit $?

for i in list slist tlist
do
    ../setpar $DB $i > $i.out
done
CONFIG=$(../setpar febex.db file list | grep -oE "([0-9]+,? *){4}")

if test -z "$1"
then
    HOSTNAME=$(echo $HOSTNAME | tr A-Z a-z | sed s/[.].*// )
else
    HOSTNAME=$1
fi
git add *.h

OLDCOMMIT=$(cat ../febex.db.commit)
if ! diff febex.db ../febex.db  &>/dev/null
then
	echo "*******************************************************************"
    if test -n "$UPDATE" || ! test -f ../febex.db
    then
	if test -f ../febex.db
	then
	    echo "Warning, replacing febex.db with a newly created version"
	else
	    echo "Creating mbs/febex.db, which did not exist."
	fi
	cp -v febex.db ..
	COPIED="1"
	STAT="UPDATED mbs/febex.db. (replacing $OLDCOMMIT)"
    else
	echo "Warning, the newly created mbs/config/febex.db is different from"
	echo " mbs/febex.db with the following creation date:"
	ls --full-time ../febex.db
	echo "Please consider updating to the the version."
	echo STAT="KEPT OLD mbs/febex.db ($OLDCOMMIT)"
    fi
	echo "*******************************************************************"
else
    echo "mbs/febex.db is up to date with text files."
    STAT="No functional changes from $OLDCOMMIT"
fi

MSG="create.sh: created $DB on $HOSTNAME with modules=[$CONFIG]. $STAT"
echo "Commiting with $MSG"
test -n "$COPIED" && EMPTYOK="--allow-empty"
git commit $EMPTYOK -m "$MSG"
git show  | grep ^commit > febex.db.commit
test -n "$COPIED" && cp febex.db.commit ..

