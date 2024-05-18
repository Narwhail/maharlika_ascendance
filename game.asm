.model small
.stack
.data
    ;strings
    ;playing state
    line1_game db "MAHARLIKA", "$"
    line2_game db "ASCENDANCE", "$"
    line3_game db "Control using", "$"
    line4_game db "'WASD'", "$"
    line5_game db "Score:" ,"$"
    ;gameover state
    line1_over db "GAME OVER", "$"
    line2_over db "Score: ", "$"
    line3_over db "Press any key to return to menu", "$"

    ;game variables
    current_tick db 00h
    y_toplimit dw 18h
    y_bottomlimit dw 098h
    y_velocity dw 0008h         ;this is used for obstacles, and tower y movement
    game_state dw 0001h         ;0 = title screen, 1 = playing, 2 = game over
    randomNum db 01h
    rngseed dw 00h
    
    ;character variables
    char_size dw 0fh
    char_x dw 0088h
    char_y dw 0098h
    char_velocity dw 0008h
    char_xfixedpos dw 01h       ;0087h, 00b7h, 00dfh, 010fh

    ;tower
    tower_x dw 0097h
    tower_x2 dw 0efh
    tower_y dw 0008h
    tower_xsize dw 1fh
    tower_ysize dw 0afh

    ;obstacle
    obstacle_xpos dw 00b7h
    obstacle_ypos dw 0008h
    obsfixedxpos_state dw 00h       ;0 = 0087h, 1 = 00b7h, 2 = 00dfh, 3 = 010fh 
    
    

.code

org 0100h

    main proc far
        mov ax, @data
        mov ds, ax

        call clear_screen

        playing_game:
            mov ah, 2ch
            int 21h


            cmp dl, current_tick
            je playing_game

            mov current_tick, dl        ;update game tick
            

            
            call update_xposition
            call clear_screen

            mov bx, tower_x
            call draw_tower

            mov bx, tower_x2
            call draw_tower

    
            call draw_obstacle
            call move_obstacle
            call draw_char
            call playinggame_printtext
            ;call playinggame_printscore
            call playinggame_input
            call check_collission

            cmp game_state, 01h         ;if game state is still playing, continue to next tick
            je playing_game             ;if true
            jmp game_over               ;else

        game_over:
            call gameover_printtext     
            call generateseed
            call gameover_input         ;check for input
    main endp

    obstaclexfixed_updateval proc near
        mov al, randomNum


        ;randomNum = 1
        cmp al, 01
        je obs1_position1
        
        ;randomNum = 2
        cmp al, 02
        je obs1_position2

        ;randomNum = 3
        cmp al, 03
        je obs1_position3

        ;randomNum = 4
        cmp al, 04
        je obs1_position4

        ret                 ;exit if none

        obs1_position1:
            mov obstacle_xpos, 0087h
            ret
        obs1_position2:
            mov obstacle_xpos, 00b7h
            ret

        obs1_position3:
            mov obstacle_xpos, 00dfh
            ret

        obs1_position4:
            mov obstacle_xpos, 010fh
            ret

        obs1_exit_xupdate:
            ret
    obstaclexfixed_updateval endp

    prng proc          ;generates a number (0 to 3)

        cmp rngseed, 0
        jne gamba

        call generateseed
        jmp gamba

        gamba:
        mov ax, rngseed
        
        xor dx, dx
        mov bx, 04h
        div bx
        inc dl

        mov randomNum, dl
        ret

    prng endp

    nurng proc
        mov ax, rngseed       ; Load the current seed into AX
        mov bx, 0A9h       ; Multiplier (a = 169)
        mul bx             ; AX = AX * BX
        add ax, 1          ; Increment (c = 1)
        mov rngseed, ax       ; Update the seed with the new value
        
        ; Now AX contains the new seed
        xor dx, dx         ; Clear DX for division
        mov bx, 5          ; Set divisor to 5
        div bx             ; Divide AX by BX, quotient in AL, remainder in DL
        inc dl
        mov randomNum, dl  ; Move the remainder (0-4) to randomNum
        ret                ; Return from procedure
    nurng endp

    generateseed proc near
        mov ah, 00h
        int 1ah
        mov rngseed, dx
        ret
    generateseed endp

    delay proc near
        mov cx, 5
        mov dx, 0e848h
        mov ah, 86h
        int 15h
        ret
    delay endp

    default_gamevalue proc near
        mov rngseed, 0
        mov randomNum, 02h              
        call obstaclexfixed_updateval
        mov char_xfixedpos, 01h
        mov char_y, 0098h
        mov obstacle_ypos, 0008h
        ret
    default_gamevalue endp 

    gameover_input proc near
        mov ah, 01h
        int 16h
        jnz gameover_keypress       ;if zero flag is false, go to _keypress        
        jmp gameover_input          ;else keep checking for input

        gameover_keypress:
            mov game_state, 01h
            call default_gamevalue
            call prng
            call obstaclexfixed_updateval
            jmp playing_game
    gameover_input endp

    gameover_printtext proc near
        call clear_screen

        mov ah, 02h
        mov bh, 00h         ;page position
        mov dh, 04h         ;y position of text -> 1 hexadecimal is equivalent to 8 pixels
        mov dl, 04h         ;x position of text -> 00h is tile one, 01h is tile two
        int 10h
        mov ah, 09h
        mov dx, offset line1_over       ;smd
        int 21h

        mov ah, 02h
        mov bh, 00h         ;page position
        mov dh, 07h         ;y position of text -> 1 hexadecimal is equivalent to 8 pixels
        mov dl, 04h         ;x position of text -> 00h is tile one, 01h is tile two
        int 10h
        mov ah, 09h
        mov dx, offset line2_over
        int 21h

        mov ah, 02h
        mov bh, 00h         ;page position
        mov dh, 09h         ;y position of text
        mov dl, 04h         ;x position of text -> 00h is tile one, 01h is tile two
        int 10h
        mov ah, 09h
        mov dx, offset line3_over
        int 21h
        ret
    gameover_printtext endp

    move_obstacle proc near
        mov ax, y_velocity  
        add obstacle_ypos, ax           ;obstacle_ypos += y_velocity

        mov ax, y_bottomlimit
        add ax, 10h                     ;add bottom limit by 16 pixels

        cmp obstacle_ypos, ax           ;compare it to bottom limit
        jl exit_moveobs                 ;if its less

        ;else
        mov obstacle_ypos, 0008h        ;reset back to top

        call nurng
        call obstaclexfixed_updateval
        ret

        exit_moveobs:
            ret
    move_obstacle endp

    check_collission proc near
        ;check if char is colliding with obstacle
        ;char_x+char_size > obstacle_xpos && char_x < obstacle_xpos+char_size 
        ;&& char_y+char_size > obstacle_ypos && char_y < obstacle_ypos+char_size 

        mov ax, char_x
        add ax, char_size
        cmp ax, obstacle_xpos
        jng exit_collission

        mov ax, obstacle_xpos
        add ax, char_size
        cmp char_x, ax
        jnl exit_collission

        mov ax, char_y
        add ax, char_size
        cmp ax, obstacle_ypos
        jng exit_collission

        mov ax, obstacle_ypos
        add ax, char_size
        cmp char_y, ax
        jnl exit_collission

        ;if collission is true
        mov game_state, 02h         ;set game state to gameover
        call delay
        ret

        ;if false
        exit_collission:
            ret

    check_collission endp

    draw_obstacle proc near

        ;single obstacle
        mov cx, obstacle_xpos     ;x position is also fixed
        mov dx, obstacle_ypos     ;y position is same as 

        drawobs:
            mov ah, 0ch     ;set config to write pixels
            mov al, 0fh     ;set pixel color to white
            mov bh, 00h     ;page number
            
            int 10h         ;execute

            inc cx
            mov ax, cx
            sub ax, obstacle_xpos
            cmp ax, char_size
            jng drawobs
            mov cx, obstacle_xpos
            inc dx
            mov ax, dx 
            sub ax, obstacle_ypos
            cmp ax, char_size
            jng drawobs
        ret
    draw_obstacle endp
    
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

    playinggame_printtext proc near
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
        ret
    playinggame_printtext endp

    playinggame_printscore proc near           ;incomplete
        
        ret
    playinggame_printscore endp
           
    playinggame_input proc near
        mov ah, 01h             ;if no key is pressed, exit playinggame_input
        int 16h
        jz exit_input

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
            mov ax, y_toplimit      ;check if character y position has reached top_limit
            cmp char_y, ax
            je exit_input           ;if true then exit

            ;else
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
            mov ax, y_bottomlimit   ;check if character y position has reached bottom_limit
            cmp char_y, ax 
            je exit_input           ;if true then exit

            ;else
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
    playinggame_input endp

    update_xposition proc near      ;this is responsible for updating the values for adding in char_x, depending on the char_xfixedpos
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