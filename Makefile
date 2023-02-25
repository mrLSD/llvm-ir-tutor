run:
	@llc --thread-model=posix --filetype=obj main.ll
	@ls -l main.o
	@gcc main.o -o main
