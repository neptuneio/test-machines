#! /bin/bash

# Work out of /tmp directory
cd /tmp

# Start an infinite while loop
while true;
do

  # Start of while loop

  # Run one of 4 load types during a cycle
  load_type=$((RANDOM%5))

  # Run load for a duration of random time between 0 and 9minutes
  timeout=7
  # timeout=$((RANDOM%10))

  case "$load_type" in
    1) echo "Running CPU load test"
      stress -q -c 2 -t ${timeout}m &
      ;;
    2) echo "Running Disk util load test"
      fallocate -l 4G temp.file
      ;;
    3) echo "Running DiskIO load test"
      stress -q -d 2 -t ${timeout}m &
      ;;
    *) echo "Running Memory load test"
      stress -q -m 4 --vm-hang 0 -t ${timeout}m &
      ;;
  esac

  # Sleep for timeout
  sleep 1200

  # Remove temp.file if it exists
  if [ -f temp.file ]; then
    rm -rf temp.file
  fi

  # end of while loop
done

