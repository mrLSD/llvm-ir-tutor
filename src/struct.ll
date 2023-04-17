@.str1 = private global [23 x i8] c"St{[%d].{%d, %d}, %d}\0A\00"
@.str2 = private global [15 x i8] c"StI64[%d]{%d}\0A\00"

%Struct = type { i64, i64 }
%Arr = type {
    [10 x %Struct],   ; fixed size array
    i32               ; length
}

;; Example: store type StructI64 through `ptr` to %StructAsSlice type
;; It is possible because `StructAsSlice` declared with fixed size
;; array with size of struct `StructI64`: [8 x i8] 
%StructAsSlice = type { [8 x i8] }
%StructI64 = type { i64 }

;; Enum implementation.
;; Enum = { IndexOfEnumElement, MaxSizeOfType }
;; where MaxSizeOfType calculated by maximum size of type.
;; For example: i8 (1 byte), i32 (4 byte), i64 (8 byte)
;; so i64 is MaxSizeOf type = 8 bytes
%Enum = type { i8, [8 x i8] }
%EnumI64 = type { i8, i64 }
%EnumBool = type { i8, i1 }
%StructF64 = type { i8, double }
%EnumToken = type { i8 }


declare i32 @printf(ptr, ...)

define void @struct1_run() {
    %ptr_arr = alloca %Arr
    %ptr_i = alloca i32
    store i32 0, ptr %ptr_i
    %arr1 = call %Arr @struct1()
    store %Arr %arr1, ptr %ptr_arr
    ; st_1 =  int arr.1
    %ptr_st1 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 1
    %st_1 = load i32, ptr %ptr_st1
    br label %loop

loop:
    %i1 = load i32, ptr %ptr_i
    %i2 = add i32 %i1, 1
    store i32 %i2, ptr %ptr_i
    ; res = int arr.[i].0
    %ptr_st2 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 0, i32 %i1, i32 0
    ; Struct s = arr.[i]
    %ptr_st3 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 0
    ; s[i].1 = i
    %ptr_st4 = getelementptr [10 x %Struct], ptr %ptr_st3, i32 0, i32 %i1, i32 1
    %res1 = load i32, ptr %ptr_st2
    %res2 = load i32, ptr %ptr_st4
    %p1 = call i32 @printf(ptr @.str1, i32 %i1, i32 %res1, i32 %res2, i32 %st_1)
    %eq_loop = icmp slt i32 %i2, 10
    br i1 %eq_loop, label %loop, label %end

end:
    call void @struct_as_slice_run()
    call void @enum_run()
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
    %ptr_st3 = getelementptr [10 x %Struct], ptr %ptr_st2, i32 0, i32 %i1, i32 1
    store i32 %i2, ptr %ptr_st3
    %eq_loop = icmp slt i32 %i2, 10
    br i1 %eq_loop, label %loop, label %next

next:
    ; int arr.1 = i
    %ptr_st4 = getelementptr %Arr, ptr %ptr_arr, i32 0, i32 1
    store i32 33, ptr %ptr_st4
    br label %end

end:
    %arr = load %Arr, ptr %ptr_arr
    ret %Arr %arr
}

;; Example: store one type (StructI64) through pointer to
;; another basic type (StructAsSlice). And read again to (StructI64).
;; It's possible because `StructAsSlice` declared as array with 
;; size of struct `StructI64`: [8 x i8]
define void @struct_as_slice_run() {
    %st = alloca %StructAsSlice 
    ; Also valid type: StructI64
    ; It's just example, it can be StructAsSlice or StructI64
    %ptr_mem1 = getelementptr %StructAsSlice, ptr %st, i32 0, i32 0
    store i64 333, ptr %ptr_mem1
    
    %ptr_mem2 = getelementptr %StructI64, ptr %st, i32 0, i32 0
    %i1 = load i64, ptr %ptr_mem2
    %p1 = call i32 @printf(ptr @.str2, i8 0, i64 %i1)    
    ret void
}

;; Store and read data from Enum type.
;; How it works: allocate `Enum` type ptr variable
define void @enum_run() {
    %st = alloca %Enum 
    ; %ptr_mem1 = getelementptr %Enum64, ptr %st, i32 0, i32 1
    ; store i64 333, ptr %ptr_mem1
    ; %ptr_mem2 = getelementptr %StructI64, ptr %st, i32 0, i32 0
    ; %i1 = load i64, ptr %ptr_mem2
    ; %p1 = call i32 @printf(ptr @.str2, i8 0, i64 %i1)    
    ret void
}
