;resolve illegal read from delay
;resolve illegal write from delay

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
    y_bottomlimit dw 0098h
    y_velocity dw 4             ;this is used for obstacles, and tower y movement
    game_state dw 0001h         ;0 = menu screen, 1 = playing, 2 = game over, 3 = tutorial
    randomNum db 01h
    rngseed dw 00h
    score_ones db 0
    score_tens db 0
    score_hund db 0
    score_rate db 1
    difficulty db 0             ;0 = easy, 1 = intermediate, 2 = hard

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
    obs_xpos dw 00b7h, 00b7h, 00b7h, 00b7h, 00b7h       ;address is by 2 ie. 0,2,4,6,8
    obs_ypos dw 24, 56, 88, 120, 152                    ;address is by 2 ie. 0,2,4,6,8
    obsfixedxpos_state dw 00h                           ;0 = 0087h, 1 = 00b7h, 2 = 00dfh, 3 = 010fh 
    obs_isactive db 1, 0, 0, 0, 0                       ;0 = inactive, 1 = active
.code

org 0100h
    main proc far
        mov ax, @data
        mov ds, ax

        call generateseed
        call default_gamevalue
        call clear_screen

        check_state:
            cmp game_state, 0
            je menu_screen

            cmp game_state, 1
            je playing_game
            
            cmp game_state, 2
            je game_over

            cmp game_state, 3
            je tutorial_screen

        menu_screen:

        playing_game:
            mov ah, 2ch
            int 21h

            cmp dl, current_tick
            je playing_game

            mov current_tick, dl        ;update game tick
            
            call clear_screen

            mov bx, tower_x
            call draw_tower

            mov bx, tower_x2
            call draw_tower

    
            call draw_obstacle
            call move_obstacle
            call update_difficulty
            call check_collission

            call draw_char
            call playinggame_printtext
            call playinggame_input

            call check_state

        game_over:
            call delay                  ;illegal read and write error in dosbox status window
            call clear_screen
            call gameover_printtext
            call generateseed
            call gameover_input         ;check for input

        tutorial_screen:
    main endp

    update_difficulty proc near 
        mov si, 0
        cmp score_tens, 1
        je begin
        jmp exit_updatedif

        begin:
            mov cx, 5                   ; Loop counter for 5 iterations
            mov y_velocity, 8
            
        update_loop:
            cmp obs_ypos[si], 8         ; Compare obs_ypos[si] with 8
            jne skip_update
            mov obs_isactive[si], 1     ; Set obs_isactive[si] to 1

        skip_update:
            add si, 2                   ; Move to the next pair of positions (si+2)
            loop update_loop            ; Loop until CX decrements to 0

        exit_updatedif:
            ret
    update_difficulty endp

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

        ret                 ;exit if none, will retain previous x position

        obs1_position1:
            mov obs_xpos[si], 0087h
            ret

        obs1_position2:
            mov obs_xpos[si], 00b7h
            ret

        obs1_position3:
            mov obs_xpos[si], 00dfh
            ret

        obs1_position4:
            mov obs_xpos[si], 010fh
            ret

        obs1_exit_xupdate:
            ret
    obstaclexfixed_updateval endp

    prng proc

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
        mov bx, 0A9h
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
        mov ah, 00h                 ;get system time
        int 1ah
        mov rngseed, dx
        ret
    generateseed endp

    delay proc near
        mov ah, 86h
        mov cx, 07
        mov dx, 0e848h
        int 15h
        ret
    delay endp

    default_gamevalue proc near
        mov si, 0
        mov obs_ypos[si+0], 24
        mov obs_ypos[si+2], 56
        mov obs_ypos[si+4], 88
        mov obs_ypos[si+6], 120
        mov obs_ypos[si+8], 152
        mov obs_isactive[si+0], 1
        mov obs_isactive[si+2], 0
        mov obs_isactive[si+4], 0
        mov obs_isactive[si+6], 0
        mov obs_isactive[si+8], 0
        mov rngseed, 0
        mov randomNum, 02h              
        call obstaclexfixed_updateval
        mov char_xfixedpos, 01h
        mov char_y, 0098h
        mov score_ones, 0
        mov score_hund, 0
        mov score_tens, 0
        mov y_velocity, 4
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
        mov dh, 07h
        mov dl, 04h
        call _printscore

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

        mov ah, 02h
        mov dh, 0eh
        mov dl, 02h
        call _printscore
        ret
    playinggame_printtext endp

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
                jmp exit_update

            position2:
                mov char_x, 00b7h
                jmp exit_update

            position3:
                mov char_x, 00dfh
                jmp exit_update

            position4:
                mov char_x, 010fh
                jmp exit_update

            exit_update:
                ret
            
    playinggame_input endp

    check_collission proc near
        ;check if char is colliding with obstacle
        ;char_x+char_size > obstacle_xpos && char_x < obstacle_xpos+char_size 
        ;&& char_y+char_size > obstacle_ypos && char_y < obstacle_ypos+char_size 
        mov cx, 5
        mov si, 0

        collissionloop:
            cmp obs_isactive[si], 0
            je exit_collission
            
            mov ax, char_x
            add ax, char_size
            cmp ax, obs_xpos[si]
            jng exit_collission

            mov ax, obs_xpos[si]
            add ax, char_size
            cmp char_x, ax
            jnl exit_collission

            mov ax, char_y
            add ax, char_size
            cmp ax, obs_ypos[si]
            jng exit_collission

            mov ax, obs_ypos[si]
            add ax, char_size
            cmp char_y, ax
            jnl exit_collission

            ;if collission is true
            mov game_state, 2         ;set game state to gameover
        ret

        ;if false
        exit_collission:
            add si, 2
            loop collissionloop
            ret
    check_collission endp

    move_obstacle proc near
        ;array addresses: 0, 2, 4, 6, 8
        mov si, 0                                   ;obs_xpos[0]
        mov cx, 5                                   ;set loop to 5

        loophere:
            mov ax, y_velocity
            add obs_ypos[si], ax                    ;obs_ypos[si] += y_velocity

            mov ax, y_bottomlimit
            add ax, 12
            cmp obs_ypos[si], ax                    ;compare obx_ypos[si] to bottom limit
            jg returntop_obstacle                   ;if obs_ypos[si] < y_bottomlimit is true                    

            add si, 2
            loop loophere                           ;loop until cx is 0
            ret

        returntop_obstacle:
            call nurng
            call obstaclexfixed_updateval
            call increment_score

            mov ax, 0008h
            mov obs_ypos[si], ax                    ;mov obx_ypos[si] back to top

            add si, 2
            loop loophere                           ;loop until cx is 0
            ret
    move_obstacle endp

    draw_obstacle proc near
        mov cx, 5                       ;set loop to 5
        mov si, 0

        loopa:
            push cx

            cmp obs_isactive[si], 0         ;if obs_isactive is 0, then don't draw and continue to check next element in array
            je increment_si

            mov cx, obs_xpos[si]            ;x coord
            mov dx, obs_ypos[si]            ;y coord

            

            drawobs_horizontal:
                mov ah, 0ch                 ;set config to write pixel

                cmp si, 0                                   ;ONLY USED FOR TESTING
                je redcolor                                 ;ONLY USED FOR TESTING
                mov al, 0fh                 ;set white as color

                contin:                                     ;ONLY USED FOR TESTING
                    mov bh, 00h                 ;page number
                    int 10h

                    inc cx
                    mov ax, cx
                    sub ax, obs_xpos[si]
                    cmp ax, char_size
                    jng drawobs_horizontal
                    mov cx, obs_xpos[si]
                    inc dx

                    mov ax, dx
                    sub ax, obs_ypos[si]
                    cmp ax, char_size
                    jng drawobs_horizontal

            increment_si:
                add si, 2
                pop cx
                loop loopa
                ret

            redcolor:                                   ;ONLY USED FOR TESTING
                mov al, 28h                             ;ONLY USED FOR TESTING
                jmp contin                              ;ONLY USED FOR TESTING
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

    increment_score proc near
        inc score_ones
    	cmp score_ones, 10
   	    jl exit_increment

    	mov score_ones, 0
    	inc score_tens
    	cmp score_tens, 10
    	jl exit_increment

    	mov score_tens, 0
    	inc score_hund
    	cmp score_hund, 10
    	jl exit_increment

    	mov score_hund, 0
    
    	exit_increment:
        ret
    increment_score endp

    _printscore proc near    ;dl - x position
        ; the string 'Score: ' occupies 7 squares incl. whitespace
        add dl, 7       ;set x pos 7 squares apart from previous' text initial letter
        int 10h

        ; Print hundreds digit
    	push dx
        mov dl, score_hund
    	add dl, '0'
    	int 21h
        pop dx

    	inc dl              ; move to next square
   	    int 10h
        
        ; print tens digit
    	push dx
        mov dl, score_tens
    	add dl, '0'
    	int 21h
        pop dx

    	inc dl              ; move to next position
    	int 10h

        ; Print ones digit
    	push dx
        mov dl, score_ones
    	add dl, '0'
    	int 21h
        pop dx

        ret
    _printscore endp

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