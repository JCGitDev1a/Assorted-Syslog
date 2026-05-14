#!/bin/bash
#
# This script is used when you have one ore more Cisco Ironport Email Security Appliances (physical or virtual) also known as Cisco Ironport ESA
# The ESA must send mail logs to a remote syslog server or you have downloaded or saved the logs from the ESA.
# In Syslog, it is suggested to have a directory just for the ESA traffic.
# In Syslog, it is assumed you have stored X number of days of logs using logrotate in uncompressed format before deleting/compressing/etc.
# For example /var/log/ironport/esa-001.log-20230101    /var/log/ironport/esa-001.log-20230102   /var/log/ironport/esa-001.log
# This can be used for outbound or inbound mail flow queries.
# The script looks in syslog for all unique senders from a given domain for a given timeframe.
# It should filter most SRS (Sender Rewrite Scheme) type senders.
# Note: If you need to include SRS addresses for a particular purpose, just comment out that one line.
# John Cole - 2023

# Default values
BASELOGDIR="/var/log/mail"
MTIME=60
DATETIME=$(date +"%Y%m%d%H%M")

# Usage function
usage() {
    echo "Usage: $0 -d <domain> [-l <logdir>] [-t <days>] [-o <outputfile>]"
    echo
    echo "Options:"
    echo "  -d DOMAIN      Domain to search for (required)"
    echo "  -l LOGDIR      Base log directory (default: /var/log/mail)"
    echo "  -t DAYS        Search files modified within DAYS (default: 60)"
    echo "  -o OUTPUT      Output filename (default: domain.com-YYYYMMDDhhmm.txt)"
    echo
    echo "Example:"
    echo "  $0 -d example.com"
    echo "  $0 -d example.com -t 30"
    echo "  $0 -d example.com -l /logs/mail -o results.txt"
    exit 1
}

# Parse options
while getopts "d:l:t:o:h" opt; do
    case ${opt} in
        d )
            DOMAIN="$OPTARG"
            ;;
        l )
            BASELOGDIR="$OPTARG"
            ;;
        t )
            MTIME="$OPTARG"
            ;;
        o )
            OUTPUT="$OPTARG"
            ;;
        h )
            usage
            ;;
        \? )
            usage
            ;;
    esac
done

# Validate required domain argument
if [ -z "$DOMAIN" ]; then
    echo "Error: Domain is required."
    usage
fi

# Set default output filename if not provided
if [ -z "$OUTPUT" ]; then
    OUTPUT="${DOMAIN}-${DATETIME}.txt"
fi

# Run the search pipeline
find "$BASELOGDIR" -type f -mtime -"${MTIME}" -print0 | \
xargs -0 grep "$DOMAIN" | \
grep "ICID" | \
grep "From" | \
grep -v "\+SRS=" | \
awk '{ print $12 }' | \
sort | \
uniq | \
tr -d '<' | \
tr -d '>' > "$OUTPUT"

echo "Results written to $OUTPUT"
