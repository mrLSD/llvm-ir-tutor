@.str1 = private global [31 x i8] c"Formula range: %d; sin(%f)=%f\0A\00"
@.str2 = private global [11 x i8] c"[%d] = %d\0A\00"

declare i32 @printf(ptr, ...)
declare double @pow(double, double)
declare double @llvm.sin(double)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @exit(i64)

;; Calculate results for incoming array results
;; for function:
;;  f(x) = x^3 + 2x - 3(x/4 + 6sin(x/2))^1.2
define ptr @formula1(ptr %arr, i32 %range) {
    ; %d = sitofp i8 %i to double
    %1 = alloca double
    %2 = call double @llvm.sin(double 3.4)
    call void @calc_formula1(i32 %range)
    
    call i32 (ptr, ...) @printf(ptr @.str1, i32 %range, double 3.4, double %2)
    ret ptr %1
}

define private void @calc_formula1(i32 %range) {
    ; Init array for `double` type (sizeof = 8)
    %1 = call ptr @vec_new_with_capacity_raw(i32 %range, i64 8)
    call void @prepare_vec(ptr %1)
    call void @vec_free(ptr %1)
    ret void
}

define private void @prepare_vec(ptr %vec, i32 %range) {
    %1 = load ptr, ptr %vec
    %i.ptr = alloca i32
    store i32 0, ptr %i.ptr
    %2 = icmp sgt i32 %range, 0
    br i1 %2, label %loop, label %end
    
loop:
    %3 = load i32, ptr %i.ptr
    %4 = load ptr, ptr %vec
    %5 = getelementptr inbounds i32, ptr %4, i32 %3
    store i32 %3, ptr %4
    %6 = add i32 %3, 1
    store i32 %6, ptr %i.ptr
    %7 = icmp sle i32 %3, %range 
    br i1 %7, label %loop, label %end
     
end:
    store i32 0, ptr %i.ptr
    br label %print
    
print:
    %8 = load i32, ptr %i.ptr
    %9 = load ptr, ptr %vec
    %.ptr10 = getelementptr inbounds i32, ptr %4, i32 0, i32 %8
    %10 = load i32, ptr %.ptr10
    call i32 (ptr, ...) @printf(ptr @.str2, i32 %8, i32 %10)
    %12 = add i32 %8, 1
    store i32 %12, ptr %i.ptr
    %13 = icmp sle i32 %8, %range 
    br i1 %13, label %print, label %print_end

print_end:
    ret void
}

;; Init vector in memory with fixed `capacity` and known
;; `sizeof` for vector type. Vector not initialized
;; with zero values. It mean uninit raw data.
define private ptr @vec_new_with_capacity_raw(i32 %capacity, i64 %sizeof) {
    %1 = alloca ptr
    %2 = zext i32 %capacity to i64
    %3 =  mul i64 %2, %sizeof
    %4 = call ptr @malloc(i64 %3)
    store ptr %4, ptr %1
    ret ptr %1
}

; Free allocated memory
define private void @vec_free(ptr %vec) {
    %1 = load ptr, ptr %vec
    call void @free(ptr %1)
    ret void
}
