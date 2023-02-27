@.str = private constant [30 x i8] c"Calc: (%d * %i)*%d + %d = %d\0A\00"
@.x = global i32 12
@.y = private constant i32 10

declare i32 @printf(ptr, ...)
declare i32 @scan(ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @exit(i32)

declare i32 @calc()
declare void @ext_func1(ptr, ptr)
declare void @ext_func2(ptr nocapture, ptr nocapture, ptr nocapture)

define i32 @main() {
    %1 = call i32 @calc()
    %2 = call i32 @math_and_print(i32 %1)
    call void @call_ext_func1()
    ret i32 %2
}

define i32 @math_and_print(i32 %x) {
    ; get global var
    %1 = load i32, ptr @.x
    ; store previous value of @.x
    %.x = alloca i32
    store i32 %1, ptr %.x
    ; multiply
    %.2 = mul i32 %1, %x
    %2 = mul i32 %.2, 3
    ; set result to global var
    store i32 %2, ptr @.x
    %3 = alloca i32
    %4 = load i32, ptr @.x
    %5 = load i32, ptr @.y
    %6 = add i32 %4, %5
    store i32 %6, ptr %3
    %7 = load i32, ptr %3
    %8 = load i32, ptr %.x

    call i32 (ptr, ...) @printf(ptr @.str, i32 %8, i32 %x, i32 3, i32 %5, i32 %7)
    ret i32 0
}

define void @call_ext_func1() {
    %1 = alloca i32
    %2 = alloca i32
    store i32 10, ptr %1
    store i32 20, ptr %2
    call void @ext_func1(ptr %1, ptr %2)
    call void @ext_func2(ptr %1, ptr %1, ptr %1)
    ret void
}
