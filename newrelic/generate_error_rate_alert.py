#!/usr/bin/env python

import datetime
import simplejson as json
import requests

msg = {}
msg['alert_policy_name'] = "Default application alert policy"
msg['created_at'] = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
msg["application_name"] = "newrelicTestApp"
msg["account_name"] = "Neptuneio"
msg["severity"] = "critical"
msg["message"] = "Error rate > 1.0%"
msg["short_description"] = "New alert for Default application alert policy: Error rate > 1.0%"
msg["long_description"] = "Alert opened for Default application alert policy -- Triggered by: Error rate > 1.0% -- Apps currently involved: newrelicTestApp"
msg["alert_url"] = "https://rpm.newrelic.com/accounts/853919/incidents/19738033"
j = json.dumps(msg)

headers = {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"}
requests.post('https://neptune-staging-env.herokuapp.com/api/v1/trigger/channel/newrelic/03652462674c4d30ad183e3c8c048a82', headers=headers, data={u'alert': j})

