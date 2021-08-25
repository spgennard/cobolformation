#

COBOLFormation is a Golang wrapper for COBOL applications, allowing them to run within Knative as a serverless application.

## How it Works

The [handler.go](handler.go) takes a CloudEvent’s data payload and uses it as the arguments for the wrapped [datatype.cob](datatype.cob).
The example [datatype.cob](datatype.cob) COBOL program takes the passed arguments as variables and does a few trivial operations to the data.
* A message is added to the first argument
* The second argument is replaced
* 100 is added to the third argument (float)
* 100 is subtracted from the fourth argument (double)
* 100 is added to the fifth argument (integer)

It should be fairly straightforward to upgrade the wrapper and the COBOL application for your own usage.

## Building and Deploying

Build the docker image with your tag of choice:

    docker build -t mattray/cobolformation .

Push to your preferred container registry and update the [ksvc.yaml](ksvc.yaml) with the appropriate image location.

### Deploy to Knative as KSVC

Assuming your Kubernetes cluster has already deployed [Knative Serving](https://knative.dev/docs/serving/), create the `demo` namespace and apply the `ksvc.yaml` to deploy the application.

    kubectl create namespace demo
    kubectl -n demo apply -f ksvc.yaml

Your COBOL application is now live, you can get the external IP address with

    kubectl -n demo get svc cobolformation

## Testing

You can test it with `curl`, using an example request like:

```
curl -D- https://cobolformation.demo.k.triggermesh.net \
    -H 'Content-Type: application/json' \
    -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Type: greeting' \
    -H 'Ce-Source: my-workstation' \
    -H 'Ce-Id: 0000' \
    -d '{ "arg1": "hello,", "arg2": "replace me", "arg3":123.45, "arg4":234.5678,"arg5":3 }'
```

You should get an example response similar to:

```
HTTP/2 200
ce-id: 744bcc55-0921-430a-995f-24261a13a521
ce-processedid: 0000
ce-processedsource: my-workstation
ce-processedtype: greeting
ce-source: io.triggermesh.targets.cobol-sample
ce-specversion: 1.0
ce-time: 2021-08-25T04:35:56.031101246Z
ce-type: com.example.target.ack
content-length: 179
content-type: application/json
date: Wed, 25 Aug 2021 04:35:56 GMT
x-envoy-upstream-service-time: 5655
server: istio-envoy

{"code":0,"detail":{"message":"event processed successfully:hello, Replaced in COBOL       ","arg3":223.4499969482422,"arg4":134.56779999999998,"arg5":103,"processing_time_ms":0}}
```

The output could be cleaned up in the wrapper as necessary.

## Run locally

If you want to run and build it on your workstation, make sure you have [GnuCOBOL](https://gnucobol.sourceforge.io/) installed.

```
make run
```

## Author

This was originally written by [Jeff Neff](https://github.com/JeffNeff).
