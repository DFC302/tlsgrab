#!/bin/bash

# set timeout in seconds for httpx requests
timeout=2
# set thread count
threads=50

# take single or list of cidrs
while read cidr ; do
    # use nmap to scan the list, but do not do DNS resolution (https://stackoverflow.com/questions/16986879/bash-script-to-list-all-ips-in-prefix)
    cidr2ip=$(nmap -sL -n ${cidr} | awk '/Nmap scan report/{print $NF}')

    # for each IP in cidr range, perform tlsgrab using httpx
    for ip in ${cidr2ip} ; do
        tlsgrab=$(echo ${ip} | httpx -silent -json -tls-grab -timeout ${timeout} -threads ${threads} | jq -r .'"tls-grab".dns_names[]' 2>/dev/null | sort -u)

        # if tlsgrab variable has output, return the IP address associated with the tlsgrab results
        if [[ ${tlsgrab} ]] ; then
            echo ${ip}
            for result in ${tlsgrab} ; do
                echo -e "\t${result}"
            done
            
            # add a space between each request
            echo ""
        fi
    done
done
