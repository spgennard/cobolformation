/*
Copyright (c) 2021 TriggerMesh Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"strings"
	"time"

	cloudevents "github.com/cloudevents/sdk-go/v2"
)

/*
#cgo CFLAGS: -I.-fpic
#cgo LDFLAGS: -L. -L/usr/lib -ldl
#include <dlfcn.h>
#include <stdio.h>

int datatype2(char *arg1, char *arg2,float *arg3,double *arg4, signed int *arg5) {
	int (*datatype_pp)(char *arg1, char *arg2,float *arg3,double *arg4, signed int *arg5);
	int ret=-1;

	void *handle = dlopen("datatype.so", RTLD_GLOBAL | RTLD_NOW);
	if (handle == 0) {
		printf("FAILED to load datatype.so\n");
		printf(" REASON: %s\n",dlerror());
		return ret;
	}

	datatype_pp = dlsym(handle,"datatype");

	if (datatype_pp != 0) {
		ret = datatype_pp(arg1,arg2,arg3,arg4,arg5);
		dlclose(handle);
	} else {
		printf("FAILED to find datatype\n");
		printf(" REASON: %s\n",dlerror());
	}
	return ret;
}
*/
import "C"

const (
	eventTypeAck = "com.example.target.ack"

	eventSrcName = "io.triggermesh.targets.mfcobol-sample"

	ceExtProcessedType   = "processedtype"
	ceExtProcessedID     = "processedid"
	ceExtProcessedSource = "processedsource"
)

// Handler runs a CloudEvents receiver.
type Handler struct {
	cli cloudevents.Client
}

// NewHandler returns a new Handler for the given CloudEvents client.
func NewHandler(c cloudevents.Client) *Handler {
	rand.Seed(time.Now().UnixNano())

	return &Handler{
		cli: c,
	}
}

// Run starts the handler and blocks until it returns.
func (h *Handler) Run(ctx context.Context) error {
	return h.cli.StartReceiver(ctx, h.receive)
}

// ACKResponse represents the data of a CloudEvent payload returned to
// acknowledge the processing of an event.
type ACKResponse struct {
	Code   ACKCode     `json:"code"`
	Detail interface{} `json:"detail"`
}

// ACKCode defines the outcome of the processing of an event.
type ACKCode int

// Enum of supported ACK codes.
const (
	CodeSuccess ACKCode = iota // 0
	CodeFailure                // 1
)

// receive implements the handler's receive logic.
func (h *Handler) receive(e cloudevents.Event) (*cloudevents.Event, cloudevents.Result) {
	code := CodeSuccess
	ceResult := cloudevents.ResultACK

	result, err := processEvent(e)
	if err != nil {
		code = CodeFailure
		ceResult = cloudevents.ResultNACK
	}

	return newAckEvent(e, code, result), ceResult
}

// processEvent processes the event and returns the result of the processing.
func processEvent(e cloudevents.Event) (interface{} /*result*/, error) {
	tBegin := time.Now()

	r := &Request{}

	if err := e.DataAs(r); err != nil {
		fmt.Println("err:", err)
		return nil, err
	}

	// C.cob_init(0, nil)

	arg1 := C.CString(r.Arg1 + strings.Repeat(" ", 24))
	arg2 := C.CString(r.Arg2 + strings.Repeat(" ", 24))
	arg3 := C.float(r.Arg3)
	arg4 := C.double(r.Arg4)
	arg5 := C.int(r.Arg5)

	C.datatype2(arg1, arg2, &arg3, &arg4, &arg5)

	res := &result{
		Message: "event processed successfully: [" +
			strings.TrimRight(C.GoString(arg1), " ") +
			C.GoString(arg2) + "]",
		Arg3:           float64(arg3),
		Arg4:           float64(arg4),
		Arg5:           int(arg5),
		ProcessingTime: time.Since(tBegin).Milliseconds(),
	}

	return res, nil
}

// result represents a fictional structured result of some event
// processing.
type result struct {
	Message        string  `json:"message"`
	Arg3           float64 `json:"arg3"`
	Arg4           float64 `json:"arg4"`
	Arg5           int     `json:"arg5"`
	ProcessingTime int64   `json:"processing_time_ms"`
}

type Request struct {
	Arg1 string  `json:"arg1"`
	Arg2 string  `json:"arg2"`
	Arg3 float32 `json:"arg3"`
	Arg4 float64 `json:"arg4"`
	Arg5 int     `json:"arg5"`
}

// newAckEvent returns a CloudEvent that acknowledges the processing of an
// event.
func newAckEvent(e cloudevents.Event, code ACKCode, detail interface{}) *cloudevents.Event {
	resp := cloudevents.NewEvent()
	resp.SetType(eventTypeAck)
	resp.SetSource(eventSrcName)
	resp.SetExtension(ceExtProcessedType, e.Type())
	resp.SetExtension(ceExtProcessedSource, e.Source())
	resp.SetExtension(ceExtProcessedID, e.ID())

	data := &ACKResponse{
		Code:   code,
		Detail: detail,
	}

	if err := resp.SetData(cloudevents.ApplicationJSON, data); err != nil {
		log.Panicf("Error serializing CloudEvent data: %s", err)
	}

	return &resp
}
