#! /bin/bash

# Work out of /tmp directory
cd /tmp

# Start an infinite while loop
while true;
do

  # Start of while loop

  # Run one of 10 load types during a cycle
  load_type=$((RANDOM%10))

  case "$load_type" in
    1) curl "http://localhost:3000/error"
      ;;
    2) curl "http://localhost:3000/5000"
      ;;
    *) curl "http://localhost:3000"
      ;;
  esac

  # Sleep for 10 seconds 
  sleep 10

  # end of while loop
done

