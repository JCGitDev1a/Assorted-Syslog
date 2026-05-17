#!/bin/bash
#
# This script searches Cisco Ironport Email Security Appliance (ESA)
# It looks for a specific sender for today and gets the delivery status.
# Output is in the form of:
#  sender,recipient,subject,date_time,delivery_status
# This can be useful for getting the status of all messages a sender sent today, most commonly for bulk mail delivery or compromised mailboxes.
# It is most useful if the sender is one of your own domains.
# example usage is:
# ./parse-ip-GetDeliveryStatusForSender.sh ./ironport/mail.log > /tmp/bob-20260101.txt
#
# John Cole - 2025

LOGFILE="$1"

if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
  echo "Usage: $0 mail.log"
  exit 1
fi

SENDER_FILTER="user@domain.com"

awk -v sender_filter="$SENDER_FILTER" '
BEGIN {
    OFS=","
    print "sender,recipient,subject,date_time,delivery_status"
}

{
    timestamp = substr($0, 1, 15)

    if (match($0, /MID ([0-9]+)/, m)) {
        mid = m[1]
    } else {
        next
    }

    if ($0 ~ /From: </) {
        match($0, /From: <([^>]+)>/, f)
        sender[mid] = f[1]
        time[mid] = timestamp
    }

    if ($0 ~ /To: </) {
        match($0, /To: <([^>]+)>/, t)
        recipients[mid, t[1]] = 1
    }

    if ($0 ~ /Subject /) {
        match($0, /Subject '\''([^'\'']+)'\''/, s)
        subject[mid] = s[1]
    }

    if ($0 ~ /Response /) {
        match($0, /Response '\''([^'\'']+)'\''/, r)
        delivery[mid] = r[1]
    }
}

END {
    for (key in recipients) {
        split(key, parts, SUBSEP)
        mid = parts[1]
        rcpt = parts[2]

        # Only print if:
        # 1) Sender matches
        # 2) Subject exists and not empty
        # 3) Delivery status exists and not empty
        if (sender[mid] == sender_filter &&
            subject[mid] != "" &&
            delivery[mid] != "") {

            print sender[mid],
                  rcpt,
                  subject[mid],
                  time[mid],
                  delivery[mid]
        }
    }
}
' "$LOGFILE" | sort -u
