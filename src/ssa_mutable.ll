@.str1 = private global [24 x i8] c"ssa sum(%d) result: %d\0A\00"

declare i32 @printf(ptr, ...)

;; Use loop without allocation (alloca). It mean mutual values
;; without allocation.
;; Only ssa-form (registers) and phi nodes.
;; To init values without constant used trick with entry point:
;; `[0, %entry]`
define void @ssa_sum(i32 %range) {
entry:
    %eq1 = icmp sgt i32 %range, 0
    br i1 %eq1, label %loop, label %end   
    
loop:   ; for i = 0; i < range; i++
    ; x = 0; x = x + i; 
    %x = phi i32 [0, %entry], [%loop_sum_x, %loop]
    ; i = 0; And get previous "i" value
    %i = phi i32 [0, %entry], [%loop_next_i, %loop]
    ; i++
    %loop_next_i = add i32 %i, 1
    ; x += i
    %loop_sum_x = add i32 %x, %loop_next_i
    ; i < range    
    %eq_loop = icmp slt i32 %loop_next_i, %range   
    br i1 %eq_loop, label %loop, label %end
    
end:
    ; Get result from func entry point, or from loop result
    %res =  phi i32 [0, %entry], [%loop_sum_x, %loop]
    %p1 = call i32 @printf(ptr @.str1, i32 %range, i32 %res)
    ret void
}
