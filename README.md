# GOLANG and COBOL

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

## COBOL Datatypes

If you are using COBOL "PIC X(n)" as a receiving parameter, ensure the go code reserves enough space for the parameter otherwise stack corruption will occur.

As COBOL PIC X(n) data fields often include a lot of unrequired spaces, the use of strings.TrimRight is your friend.

## Signal handling

The Micro Focus COBOL runtime by default installs a signal handler and so does the go runtime.  

By using a cobconfig file & the environment variable COBCONFIG the SIGINT signal handler is turned off and a SEGSEGV when CTRL-C is used is avoided.

## Building and Deploying

Build the docker image with your tag of choice:

    docker build -t mfcobol/cobolformation .

Push to your preferred container registry and update the [ksvc.yaml](ksvc.yaml) with the appropriate image location.

## Testing the built image before deployment

You can do this by executing the following docker run command:

    docker run --expose 8080 -p 8080:8080 -ti mfcobol/cobolformation

### Deploy to Knative as KSVC

Assuming your Kubernetes cluster has already deployed [Knative Serving](https://knative.dev/docs/serving/), create the `demo` namespace and apply the `ksvc.yaml` to deploy the application.

    kubectl create namespace demo
    kubectl -n demo apply -f ksvc.yaml

Your COBOL application is now live, you can get the external IP address with

    kubectl -n demo get svc cobolformation

## Testing

You can test it with `curl`, using an example request like:

```bash
  curl -D- https://cobolformation.demo.k.triggermesh.net \
    -H 'Content-Type: application/json' \
    -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Type: greeting' \
    -H 'Ce-Source: my-workstation' \
    -H 'Ce-Id: 0000' \
    -d '{ "arg1": "hello,", "arg2": "replace me", "arg3":123.45, "arg4":234.5678,"arg5":3 }'
```

You should get an example response similar to:

```http
HTTP/1.1 200 OK
Ce-Id: e19a2bb0-88a2-450c-b6e5-3d12ca9a2be5
Ce-Processedid: 0000
Ce-Processedsource: my-workstation
Ce-Processedtype: greeting
Ce-Source: io.triggermesh.targets.mfcobol-sample
Ce-Specversion: 1.0
Ce-Time: 2021-09-13T10:26:54.906317879Z
Ce-Type: com.example.target.ack
Content-Length: 167
Content-Type: application/json
Date: Mon, 13 Sep 2021 10:26:54 GMT

{"code":0,"detail":{"message":"event processed successfully: [hello,Replaced in MFCOBOL]","arg3":223.4499969482422,"arg4":134.5678,"arg5":103,"processing_time_ms":25}}
```

The output could be cleaned up in the wrapper as necessary.

## Run locally

If you want to run and build it on your workstation, make sure you have *Micro Focus COBOL* installed for example: Visual COBOL

```
make run
```

## Author

This was originally written by [Jeff Neff](https://github.com/JeffNeff) for GnuCOBOL and then forked by [Stephen Gennard](https://github.com/triggermesh/cobolformation) for use with Micro Focus COBOL.
