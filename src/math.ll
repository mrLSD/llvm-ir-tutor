@.str1 = private global [31 x i8] c"Formula range: %d; sin(%f)=%f\0A\00"
@.str2 = private global [12 x i8] c"[%d] = %lf\0A\00"
@.str3 = private global [8 x i8] c"Failed\0A\00"

declare i32 @printf(ptr, ...)
declare double @pow(double, double)
declare double @llvm.sin(double)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @exit(i64)
declare double @llvm.pow.f64(double, double)

;; Calculate results for incoming array results
;; for function:
;; f(x) = x^2.3 + 2x - 3(x/4 + 6sin(x/2))
define void @formula1(ptr %arr, i32 %range) {
    call void @calc_formula1(i32 %range)
    ret void
}

define private void @calc_formula1(i32 %range) {
    %ptr_arr = alloca ptr
    %ptr_range = alloca i32
    store i32 %range, ptr %ptr_range

    %mem_ptr1 = call ptr @vec_new_with_capacity_raw(i32 %range, i32 16)
    store ptr %mem_ptr1, ptr %ptr_arr

    %mem_ptr2 = load ptr, ptr %ptr_arr
    %range2 = load i32, ptr %ptr_range
    call void @prepare_vec(ptr %mem_ptr2, i32 %range2)

    %mem_ptr3 = load ptr, ptr %ptr_arr
    %range3 = load i32, ptr %ptr_range
    call void @get_vec(ptr %mem_ptr3, i32 %range3)

    %mem_ptr4 = load ptr, ptr %ptr_arr
    call void @free(ptr %mem_ptr4)
    ret void
}

define private double @calc_formula2(double %val) {
    %ptr_val = alloca double
    store double %val, ptr %ptr_val
    %val1 = load double, ptr %ptr_val
    %val_x_pow_3 = call double @llvm.pow.f64(double %val1, double 2.3)

    %val2 = load double, ptr %ptr_val
    %val_x_mul_2 = fmul double 2.0, %val2

    %val3 = load double, ptr %ptr_val
    %val_x_div_4 = fdiv double %val3, 4.0

    %val4 = load double, ptr %ptr_val
    %val_x_div_2 = fdiv double %val4, 2.0

    %sin_x = call double @llvm.sin(double %val_x_div_2)
    %sin_x6 = fmul double 6.0, %sin_x
    %x_div_4_plus_6sin_x = fadd double %sin_x6, %val_x_div_4
    %x3_div_4_plus_6sin_x = fmul double %x_div_4_plus_6sin_x, 3.0
    %x_add =  fadd double %val_x_pow_3, %val_x_mul_2
    %res = fsub double %x_add, %x3_div_4_plus_6sin_x
    ret double %res
}

define private void @prepare_vec(ptr %vec, i32 %range) {
    %ptr_arr = alloca ptr
    %ptr_range = alloca i32
    %ptr_i = alloca i32
    %ptr_val = alloca double
    store ptr %vec, ptr %ptr_arr
    store i32 %range, ptr %ptr_range
    store i32 0, ptr %ptr_i
    store double 0.0, ptr %ptr_val
    br label %next1

next1:
    %range_next1 = load i32, ptr %ptr_range
    %eq_next1 = icmp sgt i32 %range_next1, 0
    br i1 %eq_next1, label %next2, label %end

next2:
    %i1 = load i32, ptr %ptr_i
    %d = sitofp i32 %i1 to double
    %val1 = call double @calc_formula2(double %d)
    store double %val1, ptr %ptr_val
    br label %next3

next3:
    %i2 = load i32, ptr %ptr_i
    %ptr_mem1 = load ptr, ptr %ptr_arr
    %index1 = sext i32 %i2 to i64
    %ptr_mem2 = getelementptr inbounds double, ptr %ptr_mem1, i64 %index1
    %val2 = load double, ptr %ptr_val
    store double %val2, ptr %ptr_mem2
    br label %next4

next4:
    %i3 = load i32, ptr %ptr_i
    %range1 = load i32, ptr %ptr_range
    %i4 = add i32 %i3, 1
    store i32 %i4, ptr %ptr_i
    %eq_next4 = icmp slt i32 %i4, %range1
    br i1 %eq_next4, label %next2, label %end

end:
    ret void
}

define private void @get_vec(ptr %vec, i32 %range) {
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
    %ptr_mem2 = getelementptr inbounds double, ptr %ptr_mem1, i64 %index1
    %i_arr = load double, ptr %ptr_mem2
    %p1 = call i32 (ptr, ...) @printf(ptr @.str2, i32 %i1, double %i_arr)
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
