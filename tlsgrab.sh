#!/bin/bash

function helpmenu() {
    echo "Help Menu"
    exit 0
}

while getopts "h:c:t:d:" opt; do

    case ${opt} in

        h)
            # usage
            helpmenu
            ;;

        c)
            # threads
            concurrency=$OPTARG
            ;;

        t)
            # timeout
            timeout=$OPTARG
            ;;

        d)
            # domain
            domain=$OPTARG
            ;;

        \?)
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;

        :)
            echo "Invalid Option: -$OPTARG requires an argument." 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# take single or list of cidrs
while read cidr ; do

    if [ -z ${timeout} ] || [ -z ${concurrency} ] ; then
        timeout=2
        concurrency=50
    fi

    # use nmap to scan the list, but do not do DNS resolution (https://stackoverflow.com/questions/16986879/bash-script-to-list-all-ips-in-prefix)
    cidr2ip=$(nmap -sL -n ${cidr} | awk '/Nmap scan report/{print $NF}')

    # for each IP in cidr range, perform tlsgrab using httpx
    for ip in ${cidr2ip} ; do
        if [ ! -z ${domain} ] ; then
            tlsgrab=$(echo ${ip} | httpx -silent -json -tls-grab -timeout ${timeout} -threads ${concurrency} | jq -r .'"tls-grab".dns_names[]' 2>/dev/null | sort -u | grep "[a-zA-Z0-9\-\.\*]*.\.${domain}")

        elif [ -z ${domain} ] ; then
            tlsgrab=$(echo ${ip} | httpx -silent -json -tls-grab -timeout ${timeout} -threads ${concurrency} | jq -r .'"tls-grab".dns_names[]' 2>/dev/null | sort -u)

        fi

        if [[ ${tlsgrab} ]] ; then
            echo ${ip}

            for result in ${tlsgrab} ; do
                echo -e "\t${result}"
            done
        fi
    done
done
