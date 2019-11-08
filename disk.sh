for host in `ls /sys/class/scsi_host/`;do echo "- - -" >/sys/class/scsi_host/${host}/scan; done

fdisk -l 2>/dev/null | egrep '^Disk' | egrep -v 'dm-|type|identifier'|awk -F "[= ]" '{print " "$2}'|xargs |awk -F "[= ]" '{print " "$NF}' > result
sed -i 's/\:/ /g' result
disk=$(cat result|tr -d '[:space:]')
echo -e "n\np\n1\n\n\nw" | sudo fdisk "${disk}"
