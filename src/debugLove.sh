#!/usr/bin/env bash
echo
if [ "$#" != 1 ]
then
	/usr/bin/love "${@: -1}" -ideadebug
else
	/usr/bin/love $1
fi
