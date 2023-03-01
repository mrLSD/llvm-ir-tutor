SRC_DIR = src
BUILD_DIR = build
SOURCES = $(wildcard $(SRC_DIR)/*.ll)
OBJECTS = $(SOURCES:$(SRC_DIR)/%.ll=$(BUILD_DIR)/%.o)
BITCODE = $(SOURCES:$(SRC_DIR)/%.ll=$(BUILD_DIR)/%.bc)
EXECUTABLE = $(BUILD_DIR)/main

LLC = llc
LLC_ARGS = --thread-model=posix --filetype=obj

LLVM_AS = llvm-as
LLVM_AS_ARGS = --data-layout=e-m:o-i64:64-i128:128-n32:64-S128
GCC = gcc
GCC_ARGS =

OS = $(shell uname)
ifeq ($(OS),Darwin)
	LLD = ld64.lld
	LLD_ARGS = -arch arm64 -platform_version macos 12.0.0 13.1 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -lSystem /Library/Developer/CommandLineTools/usr/lib/clang/14.0.0/lib/darwin/libclang_rt.osx.a
else ifeq ($(OS),Linux)
	LLD = ld.lld
	LLD_ARGS =
endif

all: mkdir_build llc preview

llc: $(OBJECTS)
	@$(GCC) $(GCC_ARGS) $^ -o $(EXECUTABLE)

$(OBJECTS): $(BUILD_DIR)/%.o: $(SRC_DIR)/%.ll
	@$(LLC) $(LLC_ARGS) -o $@ $<

mkdir_build:
	@mkdir -p $(BUILD_DIR)

lld: mkdir_build lld-link preview

lld-link: $(OBJECTS)
	@$(LLD) $(LLD_ARGS) $^ -o $(EXECUTABLE)

preview:
	@ls -lh $(BUILD_DIR)
	@$(EXECUTABLE)

as: mkdir_build assemble preview

assemble: $(BITCODE)
	@$(LLD) $(LLD_ARGS) $^ -o $(EXECUTABLE)

$(BITCODE): $(BUILD_DIR)/%.bc: $(SRC_DIR)/%.ll
	@$(LLVM_AS) $(LLVM_AS_ARGS) -o $@ $<
