.model small
.stack 100h
.data
    outputMsg db "Random Number between (0-3): $"
    randomNum db 0
.code
main proc far

    mov ax, @data
    mov ds, ax

    reloop:
        call rng

        mov ah, 09h
        mov dx, offset outputMsg
        int 21h

        mov ah, 02h
        mov dl, randomNum
        add dl, '0'
        int 21h

        mov ah, 4ch
        int 21h
main endp

rng proc near
    mov ah, 00h
    int 1ah

    mov ax, dx
    mov dx, 00h
    mov bx, 05h
    div bx

    mov randomNum, dl
    ret
rng endp

end main