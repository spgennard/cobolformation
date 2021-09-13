all: build

cobolformation:
	go build . 

cobol:
	cob -yU -o datatype.so -e "" *.cob

build: clean cobol cobolformation
	echo Complete	

run: build
	go run .

docker:
	docker build -t mfcobol/cobolformation .

make clean:
	rm -f *.o cobolformation datatype.so
