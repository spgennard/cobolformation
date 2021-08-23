## Run locally
```
make run
```

## Deploy to Knative as KSVC
```
kubectl -n demo apply -f ksvc.yaml
```

## Example Request:
```
curl -D- http://localhost:8080/ \
    -H 'Content-Type: application/json' \
    -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Type: greeting' \
    -H 'Ce-Source: my-workstation' \
    -H 'Ce-Id: 0000' \
    -d '{ "arg1": "hello,", "arg2": "replace me", "arg3":-123.22, "arg4":234.3333,"arg5":-3 }'
```

## Example Response:
```
HTTP/1.1 200 OK
Ce-Id: f470af12-3a87-4474-85ae-d8fef9f1cfdc
Ce-Processedid: 0000
Ce-Processedsource: my-workstation
Ce-Processedtype: greeting
Ce-Source: io.triggermesh.targets.cobol-sample
Ce-Specversion: 1.0
Ce-Time: 2021-08-10T16:14:29.698595Z
Ce-Type: com.example.target.ack
Content-Length: 172
Content-Type: application/json
Date: Tue, 10 Aug 2021 16:14:29 GMT

{"code":0,"detail":{"message":"event processed successfully:hello, Replaced in COBOL       ","arg3":-23.220001220703125,"arg4":334.3333,"arg5":-103,"processing_time_ms":1}}%  
```
