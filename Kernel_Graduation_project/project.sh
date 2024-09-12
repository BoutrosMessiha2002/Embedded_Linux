#!/bin/bash

# Bash Script to Analyze Network Traffic

#Author: Boutros George Sabri

# Input: Path to the Wireshark pcap file
pcap_file="./captured_packets.pcap"

# Function to extract information from the pcap file
analyze_traffic() {
    # Check if the pcap file exists
    if [[ ! -f "$pcap_file" ]]; then
        echo "PCAP file not found!"
        exit 1
    fi


# I used tshark commands, which I knew from tldr and tshark documentation.
# this command prints number of total packets, by getting the number of the last packet transmitted.

    total_packets=$(tshark -r "$pcap_file" -T fields -e frame.number | tail -n 1)
    
 #the following 4 lines of code, I used tshark and some filters to filter out 4 different protocls(http,https,TCP and DNS) and print their number down.

    http_packets=$(tshark -r $pcap_file -T fields -Y http -e http.request -e http.response | wc -l)
    https_packets=$(tshark -r "$pcap_file" -Y tls -T fields -e tls.record.version | wc -l)
    DNS_packets=$(tshark -r $pcap_file -T fields -Y dns -e dns.qry.name | wc -l)
    TCP_packets=$(tshark -r $pcap_file -T fields -Y tcp -e tcp.srcport | wc -l)


#the following 2 lines of code group both top source ip addresses and top destination ip addresses, I used grep -v '^$' to filter out blank lines,
#because tshark sometimes outputs a number without mentioning which ip was the source or destination, this is why it was necessary to write this grep.

    top_source_ips=$(tshark -r "$pcap_file" -T fields -e ip.src | grep -v '^$' | sort | uniq -c | sort -nr | head -n 5)
    top_dest_ips=$(tshark -r "$pcap_file" -T fields -e ip.dst | grep -v '^$' | sort | uniq -c | sort -nr | head -n 5)

    echo "----- Network Traffic Analysis Report -----"

    #Output the analysis summary
    #Output the number of total packets

    echo "1. Total Packets: $total_packets"
    echo "2. Protocols:"

    #Output http,https,DNS and TCP packets

    echo "   - HTTP: $http_packets packets"
    echo "   - HTTPS/TLS: $https_packets packets"
    echo "   - DNS: $DNS_packets packets"
    echo "   - TCP: $TCP_packets packets"

    #Output top source ips

    echo ""
    echo "3. Top 5 Source IP Addresses:"
    echo "$top_source_ips"

    #Output top destination ips

    echo ""
    echo "4. Top 5 Destination IP Addresses:"
    echo "$top_dest_ips"
    echo ""
    echo "----- End of Report -----"
}

# Run the analysis function
analyze_traffic
