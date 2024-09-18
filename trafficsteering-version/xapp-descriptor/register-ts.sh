# get appmgr http ip
httpAppmgr=$(kubectl get svc -n ricplt | grep service-ricplt-appmgr-http | awk '{print $3}') 

# for delete the register by curl
curl -X POST "http://${httpAppmgr}:8080/ric/v1/deregister" -H "accept: application/json" -H "Content-Type: application/json" -d '{"appName": "trafficxapp", "appInstanceName": "trafficxapp"}'

# for delete the registeration which is registered after xapp is enabled (trafficxapp use null appInstanceName to register)
curl -X POST "http://${httpAppmgr}:8080/ric/v1/deregister" -H "accept: application/json" -H "Content-Type: application/json" -d '{"appName": "trafficxapp", "appInstanceName": ""}'

# get xapp http ip
httpEndpoint=$(kubectl get svc -n ricxapp | grep 8080 | awk '{print $3}')
# get xapp rmr ip
rmrEndpoint=$(kubectl get svc -n ricxapp | grep 4560 | awk '{print $3}')

# do register
curl -X POST "http://${httpAppmgr}:8080/ric/v1/register" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{
  "appName": "trafficxapp",
  "appVersion": "1.2.5",
  "configPath": "",
  "appInstanceName": "trafficxapp",
  "httpEndpoint": "",
  "rmrEndpoint": "10.102.212.190:4560",
  "config": "{\"name\": \"trafficxapp\", \"xapp_name\": \"trafficxapp\", \"version\": \"1.2.5\", \"containers\": [{\"name\": \"trafficxapp\", \"image\": {\"registry\": \"127.0.0.1:5000\", \"name\": \"o-ran-sc/ric-app-ts\", \"tag\": \"latest\" }}], \"messaging\": {\"ports\": [ {\"name\": \"rmr-data\", \"container\": \"trafficxapp\", \"port\": 4560, \"rxMessages\": [\"TS_QOE_PREDICTION\", \"A1_POLICY_REQ\", \"TS_ANOMALY_UPDATE\"], \"txMessages\": [\"TS_UE_LIST\", \"TS_ANOMALY_ACK\"], \"policies\": [20008], \"description\": \"rmr receive data port for trafficxapp\" }, {\"name\": \"rmr-route\", \"container\": \"trafficxapp\", \"port\": 4561, \"description\": \"rmr route port for trafficxapp\" } ] }, \"rmr\": {\"protPort\": \"tcp:4560\", \"maxSize\": 2072, \"numWorkers\": 1, \"txMessages\": [\"TS_UE_LIST\", \"TS_ANOMALY_ACK\"], \"rxMessages\": [\"TS_QOE_PREDICTION\", \"A1_POLICY_REQ\", \"TS_ANOMALY_UPDATE\"], \"policies\": [20008] }, \"controls\": {\"ts_control_api\": \"rest\", \"ts_control_ep\": \"http://127.0.0.1:5000/api/echo\" }}"
}'

# rollback xapp
kubectl rollout restart deployment --namespace ricxapp ricxapp-trafficxapp
