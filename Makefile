LLC = llc --thread-model=posix --filetype=obj
LLD = ld64.lld -arch arm64 -platform_version macos 12.0.0 13.1 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -lSystem /Library/Developer/CommandLineTools/usr/lib/clang/14.0.0/lib/darwin/libclang_rt.osx.a
LLVMAS = llvm-as --data-layout=e-m:o-i64:64-i128:128-n32:64-S128

run:
	@mkdir build || true
	@${LLC} main.ll -o build/main.o
	@${LLC} attributes.ll -o build/attributes.o
	@gcc build/main.o build/attributes.o -o build/main
	@ls -l build
	@build/main

lld:
	@mkdir build || true
	@${LLC} main.ll -o build/main.o
	@${LLC} attributes.ll -o build/attributes.o
	@${LLD} build/main.o build/attributes.o -o build/main
	@build/main
