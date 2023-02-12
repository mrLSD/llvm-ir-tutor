LLC = llc --thread-model=posix --filetype=obj
LLD = ld64.lld -arch arm64 -platform_version macos 12.0.0 13.1 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -lSystem /Library/Developer/CommandLineTools/usr/lib/clang/14.0.0/lib/darwin/libclang_rt.osx.a
LLVMAS = llvm-as --data-layout=e-m:o-i64:64-i128:128-n32:64-S128
run:
	@${LLC} main.ll
	@${LLC} attributes.ll
	@ls -l *.o main
	@gcc main.o attributes.o -o main
	@./main

lld:
	@${LLC} main.ll
	@${LLC} attributes.ll
	@${LLD} main.o attributes.o -o main
