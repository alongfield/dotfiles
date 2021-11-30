#!/usr/bin/env bash

DOMAINS="search"
for x in `/mnt/c/Windows/System32/ipconfig.exe | grep 'DNS Suffix' | cut -f2 -d: | sed '/^\s*$/d' | sed 's/ //g'` ; do
    # Strip the "\r" from the Windows output
    STRIPPED="${x%%[[:cntrl:]]}"
    DOMAINS="$DOMAINS $STRIPPED"
done

# If there was a DNS domain specified, add it.
cat /etc/resolv.conf | grep -v '^search ' > /tmp/resolv-conf-build
if [[ ! $DOMAINS == 'search' ]] ; then
    echo $DOMAINS >> /tmp/resolv-conf-build
    mv /tmp/resolv-conf-build /etc/resolv.conf
fi
