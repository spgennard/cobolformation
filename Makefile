build:
	rm -rf *.o && rm -rf libgbc.a && \
	cobc -c -static *.cob && ar q libgbc.a *.o && go build . 
	

run: 
	rm -rf *.o && rm -rf libgbc.a && \
	cobc -c -static *.cob && ar q libgbc.a *.o && go run .

make clean:
	rm -rf *.o && rm -rf libgbc.a && rm -rf cobolformation