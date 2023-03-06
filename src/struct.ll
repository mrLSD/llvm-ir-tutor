%Struct = type { i64, i64 }
%Arr = type {
    [10 x %Struct],   ; fixed size array
    i32               ; length
}

define void @struct1_run() {
    %ptr_arr1 = alloca %Arr
    %arr1 = call %Arr @struct1()
    store %Arr %arr1, ptr %ptr_arr1
    ret void
}

define private %Arr @struct1() {
    %ptr_arr = alloca %Arr
    %ptr_i = alloca i32
    store i32 0, ptr %ptr_i
    %ptr_ln1 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 1
    ; Store length
    store i32 10, ptr %ptr_ln1
    br label %loop

loop:
    %i1 = load i32, ptr %ptr_i
    %i2 = add i32 %i1, 1
    store i32 %i2, ptr %ptr_i
    ; int arr.[i].0 = i
    %ptr_st1 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 0, i32 %i1, i32 0
    store i32 %i1, ptr %ptr_st1
    ; Struct s = arr.[i]
    %ptr_st2 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 0
    ; s[i].1 = i
    %ptr_st3 = getelementptr [10 x %Struct], ptr %ptr_st2, i32 %i1, i32 1
    store i32 %i1, ptr %ptr_st3
    %eq_loop = icmp slt i32 %i2, 10
    br i1 %eq_loop, label %loop, label %end

end:
    %arr = load %Arr, ptr %ptr_arr
    ret %Arr %arr
}
