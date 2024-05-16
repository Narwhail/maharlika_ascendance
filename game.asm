.model small
.stack
.data
    line1_game db "MAHARLIKA", "$"
    line2_game db "ASCENDANCE", "$"
    line3_game db "Control using", "$"
    line4_game db "'WASD'", "$"
    line5_game db "Score:" ,"$"
    current_tick db 00h
    char_size dw 0fh
    char_x dw 0088h
    char_y dw 0098h
    char_velocity dw 0008h
    char_xfixedpos dw 01h
    y_toplimit dw 18h
    y_bottomlimit dw 098h
    tower_x dw 0097h
    tower_x2 dw 0efh
    tower_y dw 0008h
    tower_xsize dw 1fh
    tower_ysize dw 0afh

.code

org 0100h

    main proc far
        mov ax, @data
        mov ds, ax

        call clear_screen

        check_tick:
            mov ah, 2ch
            int 21h

            cmp dl, current_tick
            je check_tick

            mov current_tick, dl        ;update game tick
            

            
            call update_xposition
            call clear_screen

            mov bx, tower_x
            call draw_tower

            mov bx, tower_x2
            call draw_tower

            call draw_char
            call game_printtext
            ;call game_printscore
            call game_input
            jmp check_tick
    main endp

    draw_tower proc near
        mov cx, bx
        mov dx, tower_y     ;y position

        tower_loop:         ;enter tileset here
            mov ah, 0ch     ;set config to write pixels
            mov al, 0fh     ;set pixel color to white
            mov bh, 00h     ;page number
            int 10h         ;execute

            inc cx
            mov ax, cx
            sub ax, bx
            cmp ax, tower_xsize
            jng tower_loop
            mov cx, bx
            inc dx
            mov ax, dx 
            sub ax, tower_y
            cmp ax, tower_ysize
            jng tower_loop
        ret
    draw_tower endp

    game_printtext proc near
        mov ah, 02h
        mov bh, 00h         ;page position
        mov dh, 04h         ;y position of text -> 1 hexadecimal is equivalent to 8 pixels
        mov dl, 02h         ;x position of text -> 00h is tile one, 01h is tile two
        int 10h
        mov ah, 09h
        mov dx, offset line1_game       ;maharlika
        int 21h

        mov ah, 02h
        mov bh, 00h
        mov dh, 05h
        mov dl, 02h
        int 10h
        mov ah, 09h
        mov dx, offset line2_game       ;ascendance
        int 21h

        mov ah, 02h
        mov bh, 00h
        mov dh, 09h
        mov dl, 02h
        int 10h
        mov ah, 09h
        mov dx, offset line3_game       ;control using
        int 21h

        mov ah, 02h
        mov bh, 00h
        mov dh, 0bh
        mov dl, 05h
        int 10h
        mov ah, 09h
        mov dx, offset line4_game       ;wasd
        int 21h

        mov ah, 02h
        mov bh, 00h
        mov dh, 0eh
        mov dl, 02h
        int 10h
        mov ah, 09h
        mov dx, offset line5_game       ;score
        int 21h
    game_printtext endp

    game_printscore proc near
        
        ret
    game_printscore endp

    draw_char proc near
        mov cx, char_x     ;x position
        mov dx, char_y     ;y position

        drawchar_horizontal:
            mov ah, 0ch     ;set config to write pixels
            mov al, 31h     ;set pixel color to green
            mov bh, 00h     ;page number
            
            int 10h         ;execute

            inc cx
            mov ax, cx
            sub ax, char_x
            cmp ax, char_size
            jng drawchar_horizontal
            mov cx, char_x
            inc dx
            mov ax, dx 
            sub ax, char_y
            cmp ax, char_size
            jng drawchar_horizontal
        ret
    draw_char endp
        
    game_input proc near
        mov ah, 00h
        int 16h

        ;check if player presses 'w' or 'W'
        cmp al, 57h ;'W'
        je w_pressed
        cmp al, 77h ;'w'
        je w_pressed
        
        ;check if player presses 'a' or 'A'
        cmp al, 41h ;'A'
        je a_pressed
        cmp al, 61h ;'a'
        je a_pressed
        
        ;check if player presses 'd' or 'D'
        cmp al, 44h ;'D'
        je d_pressed
        cmp al, 64h ;'d'
        je d_pressed

        ;check if player presses 's' or 'S'
        cmp al, 53h ;'S'
        je s_pressed
        cmp al, 73h ;'s'
        je s_pressed

        ;exit if no input
        jmp exit_input

        w_pressed:
            mov ax, y_toplimit
            cmp char_y, ax
            je exit_input

            mov ax, char_velocity
            sub char_y, ax
            jmp exit_input

        a_pressed:
            mov ax, char_xfixedpos
            cmp ax, 01h
            je exit_input           ;exit if xfixedpos is already at 1

            ;else
            dec char_xfixedpos
            jmp exit_input

        s_pressed:
            mov ax, y_bottomlimit
            cmp char_y, ax 
            je exit_input

            mov ax, char_velocity
            add char_y, ax
            jmp exit_input

        d_pressed:
            mov ax, char_xfixedpos
            cmp ax, 04h
            je exit_input           ;exit if xfixedpos is already at 4
        
            ;else
            inc char_xfixedpos
            jmp exit_input
        exit_input:
            ret
    game_input endp

    update_xposition proc near
        mov ax, char_xfixedpos

        ;check if 1
        cmp ax, 01h
        je position1
        
        ;check if 2
        cmp ax, 02h
        je position2

        ;check if 3
        cmp ax, 03h
        je position3

        ;check if 4
        cmp ax, 04h
        je position4

        position1:
            mov char_x, 0087h
            jmp exit_xupdate

        position2:
            mov char_x, 00b7h
            jmp exit_xupdate

        position3:
            mov char_x, 00dfh
            jmp exit_xupdate

        position4:
            mov char_x, 010fh
            jmp exit_xupdate

        exit_xupdate:
            ret
    update_xposition endp

    clear_screen proc near
        mov ah, 00h         ;config to video mode
        mov al, 13h         ;set to video mode 320x300
        int 10h             ;execute

        mov ah, 0bh
        mov bh, 00h
        mov bl, 00h
        int 10h
        ret
    clear_screen endp
end main