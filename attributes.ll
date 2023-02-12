@.str1 = private global [16 x i8] c"priv_func call\0A\00"
@.str2 = private global [32 x i8] c"ext_func1 call: x = %d; y = %d\0A\00"

declare i32 @printf(ptr, ...)

define external i32 @calc() {
    ret i32 2
}

;; * unnamed_addr - if the attribute is given, the address is known to not be
;; significant and two identical functions can be merged.
;; * nounwind - this function attribute indicates that the function never
;; raises an exception.
define private void @priv_func() unnamed_addr nounwind {
    call i32 (ptr, ...) @printf(ptr @.str1)
    ret void
}

define external void @ext_func1(ptr %x, ptr %y) unnamed_addr nounwind {
    %1 = load i32, ptr %x
    %2 = load i32, ptr %y
    call void @priv_func()
    call i32 (ptr, ...) @printf(ptr @.str2, i32 %1, i32 %2)

    ret void
}
