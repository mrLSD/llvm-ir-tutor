@.str1 = private global [23 x i8] c"St{[%d].{%d, %d}, %d}\0A\00"
@.str2 = private global [15 x i8] c"StI64[%d]{%d}\0A\00"
@.str3 = private global [15 x i8] c"StF64[%d]{%f}\0A\00"
@.str4 = private global [16 x i8] c"StBool[%d]{%d}\0A\00"
@.str5 = private global [17 x i8] c"StToken[%d]{%d}\0A\00"

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
%EnumF64 = type { i8, double }
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
    %enI64 = alloca %Enum
    %enBool = alloca %Enum
    %enF64 = alloca %Enum
    %enToken = alloca %Enum
    
    %ptr_mem1 = getelementptr inbounds %EnumI64, ptr %enI64, i32 0, i32 1
    store i64 333, ptr %ptr_mem1
    store i8 0, ptr %enI64
    
    %ptr_mem2 = getelementptr inbounds %EnumF64, ptr %enF64, i32 0, i32 1
    store double 2.1, ptr %ptr_mem2
    store i8 1, ptr %enF64    
  
    %ptr_mem3 = getelementptr inbounds %EnumBool, ptr %enBool, i32 0, i32 1
    store i1 1, ptr %ptr_mem3
    store i8 2, ptr %enBool  
    
    store i8 3, ptr %enToken
    
    %i1 = load i64, ptr %ptr_mem1
    %ind1 = load i8, ptr %enI64
    %p1 = call i32 @printf(ptr @.str2, i8 %ind1, i64 %i1)
    
    %i2 = load double, ptr %ptr_mem2
    %ind2 = load i8, ptr %enF64
    %p2 = call i32 @printf(ptr @.str3, i8 %ind2, double %i2)    
    
    %i3 = load i1, ptr %ptr_mem3
    %ind3 = load i8, ptr %enBool
    %p3 = call i32 @printf(ptr @.str4, i8 %ind3, i1 %i3)    

    %ind4 = load i8, ptr %enToken
    %p4 = call i32 @printf(ptr @.str5, i8 %ind4, i64 0)
        
    ret void
}
