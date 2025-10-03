#!/bin/bash
# Variables - Begin
DISTRO_ID=""
DISTRO_RELEASE=""
DISTRO_DESC=""
# Variables - End

# Functions - Begin
unknown_os() {
    echo "Unfortunately, your operating system distribution and version are not supported by this script."
}

identify_distribution() {
    # Debian Based
    DISTRO_ID_UBUNTU=Ubuntu
    DISTRO_ID_KYLIN=UbuntuKylin
    DISTRO_ID_ZORIN=Zorin
    DISTRO_ID_RASPBIAN=Raspbian

    # Mac
    DISTRO_ID_DARWIN="Mac OSX (Darwin)"

    # Red Hat Based
    DISTRO_ID_CENTOS=CentOS
    DISTRO_ID_CENTOS=AlmaLinux
    DISTRO_ID_FEDORA=Fedora
    DISTRO_ID_RHEL_CLIENT=RedHatEnterpriseClient
    DISTRO_ID_RHEL_SERVER=RedHatEnterpriseServer
    DISTRO_ID_RHEL_WORKSTATION=RedHatEnterpriseWorkstation

    # Other
    DISTRO_ID_NEOKYLIN=" NeoKylin Linux Desktop"
    DISTRO_ID_SUSE="SUSE LINUX"
    DISTRO_ID_AWS="AWS"

    type lsb_release >/dev/null 2>&1
    if [ "$?" = "0" ]; then
        DISTRO_ID="$(lsb_release -is)"
        DISTRO_RELEASE="$(lsb_release -rs)"
        DISTRO_DESC="$(lsb_release -ds)"
    # OS Check - Debian - Begin
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_ID=$DISTRIB_ID
        DISTRO_DESC=$DISTRIB_DESCRIPTION
        DISTRO_RELEASE=$DISTRIB_RELEASE

    elif [ -f /etc/lsb-release ] && [ -z DISTRO_ID]; then
        DISTRO_ID=$(cat /etc/lsb-release | grep '^DISTRIB_ID' | cut -d '=' -f2)
        DISTRO_DESC=$(cat /etc/lsb-release | grep '^DISTRIB_DESCRIPTION' | cut -d '=' -f2)
        # DISTRO_RELEASE=$(cat /etc/lsb-release | grep '^DISTRO_RELEASE' | cut -d '=' -f2)
        DISTRO_RELEASE=$(cat /etc/lsb-release | grep -E '(^DISTRO_RELEASE|^DISTRIB_CODENAME)' | cut -d '=' -f2)
    # OS Check - Debian - End

    # OS Check - CentOS - Begin
    elif [ -f /etc/centos-release ]; then
        DISTRO_ID=$DISTRO_ID_CENTOS
        DISTRO_DESC="$(cat /etc/centos-release)"
        DISTRO_RELEASE="$(echo $DISTRO_DESC | awk '{ for (i=1; i < NF; i++) { if ($i == "release") { print $(i+1); break }}}')"
    # OS Check - CentOS - End

    # OS Check - Fedora - Begin
    elif [ -f /etc/fedora-release ]; then
        DISTRO_ID=$DISTRO_ID_FEDORA
        DISTRO_DESC="$(cat /etc/fedora-release)"
        DISTRO_RELEASE="$(echo $DISTRO_DESC | awk '{ for (i=1; i < NF; i++) { if ($i == "release") { print $(i+1); break }}}')"
    # OS Check - Fedora - End
    #elif [ -f /etc/issue ]; then
    #if [ grep -q Amazon /etc/issue ]; then
    #aws=`grep -q Amazon /etc/issue`
    #if [ "$?" = "0" ]; then
    #DISTRO_ID=$DISTRO_ID_AWS
    #DISTRO_DESC="6"
    #fi
    #fi
    # OS Check - Mac OSX - Begin
    elif [ $(uname -s) = "Darwin" ]; then
        DISTRO_ID=$DISTRO_ID_DARWIN

        # Get operating system name and version - Start
        OSvers1=$(sw_vers -productVersion | cut -d. -f1)
        OSvers2=$(sw_vers -productVersion | cut -d. -f2)
        OSvers3=$(sw_vers -productVersion | cut -d. -f3)
        OSvers="$OSvers1.$OSvers2"
        #echo $OSvers

        case "$OSvers" in
        "10.8" | "10.8.0" | "10.8.1" | "10.8.2" | "10.8.3" | "10.8.4" | "10.8.5")
            OSName="Mountain Lion"
            OSMajor=10
            ;;
        "10.9" | "10.9.0" | "10.9.1" | "10.9.2" | "10.9.3" | "10.9.4" | "10.9.5")
            OSName="Mavericks"
            OSMajor=10
            ;;
        "10.10" | "10.10.0" | "10.10.1" | "10.10.2" | "10.10.3" | "10.10.4" | "10.10.5")
            OSName="Yosemite"
            OSMajor=10
            ;;
        "10.11" | "10.11.0" | "10.11.1" | "10.11.2" | "10.11.3" | "10.11.4" | "10.11.5" | "10.11.6")
            OSName="El Capitan"
            OSMajor=10
            ;;
        "10.12" | "10.12.0" | "10.12.1" | "10.12.2" | "10.12.3" | "10.12.4" | "10.12.5" | "10.12.6")
            OSName="Sierra"
            OSMajor=10
            ;;
        "10.13" | "10.13.0" | "10.13.1" | "10.13.2" | "10.13.3" | "10.13.4" | "10.13.5" | "10.13.6")
            OSName="High Sierra"
            OSMajor=10
            ;;
        "10.14" | "10.14.0" | "10.14.1" | "10.14.2" | "10.14.3" | "10.14.4" | "10.14.5" | "10.14.6")
            OSName="Mojave"
            OSMajor=10
            ;;
        "10.15" | "10.15.0" | "10.15.1" | "10.15.2" | "10.15.3" | "10.15.4" | "10.15.5" | "10.15.6" | "10.15.7")
            OSName="Catalina"
            OSMajor=10
            ;;
        "10.16.0" | "11.0" | "11.0.0" | "11.0.1" | "11.1" | "11.2" | "11.2.1" | "11.2.2" | "11.2.3" | "11.3" | "11.3.1" | "11.4" | "11.5" | "11.5.1" | "11.5.2" | "11.6" | "11.6.1")
            OSName="Big Sur"
            OSMajor=11
            ;;
        "12.0" | "12.0.1" | "12.1" | "12.2" | "12.2.1" | "12.3" | "12.4" | "12.5" | "12.5.1" | "12.6" | "12.6.1" | "12.6.2" | "12.6.3" | "12.6.4")
            OSName="Monterey"
            OSMajor=12
            ;;
        "13.0" | "13.0.1" | "13.1" | "13.2" | "13.2.1")
            OSName="Ventura"
            OSMajor=13
            ;;
        default)
            OSName="Unknown"
            ;;
        esac

        #echo $OSName

        # Get operating system name and version - Stop
        OSVers=$OSvers1
        if [ ! -z $OSvers2 ]; then
            OSVers="$OSVers.$OSvers2"
        fi
        if [ ! -z $OSvers3 ]; then
            OSVers="$OSVers.$OSvers3"
        fi
        if [ $OSMajor -le 10 ]; then
            DISTRO_DESC="Mac OS X - $OSName $OSVers"
        else
            DISTRO_DESC="macOS - $OSName $OSVers"
        fi
        DISTRO_RELEASE="$OSVers"
    # OS Check - Mac OSX - End

    # OS Check - Red Hat - Begin
    elif [ -f /etc/redhat-release ]; then
        DISTRO_DESC="$(cat /etc/redhat-release)"
        DISTRO_ID=
        echo $DISTRO_DESC | grep "Client" >/dev/null 2>&1 && DISTRO_ID=$DISTRO_ID_RHEL_CLIENT
        [ -z "$DISTRO_ID" ] && echo $DISTRO_DESC | grep "Server" >/dev/null 2>&1 && DISTRO_ID=$DISTRO_ID_RHEL_SERVER
        [ -z "$DISTRO_ID" ] && echo $DISTRO_DESC | grep "Workstation" >/dev/null 2>&1 && DISTRO_ID=$DISTRO_ID_RHEL_WORKSTATION
        [ -z "$DISTRO_ID" ] && echo $DISTRO_DESC >/dev/null 2>&1 && DISTRO_ID=$DISTRO_ID_RHEL_SERVER
        DISTRO_RELEASE="$(echo $DISTRO_DESC | awk '{ for (i=1; i < NF; i++) { if ($i == "release") { print $(i+1); break }}}')"
        # echo $DISTRO_ID
        # OS Check - Red Hat - End
    else
        unknown_os
        exit
    fi

    SUB='Zorin OS 15'
    if [[ "$DISTRO_DESC" =~ .*"$SUB".* ]]; then
        DISTRO_DESC=$(echo "$DISTRO_DESC (Ubuntu 18.04 LTS)")
    fi

    #
    # Differentiate between Ubuntu and Ubuntu Kylin.
    #

    if [ "$DISTRO_ID" = "$DISTRO_ID_UBUNTU" ]; then
        #
        # Distinguish between Ubuntu and Ubuntu Kylin where possible.   Release
        # files are common place and the following file exists on
        # Ubuntu Kylin 14.04 LTS, but not on Ubuntu Kylin 13.04.   Your mileage
        # may vary...
        if [ -f /etc/ubuntukylin-release ]; then
            DISTRO_ID=$DISTRO_ID_KYLIN
        fi
    fi

    if [ "$DISTRO_ID" = "SUSE" ]; then
        #
        # Add the distribution ID "SUSE" to the DISTRO_ID_SUSE
        #
        DISTRO_ID=$DISTRO_ID_SUSE
    fi

    #
    # Check supported distributions
    #
    case "$DISTRO_ID" in
    ${DISTRO_ID_CENTOS} | ${DISTRO_ID_FEDORA} | ${DISTRO_ID_RHEL_CLIENT} | ${DISTRO_ID_RHEL_SERVER} | ${DISTRO_ID_RHEL_WORKSTATION} | ${DISTRO_ID_SUSE} | ${DISTRO_ID_NEOKYLIN}) ;;

    ${DISTRO_ID_KYLIN} | ${DISTRO_ID_UBUNTU} | ${DISTRO_ID_ZORIN} | ${DISTRO_ID_RASPBIAN})
        #echo $DISTRO_DESC | grep " LTS$" >/dev/null 2>&1
        #if [ "$?" != "0" ]; then
        #echo "$DISTRO_DESC not an LTS release"
        #exit
        #fi
        ;;
    ${DISTRO_ID_DARWIN}) ;;

    *)
        echo -e "$DISTRO_ID\n$DISTRO_DESC not supported"
        exit
        ;;
    esac

    case "$1" in
    -a)
        echo "$DISTRO_ID"
        echo "$DISTRO_RELEASE"
        echo "$DISTRO_DESC"
        ;;
    -d)
        echo "$DISTRO_DESC"
        ;;
    -r)
        echo "$DISTRO_RELEASE"
        ;;
    -i)
        echo "$DISTRO_ID"
        ;;
    *)
        echo "What details would you like to see?"
        echo " -a is for all details."
        echo " -d is for full OS name with version."
        echo " -r is for the release version of the OS"
        echo -e " -i is for the name of the distribution\n"
        echo "Type your option (a, d, r, or i), followed by [ENTER]:"
        read uiOption

        case "$uiOption" in
        a)
            echo "$DISTRO_ID"
            echo "$DISTRO_RELEASE"
            echo "$DISTRO_DESC"
            ;;
        d)
            echo "$DISTRO_DESC"
            ;;
        r)
            echo "$DISTRO_RELEASE"
            ;;
        i)
            echo "$DISTRO_ID"
            ;;
        *)
            echo "$DISTRO_ID"
            ;;
        esac
        ;;
    esac
}
# Functions - End

identify_distribution $1
#echo $DISTRO_ID
