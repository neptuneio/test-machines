#! /bin/bash

sleep 600
# Trigger webhook rule on staging
curl -X POST "https://neptune-staging-env.herokuapp.com/api/v1/trigger/channel/webhook/3052843476f74f5db8f50d6708528d88/d816d2ca-9480-4043-b8c5-465d28baed66"
