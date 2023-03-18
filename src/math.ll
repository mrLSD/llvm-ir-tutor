@.str1 = private global [31 x i8] c"Formula range: %d; sin(%f)=%f\0A\00"
@.str2 = private global [11 x i8] c"[%d] = %d\0A\00"
@.str3 = private global [4 x i8] c"#1\0A\00"
@.str4 = private global [8 x i8] c"Failed\0A\00"

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
    %ptr_arr = alloca ptr
    %ptr_range = alloca i32
    store i32 %range, ptr %ptr_range

    %mem_ptr1 = call ptr @vec_new_with_capacity_raw(i32 %range, i32 8)
    store ptr %mem_ptr1, ptr %ptr_arr

    %mem_ptr2 = load ptr, ptr %ptr_arr
    %range2 = load i32, ptr %ptr_range
    call void @prepare_vec(ptr %mem_ptr2, i32 %range2)

    %mem_ptr3 = load ptr, ptr %ptr_arr
    call void @free(ptr %mem_ptr3)
    ret void
}

define private void @prepare_vec(ptr %vec, i32 %range) {
    %ptr_arr = alloca ptr
    %ptr_range = alloca i32
    %ptr_i = alloca i32
    store ptr %vec, ptr %ptr_arr
    store i32 %range, ptr %ptr_range
    store i32 0, ptr %ptr_i
    br label %next1

next1:
    %range_next1 = load i32, ptr %ptr_range
    %eq_next1 = icmp sgt i32 %range_next1, 0
    br i1 %eq_next1, label %next2, label %end

next2:
    %i1 = load i32, ptr %ptr_i
    %ptr_mem1 = load ptr, ptr %ptr_arr
    %index1 = sext i32 %i1 to i64
    %ptr_mem2 = getelementptr inbounds i32, ptr %ptr_mem1, i64 %index1
    store i32 %i1, ptr %ptr_mem2
    br label %next3

next3:
    %i2 = load i32, ptr %ptr_i
    %range1 = load i32, ptr %ptr_range
    %i3 = add i32 %i2, 1
    store i32 %i3, ptr %ptr_i
    %eq_next3 = icmp slt i32 %i3, %range1
    br i1 %eq_next3, label %next2, label %end

end:
    ret void
}

;; Init vector in memory with fixed `capacity` and known
;; `sizeof` for vector type. Vector not initialized
;; with zero values. It mean uninit raw data.
define private ptr @vec_new_with_capacity_raw(i32 %capacity, i32 %sizeof) {
    %ptr_arr = alloca ptr
    %ptr_capacity = alloca i32
    %ptr_sizeof = alloca i32
    store i32 %capacity, ptr %ptr_capacity
    store i32 %sizeof, ptr %ptr_sizeof

    %capacity1 = load i32, ptr %ptr_capacity
    %sizeof1 = load i32, ptr %ptr_sizeof
    %capacity2 = sext i32 %capacity1 to i64
    %sizeof2 = sext i32 %sizeof1 to i64
    %size =  mul i64 %capacity2, %sizeof2

    %ptr_mem1 = call ptr @malloc(i64 %size)
    store ptr %ptr_mem1, ptr %ptr_arr
    %ptr_mem2 = load ptr, ptr %ptr_arr
    %eq1 = icmp eq ptr %ptr_mem2, null
    br i1 %eq1, label %fail, label %end

fail:
    %p1 = call i32 (ptr, ...) @printf(ptr @.str3)
    call void @exit(i32 0)
    unreachable

end:
    %ptr_mem3 = load ptr, ptr %ptr_arr
    ret ptr %ptr_mem3
}
