#!/bin/bash

#Usage:
# ./infraScan.sh ip/mask


#Quickly detect open ports in a given IP interval 
masscan -p0-65535 --open $1 --max-rate 100000 -oG nmap.gnmap;


#Extract information from masscan result ro HOST and OPEN_PORTS files
grep Host nmap.gnmap | awk '{print $4,$7}' | sed 's@/.*@@' | sort -t' ' -n -k2 | awk -F' ' -v OFS=' ' '{x=$1;$1="";a[x]=a[x]","$0}END{for(x in a) print x,a[x]}' | sed 's/, /,/g' | sed 's/ ,/ /' | sort -V -k1 | cut -d " " -f2 > OPEN_PORTS;
grep Host nmap.gnmap | awk '{print $4,$6}' | sed 's@/.*@@' | sort -t' ' -n -k2 | awk -F' ' -v OFS=' ' '{x=$1;$1="";a[x]=a[x]","$0}END{for(x in a) print x,a[x]}' | sed 's/, /,/g' | sed 's/ ,/ /' | sort -V -k1 | cut -d " " -f1 > HOSTS;


#Parallel nmap scan for each target
parallel -j 10 --link "sudo nmap -sSV -p {2} -v --open -Pn -n --script vulners.nse -T4 {1} -oN {1}.txt" :::: HOSTS :::: OPEN_PORTS;


#Clean temp files
rm HOSTS OPEN_PORTS;

#Merge output nmap result to unite files
cat *.txt >> nmap_result; rm *.txt;
