@.str1 = private global [31 x i8] c"Formula range: %d; sin(%f)=%f\0A\00"

declare i32 @printf(ptr, ...)
declare double @pow(double, double)
declare double @sin(double)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @exit(i64)

;; Calculate results for incoming array results
;; for function:
;;  f(x) = x^3 + 2x - 3(x/4 + 6sin(x/2))^1.2
define ptr @formula1(ptr %arr, i32 %range) {

    ; %d = sitofp i8 %i to double
    %1 = alloca double
    %2 = call double @sin(double 3.4)
    call i32 (ptr, ...) @printf(ptr @.str1, i32 %range, double 3.4, double %2)
    ret ptr %1
}

define void @calc_formula1(i32 %range) {
    ; Init array for `double` type (sizeof = 8)
    %1 = call ptr @vec_new_with_capacity_raw(i32 %range, i64 8)


    ;=====================
    %2 = load ptr, ptr %1
    call void @free(ptr %2)
    ret void
}

;; Init vector in memory with fixed `capacity` and known
;; `sizeof` for vector type. Vector not initialized
;; with zero values. It mean uninit raw data.
define ptr @vec_new_with_capacity_raw(i32 %capacity, i64 %sizeof) {
    %1 = alloca ptr
    %2 = zext i32 %capacity to i64
    %3 =  mul i64 %2, %sizeof
    %4 = call ptr @malloc(i64 %3)
    store ptr %4, ptr %1
    ret ptr %1
}
