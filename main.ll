@.global.1 = global i32 10

define i32 @main() {
    ; get global var
    %1 = load i32, i32* @.global.1
    ; multiply
    %2 = mul i32 %1, 5
    ; set result to global var
    store i32 %2, i32* @.global.1
    ret i32 %2
}