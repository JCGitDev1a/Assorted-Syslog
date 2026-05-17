# Cisco IronPort Scripts

Collection of Bash scripts for analyzing Cisco ESA/IronPort Syslog data.

## Included Scripts

| Script | Purpose |
|---|---|
| Find60DaySenders.sh | Gets all unique senders for a specific domain over the past 60 days via the ESA |
| parse-ip-GetDeliveryStatusForSender.sh | Gets deivery status for a specific sender from a particular ESA log file |

## Environment

Designed for:
- Linux
- Cisco ESA/IronPort
- Syslog-based logging

## Example Usage

```bash
./Find60DaySenders.sh -d example.com -l ./ironport -t 30 -o example-20260517.txt
./parse-ip-GetDeliveryStatusForSender.sh ./ironport/mail.log > /tmp/bob-20260101.txt
```

## Development Process

This project was developed using an iterative AI-assisted workflow.

The original queries were created by reviewing syslog entries and determining the information that
was needed to be captured.  After I created the initial queries, I used AI tooling to accelerate
scripting of the queries into a reusable package.  Testing was then performed to verify the results.
This AI integration greatly increased efficiency of the support team.
