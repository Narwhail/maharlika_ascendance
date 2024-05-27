;resolve illegal read from delay
;resolve illegal write from delay
;occasionaly freezes when playing, can be resolved by pressing keyboard
;sprites must be incremented by 1 to properly print
;menu input requires 2 keypresses

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
    blank_game db "   " ,"$"
    ;gameover state
    line1_over db "GAME OVER", "$"
    line2_over db "Score: ", "$"
    line3_over db "Press any key to return to menu", "$"
    ;menu state
    line1_menu db "MAHARLIKA ASCENDANCE", "$"
    line3_menu db "Press 'S' to Start", "$"
    line4_menu db "Press 'T' for Tutorial", "$"

    ;game variables
    current_tick db 00h
    y_toplimit dw 18h
    y_bottomlimit dw 0098h
    y_velocity dw 8             ;this is used for obstacles, and tower y movement
    game_state dw 0         ;0 = menu screen, 1 = playing, 2 = game over, 3 = tutorial
    randomNum db 01h
    rngseed dw 00h
    score_ones db 0
    score_tens db 0
    score_hund db 0
    score_rate db 1
    rendercoordX dw 0
    rendercoordY dw 0
    _rendersizeX dw 0
    _rendersizeY dw 0
    prevtime db 0
    allowscore db 0             ;0 = inactive, 1 = active
    delaytime db 0
    tempmsecond db 0
    ; variables ni mhiema
    tutorial_page db 1

    ; variables ni mhiema



    ;character variables
    char_size dw 0fh
    char_x dw 0087h
    char_y dw 0098h
    char_velocity dw 0008h
    char_xfixedpos dw 1       ;0087h, 00b7h, 00dfh, 010fh

    ;enemy variables
    enemy_x dw 202
    enemy_y dw 9
    enemy_state db 0           ;0 = inactive, 1 = descending, 2 = activating, 3 = ascending
    icicle_state db 0          ;0 = inactive, 1 = tracking, 2 = active  (will automatically turn inactive once it reaches the bottom limit)
    iciclex dw ?
    icicley dw 8
    icicle_velocity dw 5

    ;tower
    menutowerx dw 215
    menutowery_seg1 dw 103, 135, 167
    menutowery_seg2 dw 119, 151, 183
    menutowerchesty dw 79
    towery dw 17, 33, 49, 65, 81, 97, 113, 129, 145, 162, 178
    towerx dw 151

    ;obstacle
    obstaclex dw 183, 183, 183, 183, 183
    obs_xpos dw 183, 183, 183, 183, 183                 ;address is by 2 ie. 0,2,4,6,8
    obs_ypos dw 23, 55, 87, 119, 151                    ;address is by 2 ie. 0,2,4,6,8
    obsfixedxpos_state dw 0                             ;0 = 0087h, 1 = 00b7h, 2 = 00dfh, 3 = 010fh 
    obs_isactive dw 1, 0, 0, 0, 0                       ;0 = inactive, 1 = active
    .obs_activetemp dw 0, 0, 0, 0, 0
    difficulty db 0                                     ;0 = easy, 1 = medium, 2 = hard

    ;sprites
    icicle  db 36h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 00h    ;10x15
            db 36h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 00h
            db 00h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 00h, 00h
            db 00h, 36h, 36h, 36h, 36h, 36h, 36h, 36h, 00h, 00h
            db 00h, 00h, 36h, 36h, 36h, 36h, 36h, 00h, 00h, 00h
            db 00h, 00h, 36h, 36h, 36h, 36h, 36h, 00h, 00h, 00h
            db 00h, 00h, 36h, 36h, 36h, 36h, 36h, 00h, 00h, 00h
            db 00h, 00h, 36h, 36h, 36h, 36h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 36h, 36h, 36h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 36h, 36h, 36h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 36h, 36h, 00h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 00h, 36h, 00h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 00h, 36h, 00h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
    
    Player_left     db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h   ;17x17
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h
                    db 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 00h, 00h, 00h
                    db 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 00h, 00h, 00h
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 00h, 2Fh, 00h, 00h, 2Fh, 00h
                    db 00h, 2Fh, 00h, 2Fh, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 00h
                    db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 00h
                    db 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 00h
                    db 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h, 00h
                    db 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h
                    db 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 00h, 00h, 00h
                    db 00h, 00h, 2Fh, 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h
                    db 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h
                    db 00h, 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h
                    db 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 00h
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h


    Player_right    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h   ;17x17
                    db 00h, 00h, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    db 00h, 00h, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h
                    db 00h, 00h, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h
                    db 2Fh, 00h, 00h, 2Fh, 00h, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    db 2Fh, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 2Fh, 00h, 2Fh, 00h, 00h
                    db 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h
                    db 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 00h, 00h
                    db 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h
                    db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h
                    db 00h, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h
                    db 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h, 2Fh, 00h, 00h, 00h
                    db 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h
                    db 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h
                    db 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

                        ;                       5                       10                       15                       20                       25                       30                       35                       40                       45                       50                      55
    menutower_topchest  db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h      ;57x24
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2ah, 2ah, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 2ah, 2ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2ah, 2ah, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 2ah, 2ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2ah, 2ah, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 2ah, 2ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2ah, 2ah, 06h, 06h, 0bah, 0bah, 0bah, 0bah, 06h, 06h, 2ah, 2ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 2ah, 2ah, 0bah, 0bah, 2ah, 2ah, 2ah, 2ah, 0bah, 0bah, 2ah, 2ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 5ch, 5ch, 5ch, 2ah, 0bah, 0bah, 2ah, 5ch, 5ch, 5ch, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 2ah, 06h, 06h, 2ah, 0bah, 0bah, 2ah, 06h, 06h, 2ah, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 06h, 06h, 2ah, 2ah, 2ah, 2ah, 06h, 06h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h,  00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh , 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

                        ;                       5                       10                       15                       20                       25                       30                       35                       40                       45                       50                      55
    menutower_seg1      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h     ;57x17
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h      
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h      
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

                        ;                       5                       10                       15                       20                       25                       30                       35                       40                       45                       50                      55
    menutower_seg2      db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h     ;57x17
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h
                        db 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h, 00h, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 0fh, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    enemy   db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h  ;17x17
            db 00h, 20h, 00h, 00h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 00h 
            db 20h, 20h, 20h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h, 00h, 00h 
            db 00h, 00h, 20h, 00h, 20h, 00h, 00h, 00h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 20h, 00h, 20h, 00h, 00h, 00h, 20h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 20h, 00h, 20h, 00h, 00h, 00h, 20h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 00h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 00h, 20h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 00h, 00h, 20h, 20h, 00h, 00h, 00h, 00h, 20h, 20h, 20h, 00h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 00h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 20h, 20h, 20h, 20h, 00h, 20h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 00h, 00h, 00h, 00h, 20h, 00h, 20h, 20h, 00h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 20h, 20h, 20h, 20h, 20h, 00h, 20h, 20h, 20h, 00h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 00h, 20h, 00h, 20h, 00h, 00h, 00h, 20h, 20h, 20h, 00h, 00h 
            db 00h, 20h, 00h, 20h, 00h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 20h, 20h, 20h, 00h 
            db 00h, 00h, 20h, 00h, 20h, 20h, 00h, 20h, 20h, 20h, 20h, 20h, 20h, 00h, 20h, 20h, 00h
            db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            
    ingame_towerseg1    dB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h  ;33x17
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    ingame_towerseg2    DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    ingame_towerseg3    DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                        DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
    
    obstacle_left   DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h     ;18x17
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    obstacle_right  DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h     ;18x17
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h
                    DB 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 00h, 00h
                    DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
.code

org 0100h
    main proc far
        mov ax, @data
        mov ds, ax

        call generateseed
        call default_gamevalue
        call clear_screen

        mov ah, 2ch
        int 21h
        mov prevtime, dh

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
            call clear_screen
            call menuscreen_printtext
            call render_menutower
            call menu_input
            mov enemy_state, 1
            
            call check_state
        playing_game:
            call check_tick
            call update_difficulty
            call clear_screen
            call playinggame_input
            call move_tower
            call move_obstacle
            call move_enemy
            call move_icicle
            call playinggame_printtext
            call render_gametower
            call render_char
            call render_obstacle
            call render_icicle
            call render_enemy
            call check_collission
            
            call check_state
        game_over:
            call _delay
            call clear_screen
            call gameover_printtext
            call generateseed
            call gameover_input         ;check for input

            call check_state
        tutorial_screen:
            call clear_screen
            call tutorial_printscreen         ; hanapin mo yung function nito tapos dun ka magdagdag ng code m mhiema, yung **** proc near
            call tutorial_input               ; same din dito
            call check_state
    main endp

    ; ==================================== dito k magcode mhiema ====================================
    ; i-set mo yung game state to tutorial sa .code pra rekta tutorial screen na kada simula ng run

    ; syntax ng _rendersprite
    ;mov si, offset player           ;pangalan nung sprite
    ;mov rendercoordX, 0             ;x coord               upperleft corner position simula ng render sa coord xy
    ;mov rendercoordY, 0             ;y coord
    ;mov _rendersizeX, 16            ;x size                kopyahin lang ung nsa comment sa .code sa mga sprite
    ;mov _rendersizeY, 16            ;y size
    ;call _rendersprite
    tutorial_printscreen proc near              ; prints the text and sprites need at a given page
        ; tuloy m to
        cmp tutorial_page, 1
        je page1

        cmp tutorial_page, 2
        je page2

        page1:
            ret

        page2:
            ret
    tutorial_printscreen endp


    ; sa input, dapat
    ;       a or A ==> dec tutorial_page
    ;       d or D ==> inc tutorial_page
    ;       e or E ==> game_state to 0
    ; di dapat bumaba ng 1 hanggang s dami ng pages n binigay ko
    ; yung tutorial_page
    tutorial_input proc near                    ; handles input for navigation
        mov ah, 00h             ; set mode to read input
        int 16h                 ; execute mode

        cmp al, 'a'             ; compare with 'a'
        je a_keyinput           ; if equal, jump to a_keyinput
        cmp al, 'A'             ; compare with 'A'
        je a_keyinput           ; if equal, jump to a_keyinput

        ;tuloy mo dito




        jmp tutorial_input          ; if no keys are pressed, jmp to tutorial_input again to check

        a_keyinput:
            ret
        d_keyinput:
            ret
        e_keyinput:
            ret
    tutorial_input endp
    ; ==================================== dito k magcode mhiema ====================================

    menu_input proc near
        mov ah, 00h
        int 16h                 ; get the pressed key
        cmp al, 's'             ; compare with 's'
        je menu_skeyinput    ; if equal, jump to keypress_detected
        cmp al, 'S'             ; compare with 'S'
        je menu_skeyinput    ; if equal, jump to keypress_detected

        cmp al, 't'
        je menu_tkeyinput
        cmp al, 'T'
        je menu_tkeyinput

        jmp menu_input          ; if no keys pressed, keep jumping to menu_input

        menu_skeyinput:
            mov game_state, 1       ; set game_state to 01h
            ret

        menu_tkeyinput:
            mov game_state, 3       ;set game_state to tutorial
            ret
    menu_input endp

    menuscreen_printtext proc near
        ; Display the first line at row 4, column 5
        mov ah, 02h     
        mov bh, 00h     
        mov dh, 04h    
        mov dl, 04h     
        int 10h         

        mov ah, 09h     
        mov dx, offset line1_menu
        int 21h         

        ; Display the third line at row 7, column 5
        mov ah, 02h     
        mov dh, 07h    
        mov dl, 04h     
        int 10h         

        mov ah, 09h     
        mov dx, offset line3_menu
        int 21h   

        ; Display the fourth line at row 9, column 5
        mov ah, 02h     
        mov dh, 09h     
        mov dl, 04h     
        int 10h         
        mov ah, 09h     
        mov dx, offset line4_menu 
        int 21h    

        ret   
    menuscreen_printtext endp

    render_menutower proc near
        mov si, offset menutower_topchest
        mov ax, menutowerx
        mov rendercoordX, ax
        mov ax, menutowerchesty
        mov rendercoordY, ax
        mov _rendersizeX, 57
        mov _rendersizeY, 24
        call _rendersprite

        mov si, offset menutower_seg1
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 103
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite

        mov si, offset menutower_seg2
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 119
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite

        mov si, offset menutower_seg1
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 135
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite

        mov si, offset menutower_seg2
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 151
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite

        mov si, offset menutower_seg1
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 167
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite

        mov si, offset menutower_seg2
        mov ax, menutowerx
        mov rendercoordX, ax
        mov rendercoordY, 183
        mov _rendersizeX, 57
        mov _rendersizeY, 17
        call _rendersprite
        xor si, si
        ret
    render_menutower endp

    render_icicle proc near
        cmp icicle_state, 1         ; tracking state
        je icicle_trackingrender

        cmp icicle_state, 2         ; active
        je icicle_activerender

        jmp exit_rendericicle
        icicle_trackingrender:
            mov ah, 2ch
            int 21h

            xor ax, ax
            mov al, dl      ;dl contains milliseconds
            mov bl, 2       ;divisor, interval = 2 milliseconds
            div bl          ;divide current milliseconds to bl

            cmp ah, 0       ;compare modulo
            jne icicle_activerender
            ret

        icicle_activerender:
            push si
            mov si, offset icicle           ;tileset array, will refer for color to print
            mov ax, iciclex
            mov rendercoordX, ax             ;x coord
            mov ax, icicley
            mov rendercoordY, ax             ;y coord
            mov _rendersizeX, 10            ;x size
            mov _rendersizeY, 15            ;y size
            call _rendersprite
            pop si
            jmp exit_rendericicle

        exit_rendericicle:  ret
    render_icicle endp

    move_icicle proc near
        cmp icicle_state, 1         ; if icicle_state = 1(activating), copy char_x+3 to iciclex.
        je icicle_tracking

        cmp icicle_state, 2         ; if icicle_state = 2(active), add icicley to icicle_velocity. Once icicley reaches
        je icicle_active            ; y_bottomlimit+16, reset icicley position and change state to 0 (inactive)

        jmp exit_moveicicle

        icicle_tracking:                ; will track the player's x position, once enemy_state is 2 (active), icicle_state = 1(tracking)
            mov ax, char_x
            add ax, 4                   ;add 4 to charx
            mov iciclex, ax         

            cmp enemy_state, 2
            je exit_moveicicle          ;if enemy is in active state, continue to track playerx position

            ;else
            mov icicle_state, 2         ;else set icicle_state = 2(active), for next call
            jmp exit_moveicicle
            
        icicle_active:
            mov ax, icicle_velocity
            add icicley, ax             ;icicley += icicle_velocity

            mov ax, y_bottomlimit
            add ax, 16
            cmp icicley, ax
            jle exit_moveicicle         ;if(icicley <= y_bottomlimit+16), exit

            ;else
            mov icicle_state, 0
            mov icicley, 8
            jmp exit_moveicicle
        exit_moveicicle:    ret
    move_icicle endp

    move_tower proc 
        push si
        mov si, offset towery                        ;obs_xpos[0]
        mov cx, 11                                   ;set loop to 11

        loop_movetower:
            mov ax, y_velocity
            add [si], ax                    ;obs_ypos[si] += y_velocity

            mov ax, y_bottomlimit
            add ax, 32                          ;change this to 32 or 12
            cmp [si], ax                        ;compare obx_ypos[si] to bottom limit
            jg returntop_tower                  ;if obs_ypos[si] < y_bottomlimit is true                    

            add si, 2
            loop loop_movetower                           ;loop until cx is 0
            pop si
            ret

        returntop_tower:
            mov ax, 9
            mov [si], ax                                    ;mov obx_ypos[si] back to top
            add si, 2
            loop loop_movetower                             ;loop until cx is 0
            pop si
            ret
    move_tower endp

    render_gametower proc near
        mov cx, 1
        mov towerx, 151

        tower_segment1:
            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+0]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg1
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+6]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg1
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+12]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg1
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+18]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg1
            call _rendersprite

        tower_segment2:
            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+2]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg2
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+8]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg2
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+14]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg2
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+20]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg2
            call _rendersprite

        tower_segment3:
            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+4]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg3
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+10]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg3
            call _rendersprite

            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax           ;x coord
            mov ax, [si+16]
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 33            ;x size
            mov _rendersizeY, 16            ;y size
            mov si, offset ingame_towerseg3
            call _rendersprite

            cmp towerx, 239
            je exit_rendertower
            mov towerx, 239
            jmp tower_segment1

        exit_rendertower:
            mov si, 0
            ret
    render_gametower endp

    check_tick proc near
        mov ah, 2ch
        int 21h

        cmp dl, current_tick
        jne changetick
        jmp check_state

        changetick:
            mov current_tick, dl        ;update game tick
            cmp prevtime, dh
            je exit_checktick

            mov prevtime, dh
            call increment_score

        exit_checktick:
            ret
    check_tick endp

    render_enemy proc near
        cmp enemy_state, 0
        je exit_drawenemy

        mov si, offset enemy           ;tileset array, will refer for color to print
        mov ax, enemy_x
        mov rendercoordX, ax             ;x coord
        mov ax, enemy_y
        mov rendercoordY, ax             ;y coord
        mov _rendersizeX, 17            ;x size
        mov _rendersizeY, 17            ;y size
        call _rendersprite

        cmp enemy_state, 2              
        jne exit_drawenemy              ;if enemy is active continue to next line,
                                        ;else jump to exit_drawenemy
        ; if(enemy_state == 2 && tempmsecond == dh)
        mov ah, 2ch
        int 21h
        cmp tempmsecond, dh              
        jne exclamation                 

        ; transition to enemy_state = 3
        mov enemy_state, 3

        exclamation:
            mov ah, 02h     
            mov bh, 0     
            mov dh, 2              ;y pos
            mov dl, 26             ;x pos
            int 10h 

            mov ah, 0Eh             ;config for writing text with color
            mov al, '!'
            mov bh, 0
            mov bl, 20h             ;color of text
            int 10h

            mov ah, 2ch
            int 21h

            xor ax, ax
            mov al, dl      ;dl contains milliseconds
            mov bl, 2       ;divisor, interval = 2 milliseconds
            div bl          ;divide current milliseconds to bl

            cmp ah, 0       ;compare modulo
            je draw_exclamation
            ret

            draw_exclamation:
                mov ah, 02h     
                mov bh, 0     
                mov dh, 2              ;y pos
                mov dl, 26             ;x pos
                int 10h 

                mov ah, 0Eh             ;config for writing text with color
                mov al, ' '
                mov bh, 0
                mov bl, 20h             ;color of text
                int 10h
                jmp exit_drawenemy


        exit_drawenemy:
            ret
    render_enemy endp

    move_enemy proc near
        cmp enemy_state, 1          ;if descending state
        je descending
        
        cmp enemy_state, 3          ;if ascending state
        je ascending

        ret

        ascending:
            cmp enemy_y, 8
            jle exit_ascending
            dec enemy_y
            ret

        exit_ascending:
            mov enemy_state, 0      ;set enemy state to inactive      
            ret

        descending:
            cmp enemy_y, 31
            jge exit_descending
            inc enemy_y
            ret

        exit_descending:
            mov enemy_state, 2      ;set enemy state to active
            mov icicle_state, 1     ;set icicle_state to tracking
            mov ah, 2ch
            int 21h

            mov tempmsecond, dh
            add tempmsecond, 2      ;add 2 seconds to temporary time
            cmp tempmsecond, 59
            jg adjust_tempmsecond
            ret

            adjust_tempmsecond:
                sub tempmsecond, 60
                ret
    move_enemy endp

    update_difficulty proc near         ;to be optimized
        mov si, 0 
        ;score conditions for difficulties
        ;easy difficulty (score < 20)
        cmp score_tens, 2
        jl easydiff

        ;medium difficulty (20 <= score < 50)
        cmp score_tens, 5
        jl mediumdiff

        ;hard difficulty (score >= 50)
        cmp score_tens, 9
        jle harddiff              ; if score >= *8*, exit

        jmp exit_updatediff                    
        ;score conditions for difficulties

        easydiff:
            mov difficulty, 0
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 0
            mov .obs_activetemp[si+4], 0
            mov .obs_activetemp[si+6], 0
            mov .obs_activetemp[si+8], 0
            jmp beginupdate

        mediumdiff:
            mov difficulty, 1
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 0
            mov .obs_activetemp[si+4], 1
            mov .obs_activetemp[si+6], 0
            mov .obs_activetemp[si+8], 1
            jmp beginupdate

        harddiff:
            mov difficulty, 2
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 1
            mov .obs_activetemp[si+4], 1
            mov .obs_activetemp[si+6], 1
            mov .obs_activetemp[si+8], 1
            jmp beginupdate

        beginupdate:
            mov cx, 5                   ; Loop counter for 5 iterations
            
        updateactive:
            cmp obs_ypos[si], 7         ; Compare obs_ypos[si] with 8
            jne skip_update
            mov ax, .obs_activetemp[si]
            mov obs_isactive[si], ax    ; Set obs_isactive[si] to .obs_activetemp[si]

        skip_update:
            add si, 2                    ; Move to the next pair of positions (si+2)
            loop updateactive            ; Loop until CX decrements to 0

        exit_updatediff:
            cmp enemy_state, 0
            je update_enemy
            ret

        ;--------------->UPDATING ENEMY DIFFICULTY<------------------
        update_enemy:
            cmp score_ones, 0
            jne not_equal
            cmp icicle_state, 0
            jne not_equal
            mov enemy_state, 1
            ret

        not_equal:
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
            mov obs_xpos[si], 135
            ret

        obs1_position2:
            mov obs_xpos[si], 182
            ret

        obs1_position3:
            mov obs_xpos[si], 223
            ret

        obs1_position4:
            mov obs_xpos[si], 270
            ret

        obs1_exit_xupdate:
            ret
    obstaclexfixed_updateval endp

    nurng proc      ;to be optimized
        ;IMPORTANT FOR RNG
        mov ax, rngseed
        mov bx, 0A9h
        mul bx                ; rngseed * 169 
        add ax, 1             ; increment rngseed
        mov rngseed, ax       
        ;IMPORTANT FOR RNG

        xor dx, dx         
        mov bx, 5          ; 1/5 chance for new num, 2/5 chance for retaining previous num
        div bx             ; divide AX by BX, quotient in AL, remainder in DL
        inc dl
        mov randomNum, dl
        ret
    nurng endp

    generateseed proc near
        mov ah, 00h                 ;get system time
        int 1ah
        mov rngseed, dx
        ret
    generateseed endp

    ;syntax ie.
    ;mov delaytime, 5
    _delay proc near
        mov al, 0
        mov ah, 86h
        mov cx, 6
        mov dx, 2
        int 15h
        ret
    _delay endp

    default_gamevalue proc near
        mov icicley, 8
        mov icicle_state, 0
        mov si, 0
        ;tower sprite
        mov towery[si+0], 17
        mov towery[si+2], 33
        mov towery[si+4], 49
        mov towery[si+6], 65
        mov towery[si+8], 81
        mov towery[si+10], 97
        mov towery[si+12], 113
        mov towery[si+14], 129
        mov towery[si+16], 145
        mov towery[si+18], 162
        mov towery[si+20], 178

        ;enemy
        mov enemy_state, 0
        mov enemy_y, 8

        mov si, 0
        ;obstacle
        mov obs_ypos[si+0], 23
        mov obs_ypos[si+2], 55
        mov obs_ypos[si+4], 87
        mov obs_ypos[si+6], 119
        mov obs_ypos[si+8], 151
        mov obs_isactive[si+0], 1
        mov obs_isactive[si+2], 0
        mov obs_isactive[si+4], 0
        mov obs_isactive[si+6], 0
        mov obs_isactive[si+8], 0

        mov randomNum, 2              
        call obstaclexfixed_updateval
        mov char_xfixedpos, 1
        mov char_y, 0098h
        mov score_ones, 0
        mov score_hund, 0
        mov score_tens, 0
        mov allowscore, 0
        ret
    default_gamevalue endp 

    gameover_input proc near
        mov ah, 01h
        int 16h
        jnz gameover_keypress       ;if zero flag is false, go to _keypress        
        jmp gameover_input          ;else keep checking for input

        gameover_keypress:
            mov game_state, 0
            call default_gamevalue
            call generateseed
            call obstaclexfixed_updateval
            ret
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
        call .printscore

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
        call .printscore
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
        push si
        mov si, 0

        collission_obstacle:
            cmp obs_isactive[si], 0         ;ignore current obstacle if inactive(0)
            je exit_collissionobstacle
            
            mov ax, char_x
            add ax, char_size
            cmp ax, obs_xpos[si]
            jng exit_collissionobstacle

            mov ax, obs_xpos[si]
            add ax, char_size
            cmp char_x, ax
            jnl exit_collissionobstacle

            mov ax, char_y
            add ax, char_size
            cmp ax, obs_ypos[si]
            jng exit_collissionobstacle

            mov ax, obs_ypos[si]
            add ax, char_size
            cmp char_y, ax
            jnl exit_collissionobstacle

            ;if collission is true
            mov game_state, 2         ;set game state to gameover
            jmp check_state

        ;if false
        exit_collissionobstacle:
            add si, 2
            loop collission_obstacle
            pop si
        
        ;check if char is colliding with icicle
        ;char_x+char_size > iciclex && char_x < iciclex+char_size 
        ;&& char_y+char_size > obstacle_ypos && char_y < obstacle_ypos+char_size 
        collission_icicle:
            cmp icicle_state, 0
            je exit_collission
            
            mov ax, char_x
            add ax, char_size
            cmp ax, iciclex
            jng exit_collission

            mov ax, iciclex
            add ax, char_size
            cmp char_x, ax
            jnl exit_collission

            mov ax, char_y
            sub ax, 2
            add ax, char_size
            cmp ax, icicley
            jng exit_collission

            mov ax, icicley
            add ax, char_size
            sub ax, 2
            cmp char_y, ax
            jnl exit_collission

            ;if collission is true
            mov game_state, 2         ;set game state to gameover
            jmp check_state
        exit_collission:    ret
    check_collission endp

    move_obstacle proc near        
        ;array addresses: 0, 2, 4, 6, 8
        push si
        mov si, 0
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
            pop si
            ret

        returntop_obstacle:
            mov allowscore, 1                       ;will allow scoring until one obstacle has passed
            
            mov ax, 0007h
            mov obs_ypos[si], ax                ;mov obx_ypos[si] back to top

            call nurng
            call obstaclexfixed_updateval
            add si, 2
            loop loophere                           ;loop until cx is 0
            pop si

            ret
    move_obstacle endp

    render_obstacle proc 
        ;obstacle 1
        render_obstacle1:
            mov _rendersizeX, 18            ;x size
            mov _rendersizeY, 17            ;y size
            mov si, offset obs_isactive
            mov ax, [si+0]
            cmp ax, 0
            je render_obstacle2
            mov si, offset obs_xpos
            mov ax, [si+0]
            mov rendercoordX, ax             ;x coord
            mov si, offset obs_ypos
            mov ax, [si+0]
            inc ax
            mov rendercoordY, ax             ;y coord
            mov si, 0
            call check_leftright
            call _rendersprite
            jmp render_obstacle2

        ;obstacle 2
        render_obstacle2:
            mov _rendersizeX, 18            ;x size
            mov _rendersizeY, 17            ;y size
            mov si, offset obs_isactive
            mov ax, [si+2]
            cmp ax, 0
            je render_obstacle3
            mov si, offset obs_xpos
            mov ax, [si+2]
            mov rendercoordX, ax             ;x coord
            mov si, offset obs_ypos
            mov ax, [si+2]
            inc ax
            mov rendercoordY, ax             ;y coord
            mov si, 2
            call check_leftright
            call _rendersprite
            jmp render_obstacle3

        ;obstacle 3
        render_obstacle3:
            mov _rendersizeX, 18            ;x size
            mov _rendersizeY, 17            ;y size
            mov si, offset obs_isactive
            mov ax, [si+4]
            cmp ax, 0
            je render_obstacle4
            mov si, offset obs_xpos
            mov ax, [si+4]
            mov rendercoordX, ax             ;x coord
            mov si, offset obs_ypos
            mov ax, [si+4]
            inc ax
            mov rendercoordY, ax             ;y coord
            mov si, 4
            call check_leftright
            call _rendersprite
            jmp render_obstacle4

        ;obstacle 4
        render_obstacle4:
            mov _rendersizeX, 18            ;x size
            mov _rendersizeY, 17            ;y size
            mov si, offset obs_isactive
            mov ax, [si+6]
            cmp ax, 0
            je render_obstacle5
            mov si, offset obs_xpos
            mov ax, [si+6]
            mov rendercoordX, ax             ;x coord
            mov si, offset obs_ypos
            mov ax, [si+6]
            inc ax
            mov rendercoordY, ax             ;y coord
            mov si, 6
            call check_leftright
            call _rendersprite
            jmp render_obstacle5

        ;obstacle 5
        render_obstacle5:
            mov _rendersizeX, 18            ;x size
            mov _rendersizeY, 17            ;y size
            mov si, offset obs_isactive
            mov ax, [si+8]
            cmp ax, 0
            je exit_renderobstacle
            mov si, offset obs_xpos
            mov ax, [si+8]
            mov rendercoordX, ax             ;x coord
            mov si, offset obs_ypos
            mov ax, [si+8]
            inc ax
            mov rendercoordY, ax             ;y coord
            mov si, 8
            call check_leftright
            call _rendersprite
            jmp exit_renderobstacle

        check_leftright:
            cmp obs_xpos[si], 135
            je render_obsleft

            cmp obs_xpos[si], 223
            je render_obsleft

            cmp obs_xpos[si], 182
            je render_obsright

            cmp obs_xpos[si], 270
            je render_obsright

        render_obsleft:
            mov si, offset obstacle_left            ;tileset array, will refer for color to print
            ret

        render_obsright:
            mov si, offset obstacle_right           ;tileset array, will refer for color to print
            ret

        exit_renderobstacle:    ret
    render_obstacle endp
   
        ;this is declared before calling _rendersprite
        ;example syntax
        ;mov si, offset player           ;tileset array, will refer for color to print
        ;mov rendercoordX, 0             ;x coord
        ;mov rendercoordY, 0             ;y coord
        ;mov _rendersizeX, 16            ;x size
        ;mov _rendersizeY, 16            ;y size
        ;this is declared before calling _rendersprite

    _rendersprite proc near         ;cx = x coord, dx = y coord, si = tileset(ie. tower, obstacle), _rendersizeX, _rendersizeY, renderX, renderY
        push ax
        push bx
        push cx
        push dx
        sub _rendersizeX, 2
        sub _rendersizeY, 2
        mov cx, rendercoordX
        mov dx, rendercoordY
        dec dx
        render_horizontal:
            ;horizontal render
            mov ah, 0ch                 ;set config to write pixels
            mov al, [si]                ;tile color as per address
            mov bh, 00h                 ;page number
            int 10h                     ;execute

            inc cx
            inc si
            mov ax, cx
            sub ax, rendercoordX
            cmp ax, _rendersizeX
            jng render_horizontal       ; if !(currentxcoord - rendercoordX < _rendersizeX),
                                        ; goto render_horizontal, else continue to next line
            ;vertical render
            mov cx, rendercoordX
            inc dx
            inc si
            mov ax, dx 
            sub ax, rendercoordY
            cmp ax, _rendersizeY
            jng render_horizontal       ; if !(currentycoord - rendercoordY < _rendersizeY),
                                        ; goto render_horizontal, else exit subroutine
            pop ax
            pop bx
            pop cx
            pop dx
            ret
    _rendersprite endp

    render_char proc near
        cmp char_xfixedpos, 1
        je render_leftchar
        cmp char_xfixedpos, 3
        je render_leftchar

        cmp char_xfixedpos, 2
        je render_rightchar
        cmp char_xfixedpos, 4
        je render_rightchar

        render_leftchar:
            mov si, offset Player_left       ;tileset array, will refer for color to print
            mov ax, char_x
            mov rendercoordX, ax             ;x coord
            mov ax, char_y
            inc ax
            mov rendercoordY, ax             ;y coord
            mov _rendersizeX, 17             ;x size
            mov _rendersizeY, 17             ;y size
            call _rendersprite
            ret

        render_rightchar:
            mov si, offset Player_right       ;tileset array, will refer for color to print
            mov ax, char_x
            mov rendercoordX, ax             ;x coord
            mov ax, char_y
            mov rendercoordY, ax             ;y coord
            mov _rendersizeX, 17             ;x size
            mov _rendersizeY, 17
            call _rendersprite
            ret
    render_char endp

    increment_score proc near
        cmp allowscore, 0
        je exit_increment

        mov al, score_rate
        add score_ones, al
    	cmp score_ones, 10
   	    jl exit_increment

    	sub score_ones, 10
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

    .printscore proc near    ;dl - x position
        ; the string 'Score: ' occupies 7 squares incl. whitespace
        add dl, 7       ;set x pos 7 squares apart from previous' text initial letter
        int 10h

        ; print hundreds digit
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

    	inc dl              ; move to next square
    	int 10h

        ; print ones digit
    	push dx
        mov dl, score_ones
    	add dl, '0'
    	int 21h
        pop dx

        ret
    .printscore endp

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