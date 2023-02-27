SRC_DIR = src
BUILD_DIR = build
SOURCES = $(wildcard $(SRC_DIR)/*.ll)
OBJECTS = $(SOURCES:$(SRC_DIR)/%.ll=$(BUILD_DIR)/%.o)
LLC = llc
LLC_ARGS = --thread-model=posix --filetype=obj
LLD = ld64.lld
LLD_ARGS = -arch arm64 -platform_version macos 12.0.0 13.1 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -lSystem /Library/Developer/CommandLineTools/usr/lib/clang/14.0.0/lib/darwin/libclang_rt.osx.a
LLVM_AS = llvm-as
LLVM_AS_ARGS = --data-layout=e-m:o-i64:64-i128:128-n32:64-S128

all: mkdir_build main

main: $(OBJECTS)
	@gcc $^ -o $(BUILD_DIR)/$@

$(OBJECTS): $(BUILD_DIR)/%.o: $(SRC_DIR)/%.ll
	@$(LLC) $(LLC_ARGS) -o $@ $<

run:
	@${LLC} main.ll -o build/main.o
	@${LLC} attributes.ll -o build/attributes.o
	@${LLC} math.ll -o build/math.o
	@gcc build/main.o build/attributes.o build/math.o -o build/main
	@ls -l build
	@build/main

mkdir_build:
	@mkdir -p $(BUILD_DIR)

lld:
	@mkdir build || true
	@${LLC} main.ll -o build/main.o
	@${LLC} attributes.ll -o build/attributes.o
	@${LLC} math.ll -o build/math.o
	@${LLD} build/main.o build/attributes.o build/math.o -o build/main
	@build/main
