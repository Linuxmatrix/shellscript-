#!/bin/bash
if [ `id -u` -ne 0 ]; then
echo -e "\e[You should run this script as root user\e[0m"

 exit 4
fi
Print() {

        case $3 in
                B)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[34m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[34m$2\e[0m"
                        else
                                echo -e "\e[34m$2\e[0m"
                        fi
                        ;;
                G)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[32m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[32m$2\e[0m"
                        else
                                echo -e "\e[32m$2\e[0m"
                        fi
                        ;;
                Y)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[33m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[33m$2\e[0m"
                        else
                                echo -e "\e[33m$2\e[0m"
                        fi
                        ;;
                R)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[31m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[31m$2\e[0m"
                        else
                                                                                                                                                      1,1           Top
         echo -e "$2\e[0m"
                        fi
                        ;;
                esac

}


Print "SL" "=>> Checking existing configuration if any.. " "B"
[ -d /usr/local/qualys ]
dir_stat=$?
if [ $dir_stat -eq 0 ] ; then
[ -d /usr/local/qualys/cloud-agent/bin ] && sh /usr/local/qualys/cloud-agent/bin/qagent_uninstall.sh
        Print "SL" "Present.. " "R"
        Print "NL" "Cleaned UP.. " "G"
else
        Print "SL" "No Present.. " "R"
        Print "NL" "Skipping.. " "G"
fi
Print "SL" "=>> configuring proxy .. " "B"
cat <<EOD >> /etc/environment
ftp_proxy="http://http-proxy.test.com:88/"
http_proxy="http://http-proxy.test.com:88/"
https_proxy="http://http-proxy.test.com:88/"
no_proxy="localhost,127.0.0.1,.test.com"
FTP_PROXY="http://http-proxy.test.com:88/"
HTTP_PROXY="http://http-proxy.test.com:88/"
HTTPS_PROXY="http://http-proxy.test.com:88/"
NO_PROXY="localhost,127.0.0.1,.test.com"
EOD
if [ $? -eq 0 ] ; then
                Print "NL" "Completed.." "G"
else
        Print "NL" "Failed" "R"
        exit 1
exit 1
fi
Print "SL" "=>> Installing qualys-cloud-agent.. " "B"
rpm -Uvh  http://192.168.121.0/script/Qualys/qualys-cloud-agent.x86_64.rpm
if [ $? -eq 0 ] ; then
        Print "NL" "Completed.." "G"
else
        Print "NL" "Failed" "R"
        exit 1
fi
Print "SL" "=>> Registering qualys agent.. " "B"
/usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh CustomerId="9c0e25de-0221-5af6-e040-10ac13043f6a" ActivationId="d36f2a58-8312-4736-9477-aa1cce5ae733"
if [ $? -eq 0 ] ; then
        Print "NL" "qualys agent registration completed successfully.." "G"
else
        Print "NL" "qualys agent registration  Failed" "R"
        exit 1
fi
Print "SL" "=>> Restarting qualys agent.. " "B"
sh /usr/local/qualys/cloud-agent/bin/qagent_restart.sh
                                                        
