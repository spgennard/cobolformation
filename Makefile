COBFLAGS=-v
COBSRC=datatype.o

all: build

cobolformation:
	go build . 

cobol: $(COBSRC)
	cob -ytU $(COBFLAGS) -o datatype.so -e "" $(COBSRC)

build: clean cobol cobolformation
	echo Complete	

run: build
	go run .

docker:
	docker build -t mfcobol/cobolformation .

docker.run: docker
	docker run --expose 8080 -p 8080:8080 -ti mfcobol/cobolformation

make clean:
	rm -f *.o *.int *.idy cobolformation datatype.so

%.o : %.cob
	cob -ytUc -C 'reentrant(2)' $(COBFLAGS) $< -o $@

%.o : %.cbl
	cob -ytUc -C 'reentrant(2)' $(COBFLAGS) $< -o $@	