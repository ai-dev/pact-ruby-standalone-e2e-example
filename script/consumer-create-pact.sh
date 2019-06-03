#!/usr/bin/env bash

# start mock service
pact/bin/pact-mock-service start -p 1234 --pact-dir ./pacts --log ./log/foo-bar-mock-service.log

# clear interactions (not necessary for this example, just showing how)
curl -X DELETE -H "X-Pact-Mock-Service: true"  localhost:1234/interactions

# set up interaction (application/json)
curl -X POST -H "X-Pact-Mock-Service: true" -d@script/consumer-interaction.json localhost:1234/interactions

# set up interaction 2 (multipart)
curl -X POST -H "X-Pact-Mock-Service: true" -d@script/consumer-interaction2.json localhost:1234/interactions

# execute interaction (just the application/json one)
curl -X POST \
  http://localhost:1234/foo \
  -H 'Content-Type: application/json' \
  -H 'Host: localhost:1234' \
  -H 'content-length: 19' \
  -d '{
	"query":"TEST"
}'

# verify interaction took place
curl -H "X-Pact-Mock-Service: true" localhost:1234/interactions/verification

# write pact
curl -X POST -H "X-Pact-Mock-Service: true" -d '{"consumer": {"name": "Foo"}, "provider": {"name": "Bar"}}' localhost:1234/pact

# stop mock service
pact/bin/pact-mock-service stop -p 1234
