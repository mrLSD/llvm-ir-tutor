run:
	@docker run --rm -v `pwd`:/llvm -w /llvm mrlsd/llc:15.07 --thread-model=posix --filetype=obj main.ll
	@ls -l main.o
	@gcc main.o -o main
