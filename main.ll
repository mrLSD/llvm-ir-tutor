@.str = private constant [15 x i8] c"Res: %u %i %d\0A\00"
@.x = global i32 12
@.y = private constant i32 10

declare i32 @printf(ptr, ...)
declare i32 @scan(ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @exit(i32)

define i32 @main() {
    ; get global var
    %1 = load i32, ptr @.x
    ; multiply
    %2 = mul i32 %1, 5
    ; set result to global var
    store i32 %2, ptr @.x
    %3 = alloca i32
    %4 = load i32, ptr @.x
    %5 = load i32, ptr @.y
    %6 = mul i32 %1, %4
    %7 = add i32 %5, %6
    store i32 %7, ptr %3

    call i32 (ptr, ...) @printf(ptr @.str, i32 %1, i32 %7, i32 %2)

    ret i32 %2
}