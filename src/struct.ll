@.str1 = private global [23 x i8] c"St{[%d].{%d, %d}, %d}\0A\00"
@.str2 = private global [15 x i8] c"StI64[%d]{%d}\0A\00"
@.str3 = private global [15 x i8] c"StI16[%d]{%d}\0A\00"
@.str4 = private global [15 x i8] c"StI32[%d]{%d}\0A\00"
@.str5 = private global [15 x i8] c"StF64[%d]{%f}\0A\00"
@.str6 = private global [16 x i8] c"StBool[%d]{%d}\0A\00"
@.str7 = private global [17 x i8] c"StToken[%d]{%d}\0A\00"

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
%EnumBool = type { i8, i8 }
%EnumF64 = type { i8, double }
%EnumI16 = type { i8, i16 }
%EnumI32 = type { i8, i32 }
%EnumToken = type { i8 }

;; Point type: Pointer { i32 x, i32 y }
%Point = struct { i32, i32 }

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
;; Be carfully: index zext i8 -> i64 is required action
define void @enum_run() {
    ;===============================
    ; Allocate enum types
    %enI64 = alloca %Enum
    %enBool = alloca %Enum
    %enF64 = alloca %Enum
    %enI16 = alloca %Enum
    %enI32 = alloca %Enum
    %enToken = alloca %Enum
  
    ;===============================
    ; Set enum data  
    %ptr_mem1 = getelementptr inbounds %EnumI64, ptr %enI64, i32 0, i32 1
    store i64 333, ptr %ptr_mem1
    store i8 0, ptr %enI64
 
    %ptr_mem2 = getelementptr inbounds %EnumI16, ptr %enI16, i32 0, i32 1
    store i64 222, ptr %ptr_mem2
    store i8 1, ptr %enI16
    
    %ptr_mem3 = getelementptr inbounds %EnumI32, ptr %enI32, i32 0, i32 1
    store i64 111, ptr %ptr_mem3
    store i8 2, ptr %enI32    
    
    %ptr_mem4 = getelementptr inbounds %EnumF64, ptr %enF64, i32 0, i32 1
    store double 2.1, ptr %ptr_mem4
    store i8 3, ptr %enF64    
  
    %ptr_mem5 = getelementptr inbounds %EnumBool, ptr %enBool, i32 0, i32 1
    store i8 1, ptr %ptr_mem5
    store i8 4, ptr %enBool  
    
    ; Set token data - just index
    store i8 5, ptr %enToken
    
    ;===============================
    ; Read & print Enum data
    %i1 = load i64, ptr %ptr_mem1
    %_ind1 = load i8, ptr %enI64
    %ind1 = zext i8 %_ind1 to i64    
    %p1 = call i32 @printf(ptr @.str2, i64 %ind1, i64 %i1)
    
    %i2 = load i16, ptr %ptr_mem2
    %_ind2 = load i8, ptr %enI16
    %ind2 = zext i8 %_ind2 to i64    
    %p2 = call i32 @printf(ptr @.str3, i64 %ind2, i16 %i2)    
    
    %i3 = load i32, ptr %ptr_mem3
    %_ind3 = load i8, ptr %enI32
    %ind3 = zext i8 %_ind3 to i64    
    %p3 = call i32 @printf(ptr @.str4, i64 %ind3, i32 %i3)    
    
    %i4 = load double, ptr %ptr_mem4
    %_ind4 = load i8, ptr %enF64
    %ind4 = zext i8 %_ind4 to i64
    %p4 = call i32 @printf(ptr @.str5, i64 %ind4, double %i4)    
    
    %i5 = load i8, ptr %ptr_mem5
    %_ind5 = load i8, ptr %enBool
    %ind5 = zext i8 %_ind5 to i64
    %p5 = call i32 @printf(ptr @.str6, i64 %ind5, i8 %i5)    

    %_ind6 = load i8, ptr %enToken
    %ind6 = zext i8 %_ind6 to i64
    %p6 = call i32 @printf(ptr @.str7, i64 %ind6, i64 0)
        
    ret void
}

;; Add points: 
;; Point: p, p1, p2
;; add_points(p*, p1, p2) { p = p1 + p2 }
;; return to `ptr p*`
;; - `sret` attribute indicates that this is the return value
;; - `byval` attribute indicates that parametr are structs that are passed by value
define void @add_points(ptr sret %point, ptr byval %p1, ptr byval %p2) {
    ; p1.x + p2.x
    %ptr_p1x = getelementptr %Point, ptr p1, i32 0, i32 0
    %ptr_p2x = getelementptr %Point, ptr p2, i32 0, i32 0
    %ptr_px = getelementptr %Point, ptr point, i32 0, i32 0
    %1 = load i32, ptr %ptr_p1x
    %2 = load i32, ptr %ptr_p2x
    %3 = add i32 %1, %2
    ; p = p1.x + p2.x
    store i32 %3, ptr %ptr_px

    ; p1.y + p2.y
    %ptr_p1y = getelementptr %Point, ptr p1, i32 0, i32 1
    %ptr_p2y = getelementptr %Point, ptr p2, i32 0, i32 1
    %ptr_py = getelementptr %Point, ptr point, i32 0, i32 1
    %4 = load i32, ptr %ptr_p1y
    %5 = load i32, ptr %ptr_p2y
    %6 = add i32 %4, %5
    ; p = p1.y + p2.y
    store i32 %6, ptr %ptr_py
    ret void
}
