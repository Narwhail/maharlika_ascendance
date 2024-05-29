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
    line5_game db "Score:" ,"$"
    blank_game db "   " ,"$"
    ;gameover state
    line1_over db "Game Over...", "$"
    line2_over db "Score: ", "$"
    line3_over db "Press 'R' to return to menu", "$"
    ;menu state
    line1_menu db "MAHARLIKA ASCENDANCE", "$"   ;20
    line3_menu db "[s] Start playing", "$"
    line4_menu db "[t] Tutorial", "$"
    ;tutorial state
    line1_pg1 db "Use 'wasd' to move", "$"      ;18
    line2_pg1 db "your character!", "$"         ;15
    line1_pg2 db "Gain score", "$"              ;10
    line2_pg2 db "by staying alive!", "$"       ;17
    line1_pg3 db "Watch out for obstacles", "$" ;23
    line2_pg3 db "and falling icicles!", "$"    ;20
    line1_pg4 db "Obstacles increase", "$"      ;18
    line2_pg4 db "as you score!", "$"           ;13
    line1_pg5 db "5 points", "$" ;8
    line2_pg5 db "10 points", "$" ;9
    line3_pg5 db "20 points", "$" ;9
    line4_pg5 db "Keep an eye for coins", "$" ;21
    line5_pg5 db "to gain more points!", "$" ;20
    line3_tutorial db "[e] menu", "$"           ;8

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
    score_overallhex dw 0
    rendercoordX dw 0
    rendercoordY dw 0
    _rendersizeX dw 0
    _rendersizeY dw 0
    prevtime db 0
    allowscore db 0             ;0 = inactive, 1 = active
    delaytime db 0
    tempmsecond db 0
    _stringx db 0
    _stringy db 0
    _stringcolor db 0
    _stringlength dw 0
    tutorial_page db 1
    current_seconds db 0

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
    enemy_interval dw 0
    icicle_state db 0          ;0 = inactive, 1 = tracking, 2 = active  (will automatically turn inactive once it reaches the bottom limit)
    iciclex dw ?
    icicley dw 8
    icicle_velocity dw 5

    ;coin variables
    coinx dw 0
    coiny dw 0
    coinsize dw 8
    tempcoinx dw 0
    coin_state dw 2                 ; 0 inactive, 1 activating, 2 active, 3 cooldown
    coin_value dw 1
    obsy_address dw 0

    ;tower
    menutowerx dw 215
    menutowery_seg1 dw 103, 135, 167
    menutowery_seg2 dw 119, 151, 183
    menutowerchesty dw 79
    towery dw 17, 33, 49, 65, 81, 97, 113, 129, 145, 162, 178
    towerx dw 151

    ;obstacle
    obs_xpos dw 183, 183, 183, 183, 183                 ;address is by 2 ie. 0,2,4,6,8
    obs_ypos dw 23, 55, 87, 119, 151                    ;address is by 2 ie. 0,2,4,6,8
    obsfixedxpos_state dw 0                             ;0 = 0087h, 1 = 00b7h, 2 = 00dfh, 3 = 010fh 
    obs_isactive dw 1, 0, 0, 0, 0                       ;0 = inactive, 1 = active
    .obs_activetemp dw 0, 0, 0, 0, 0

    ;sprites

    coin db 00h, 00h, 0Eh, 0Eh, 0Eh, 0Eh, 00h, 00h, 00h     ;9x9 
         db 00h, 0Eh, 0Eh, 2Ah, 2Ah, 0Eh, 0Eh, 00h, 00h
         db 0Eh, 0Eh, 2Ah, 0Eh, 0Eh, 2Ah, 0Eh, 0Eh, 00h
         db 0Eh, 2Ah, 0Eh, 0Eh, 0Eh, 0Eh, 2Ah, 0Eh, 00h
         db 0Eh, 2Ah, 0Eh, 0Eh, 0Eh, 0Eh, 2Ah, 0Eh, 00h
         db 0Eh, 0Eh, 2Ah, 0Eh, 0Eh, 2Ah, 0Eh, 0Eh, 00h
         db 00h, 0Eh, 0Eh, 2Ah, 2Ah, 0Eh, 0Eh, 00h, 00h
         db 00h, 00h, 0Eh, 0Eh, 0Eh, 0Eh, 00h, 00h, 00h
         db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    coinsilver  db 00h, 00h, 1Ah, 1Ah, 1Ah, 1Ah, 00h, 00h, 00h  ;9x9
                db 00h, 1Ah, 1Ah, 17h, 17h, 1Ah, 1Ah, 00h, 00h
                db 1Ah, 1Ah, 17h, 1Ah, 1Ah, 17h, 1Ah, 1Ah, 00h
                db 1Ah, 17h, 1Ah, 1Ah, 1Ah, 1Ah, 17h, 1Ah, 00h
                db 1Ah, 17h, 1Ah, 1Ah, 1Ah, 1Ah, 17h, 1Ah, 00h
                db 1Ah, 1Ah, 17h, 1Ah, 1Ah, 17h, 1Ah, 1Ah, 00h
                db 00h, 1Ah, 1Ah, 17h, 17h, 1Ah, 1Ah, 00h, 00h
                db 00h, 00h, 1Ah, 1Ah, 1Ah, 1Ah, 00h, 00h, 00h
                db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    coinruby db 00h, 00h, 28h, 28h, 28h, 28h, 00h, 00h, 00h ;9x9
             db 00h, 28h, 28h, 04h, 04h, 28h, 28h, 00h, 00h
             db 28h, 28h, 04h, 28h, 28h, 04h, 28h, 28h, 00h
             db 28h, 04h, 28h, 28h, 28h, 28h, 04h, 28h, 00h
             db 28h, 04h, 28h, 28h, 28h, 28h, 04h, 28h, 00h
             db 28h, 28h, 04h, 28h, 28h, 04h, 28h, 28h, 00h
             db 00h, 28h, 28h, 04h, 04h, 28h, 28h, 00h, 00h
             db 00h, 00h, 28h, 28h, 28h, 28h, 00h, 00h, 00h
             db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

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
    
    Player_up  db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h    ;17x17
               db 00h, 00h, 00h, 2Fh, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 2Fh, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h
               db 00h, 2Fh, 00h, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 00h, 00h, 2Fh, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 2Fh, 00h
               db 00h, 00h, 00h, 00h, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 2Fh, 2Fh, 2Fh, 00h, 00h
               db 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 00h
               db 00h, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 00h, 00h
               db 00h, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h, 00h, 00h, 2Fh, 2Fh, 2Fh, 2Fh, 00h
    
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

    Player_leftdark     db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h   ;17x17
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 14h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 00h, 14h, 00h, 00h, 00h
                        db 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 00h, 14h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 14h, 00h, 14h, 00h, 00h, 14h, 00h
                        db 00h, 14h, 00h, 14h, 00h, 00h, 00h, 14h, 00h, 00h, 00h, 00h, 00h, 00h, 14h, 14h, 00h
                        db 00h, 00h, 14h, 14h, 00h, 00h, 00h, 14h, 00h, 14h, 14h, 00h, 14h, 00h, 14h, 14h, 00h
                        db 00h, 14h, 14h, 14h, 00h, 14h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 00h
                        db 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 00h, 00h
                        db 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h, 00h, 00h, 14h, 14h, 00h, 00h, 00h
                        db 00h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 14h, 14h, 14h, 00h, 14h, 00h, 00h, 00h
                        db 00h, 00h, 14h, 00h, 00h, 14h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 14h, 00h
                        db 00h, 00h, 00h, 14h, 14h, 00h, 00h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h
                        db 00h, 00h, 00h, 14h, 14h, 00h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h
                        db 00h, 14h, 14h, 00h, 00h, 00h, 14h, 00h, 14h, 14h, 14h, 14h, 00h, 00h, 00h, 14h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

    Player_rightdark    db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h   ;17x17
                        db 00h, 00h, 00h, 00h, 00h, 14h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 14h, 00h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h, 00h
                        db 00h, 00h, 14h, 00h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h
                        db 14h, 00h, 00h, 14h, 00h, 14h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 14h, 14h, 00h, 00h, 00h, 00h, 00h, 00h, 14h, 00h, 00h, 00h, 14h, 00h, 14h, 00h, 00h
                        db 14h, 14h, 00h, 14h, 00h, 14h, 14h, 00h, 14h, 00h, 00h, 00h, 14h, 14h, 00h, 00h, 00h
                        db 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 14h, 00h, 14h, 14h, 14h, 00h, 00h
                        db 00h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h
                        db 00h, 00h, 14h, 14h, 00h, 00h, 00h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h
                        db 00h, 00h, 14h, 00h, 14h, 14h, 14h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 14h, 00h, 00h
                        db 14h, 14h, 00h, 14h, 14h, 14h, 14h, 14h, 00h, 14h, 14h, 00h, 00h, 14h, 00h, 00h, 00h
                        db 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 00h, 00h, 14h, 14h, 00h, 00h, 00h, 00h
                        db 14h, 14h, 00h, 14h, 14h, 00h, 14h, 14h, 00h, 14h, 00h, 14h, 14h, 00h, 00h, 00h, 00h
                        db 14h, 00h, 00h, 00h, 14h, 14h, 14h, 14h, 00h, 14h, 00h, 00h, 00h, 14h, 14h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
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
            mov coin_state, 1
            
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
            call move_coin
            call update_coinvalue
            call update_coinactive
            call coin_collission
            call playinggame_printtext
            call render_gametower
            call render_char
            call render_obstacle
            call render_icicle
            call render_enemy
            call render_coin
            call check_collission
            call update_enemydifficulty
            
            call check_state
        game_over:
            call render_chardeathanimation
            call clear_screen
            call gameover_rendersprite
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

    coin_collission proc
        ;check if char is colliding with obstacle
        ;char_x+char_size > obstacle_xpos && char_x < obstacle_xpos+char_size 
        ;&& char_y+char_size > obstacle_ypos && char_y < obstacle_ypos+char_size 
        cmp coin_state, 0                       ;ignore coin if inactive(0)
        je exit_coincollission2
        jmp check_coincollission

        exit_coincollission2: ret

        check_coincollission:
        
        mov ax, char_x
        add ax, char_size
        cmp ax, coinx
        jng exit_coincollission2

        mov ax, coinx
        add ax, char_size
        cmp char_x, ax
        jnl exit_coin_collission

        mov ax, char_y
        add ax, char_size
        cmp ax, coiny
        jng exit_coin_collission

        mov ax, coiny
        add ax, char_size
        cmp char_y, ax
        jnl exit_coin_collission

        ;if collission is true, set state to cooldown
        cmp coin_state, 2
        jne exit_coin_collission

        call increment_score

        cmp coin_value, 1
        je add_1points

        cmp coin_value, 2
        je add_2points

        cmp coin_value, 3
        je add_3points

        add_1points:
            add score_ones, 1
            mov coin_state, 3
            jmp exit_coin_collission
        add_2points:
            add score_ones, 2
            mov coin_state, 3
            jmp exit_coin_collission
        add_3points:
            add score_ones, 3
            mov coin_state, 3
            jmp exit_coin_collission

        exit_coin_collission:   
            call calculate_overallscore
            ret
    coin_collission endp

    update_coinvalue proc near
        call calculate_overallscore
        cmp score_overallhex, 100
        jl set_coinsilver

        cmp score_overallhex, 250
        jl set_coingold

        cmp score_overallhex, 999
        jl set_coinruby

        set_coinsilver:
            mov coin_value, 5
            ret

        set_coingold:
            mov coin_value, 10
            ret

        set_coinruby:
            mov coin_value, 20
            ret

        exit_update_coinvalue:  ret
    update_coinvalue endp

    update_coinactive proc near
        cmp coin_state, 0
        jne exit_update_coinactive
        
        mov coin_state, 1
        exit_update_coinactive: ret
    update_coinactive endp

    render_coin proc near
        cmp coin_state, 2
        jne exit_rendercoin
        
        cmp coin_value, 5
        je render_silvercoin

        cmp coin_value, 10
        je render_goldcoin

        cmp coin_value, 20
        je render_rubycoin

        jmp exit_rendercoin

        exit_rendercoin:    ret
        render_silvercoin:
            mov si, offset coinsilver           ;tileset array, will refer for color to print
            mov ax, coinx
            add ax, 4
            mov rendercoordX, ax             ;x coord
            mov ax, coiny
            add ax, 4
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 9            ;x size
            mov _rendersizeY, 9            ;y size
            call _rendersprite
            ret
            
        render_goldcoin:
            mov si, offset coin           ;tileset array, will refer for color to print
            mov ax, coinx
            add ax, 4
            mov rendercoordX, ax             ;x coord
            mov ax, coiny
            add ax, 4
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 9            ;x size
            mov _rendersizeY, 9            ;y size
            call _rendersprite
            ret

        render_rubycoin:
            mov si, offset coinruby           ;tileset array, will refer for color to print
            mov ax, coinx
            add ax, 4
            mov rendercoordX, ax             ;x coord
            mov ax, coiny
            add ax, 4
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 9            ;x size
            mov _rendersizeY, 9            ;y size
            call _rendersprite
            ret
    render_coin endp

    move_coin proc near
        cmp coin_state, 1                   ;activating, determining where to position coin
        jne move_coincondition2
        jmp coin_activating

        move_coincondition2:
        cmp coin_state, 2                   ;active, is now moving downwards
        jne move_coincondition3
        jmp coin_descending

        move_coincondition3:
        cmp coin_state, 3                   ;cooldown, moving down still
        jne exit_movecoin                   ;inactive, exit move_coin func
        jmp coin_descending

        exit_movecoin:  ret

        coin_activating:
            mov si, obsy_address
            mov ax, obs_xpos[si] 
            mov coinx, ax
            
            mov si, 0
            mov cx, 5
            loop_coinassign:
                mov ax, obs_ypos[si]
                cmp ax, 23                   ;compare if an obstacle(obs_ypos[si]) is at the top
                jne check_nextcoinassign
                mov ax, si
                mov obsy_address, ax
                mov ax, obs_ypos[si]        ;coiny = obs_ypos[si]
                mov coiny, ax
                mov ax, obs_xpos[si]        ;coinx = obs_xpos[si]
                mov coinx, ax
                check_nextcoinassign:
                    add si, 2
                    loop loop_coinassign
                    mov si, 0

            assign_coinx:
                call nurng                  ;generate randomNum
                cmp randomNum, 1
                je coin_position1
                cmp randomNum, 2
                je coin_position2
                cmp randomNum, 3
                je coin_position3
                cmp randomNum, 4
                je coin_position4
                jmp assign_coinx            ;if no conditions satisfied

                mov si, obsy_address
                coin_position1:
                    mov coinx, 135
                    mov ax, obs_xpos[si]
                    cmp coinx, ax
                    je coin_position2
                    jmp check_tempcoinx
                coin_position2:
                    mov coinx, 182
                    mov ax, obs_xpos[si]
                    cmp coinx, ax
                    je coin_position3
                    jmp check_tempcoinx
                coin_position3:
                    mov coinx, 223
                    mov ax, obs_xpos[si]
                    cmp coinx, ax
                    je coin_position4
                    jmp check_tempcoinx
                coin_position4:
                    mov coinx, 270
                    mov ax, obs_xpos[si]
                    cmp coinx, ax
                    je coin_position1
                    jmp check_tempcoinx

                check_tempcoinx:            ;go to assign_coinx if it overlaps with an obstacle
                    mov coin_state, 2

        coin_descending:
            mov si, obsy_address
            mov ax, obs_ypos[si]
            mov coiny, ax
            mov ax, y_bottomlimit
            cmp coiny, ax
            jng exit_coindescending
            mov coin_state, 0
            mov coiny, 0
            mov coinx, 0

            exit_coindescending:
            mov si, 0
            ret
    move_coin endp

    render_chardeathanimation proc near
        mov ah, 2ch
        int 21h

        mov tempmsecond, dh
        add tempmsecond, 4      ;add 2 seconds to temporary time
        cmp tempmsecond, 59
        jng loop_renderdeath
        sub tempmsecond, 60

        loop_renderdeath:
            cmp char_xfixedpos, 1
            je render_leftchardeath

            cmp char_xfixedpos, 3
            je render_leftchardeath

            cmp char_xfixedpos, 2
            je render_rightchardeath

            cmp char_xfixedpos, 4
            je render_rightchardeath

        render_leftchardeath:
            mov ah, 2ch
            int 21h
            xor ax, ax
            mov al, dh      ;dh contains seconds
            mov bl, 2       ;divisor, interval = 2 seconds
            div bl          ;divide current seconds to bl
            cmp ah, 0       ;compare remainder
            je _renderleftdark
            jmp _renderleft

            _renderleft:
                mov si, offset Player_left      ;pangalan nung sprite
                mov ax, char_x
                mov rendercoordX, ax                ;x coord
                mov ax, char_y
                mov rendercoordY, ax                ;y coord
                mov _rendersizeX, 17                ;x size
                mov _rendersizeY, 17                ;y size
                call _rendersprite     
                jmp check_renderdeathtime

            _renderleftdark:
                mov si, offset Player_leftdark      ;pangalan nung sprite
                mov ax, char_x
                mov rendercoordX, ax                ;x coord
                mov ax, char_y
                mov rendercoordY, ax                ;y coord
                mov _rendersizeX, 17                ;x size
                mov _rendersizeY, 17                ;y size
                call _rendersprite
                jmp check_renderdeathtime

        render_rightchardeath:
            mov ah, 2ch
            int 21h
            xor ax, ax
            mov al, dh      ;dh contains seconds
            mov bl, 2       ;divisor, interval = 2 seconds
            div bl          ;divide current seconds to bl
            cmp ah, 0       ;compare remainder
            je _renderrightdark
            jmp _renderright

            _renderright:
                mov si, offset Player_right      ;pangalan nung sprite
                mov ax, char_x
                mov rendercoordX, ax                ;x coord
                mov ax, char_y
                mov rendercoordY, ax                ;y coord
                mov _rendersizeX, 17                ;x size
                mov _rendersizeY, 17                ;y size
                call _rendersprite     
                jmp check_renderdeathtime

            _renderrightdark:
                mov si, offset Player_rightdark      ;pangalan nung sprite
                mov ax, char_x
                mov rendercoordX, ax                ;x coord
                mov ax, char_y
                mov rendercoordY, ax                ;y coord
                mov _rendersizeX, 17                ;x size
                mov _rendersizeY, 17                ;y size
                call _rendersprite
                jmp check_renderdeathtime

        check_renderdeathtime:
            mov ah, 2ch
            int 21h
            cmp tempmsecond, dh              
            je exit_renderdeath
            jmp loop_renderdeath

        exit_renderdeath:   ret
    render_chardeathanimation endp

    tutorial_printscreen proc near              ; prints the text and sprites need at a given page
        cmp tutorial_page, 1
        jne checkpage2
        jmp page1

        checkpage2:
        cmp tutorial_page, 2
        jne checkpage3
        jmp page2

        checkpage3:
        cmp tutorial_page, 3
        jne checkpage4
        jmp page3

        checkpage4:
        cmp tutorial_page, 4
        jne checkpage5
        jmp page4

        checkpage5:
        cmp tutorial_page, 5
        jne exit_tutprintscreen
        jmp page5

        exit_tutprintscreen:    ret
        page1:
            mov si, offset Player_left
            mov rendercoordX, 128
            mov rendercoordY, 79
            mov _rendersizeX, 17
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 48
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 64
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg2
            mov rendercoordX, 144
            mov rendercoordY, 80
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite
        
            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 96
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 112
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line1_pg1       ;Use 'wasd' to move
            mov _stringx, 11
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 18
            call _printtext

            mov bp, offset line2_pg1        ;your character!
            mov _stringx, 13
            mov _stringy, 19
            mov _stringcolor, 0fh
            mov _stringlength, 15
            call _printtext

            mov bp, offset line3_tutorial        ;[e] menu
            mov _stringx, 16
            mov _stringy, 23
            mov _stringcolor, 0eh
            mov _stringlength, 8
            call _printtext

            ; navigation bar
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21   
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 07h              ;character to print - solid circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 5
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 09h              ;character to print - blank circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 23     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1ah              ;character to print - right arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h
            ret
            
        page2:
            mov si, offset Player_right
            mov rendercoordX, 176
            mov rendercoordY, 95
            mov _rendersizeX, 17
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 48
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 64
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg2
            mov rendercoordX, 144
            mov rendercoordY, 80
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite
        
            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 96
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 112
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset obstacle_left
            mov rendercoordX, 128
            mov rendercoordY, 87
            mov _rendersizeX, 18
            mov _rendersizeY, 17
            call _rendersprite

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line1_pg2       ;Gain score
            mov _stringx, 15
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 10
            call _printtext


            mov bp, offset line2_pg2       ;by staying alive!
            mov _stringx, 12
            mov _stringy, 19
            mov _stringcolor, 0fh
            mov _stringlength, 17
            call _printtext

            mov bp, offset line3_tutorial        ;[e] menu
            mov _stringx, 16
            mov _stringy, 23
            mov _stringcolor, 0eh
            mov _stringlength, 8
            call _printtext

            ; navigation bar
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 15     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1bh              ;character to print - left arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21   
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 07h              ;character to print - solid circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 5
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 18     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 09h              ;character to print - blank circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 23     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1ah              ;character to print - right arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h
            ret

        page3:
            mov si, offset Player_left
            mov rendercoordX, 128
            mov rendercoordY, 95
            mov _rendersizeX, 17
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset enemy
            mov rendercoordX, 195
            mov rendercoordY, 52
            mov _rendersizeX, 17
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 48
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 64
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg2
            mov rendercoordX, 144
            mov rendercoordY, 80
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite
        
            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 96
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 112
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset obstacle_right
            mov rendercoordX, 175
            mov rendercoordY, 71
            mov _rendersizeX, 18
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset icicle
            mov rendercoordX, 132
            mov rendercoordY, 40
            mov _rendersizeX, 10
            mov _rendersizeY, 15
            call _rendersprite

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            ; enemy exclamation
            mov ah, 02h     
            mov bh, 0     
            mov dh, 5              
            mov dl, 25          
            int 10h 

            mov ah, 0Eh            
            mov al, '!'
            mov bh, 0
            mov bl, 20h            
            int 10h

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line1_pg3        ;Watch out for obstacles
            mov _stringx, 9
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 23
            call _printtext

            mov bp, offset line2_pg3        ;and falling icicles!
            mov _stringx, 11
            mov _stringy, 19
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line3_tutorial        ;[e] menu
            mov _stringx, 16
            mov _stringy, 23
            mov _stringcolor, 0eh
            mov _stringlength, 8
            call _printtext

            ; navigation bar
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 15     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1bh              ;character to print - left arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 07h              ;character to print - solid circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 5
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 19     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 09h              ;character to print - blank circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 23     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1ah              ;character to print - right arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h
            ret

        page4:
            mov si, offset Player_right
            mov rendercoordX, 176
            mov rendercoordY, 79
            mov _rendersizeX, 17
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 48
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 64
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg2
            mov rendercoordX, 144
            mov rendercoordY, 80
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite
        
            mov si, offset ingame_towerseg3
            mov rendercoordX, 144
            mov rendercoordY, 96
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset ingame_towerseg1
            mov rendercoordX, 144
            mov rendercoordY, 112
            mov _rendersizeX, 33
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset obstacle_right
            mov rendercoordX, 175
            mov rendercoordY, 55
            mov _rendersizeX, 18
            mov _rendersizeY, 17
            call _rendersprite

            mov si, offset obstacle_right
            mov rendercoordX, 175
            mov rendercoordY, 103
            mov _rendersizeX, 18
            mov _rendersizeY, 17
            call _rendersprite
        
            mov si, offset obstacle_left
            mov rendercoordX, 128
            mov rendercoordY, 80
            mov _rendersizeX, 18
            mov _rendersizeY, 17
            call _rendersprite

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line1_pg4        ;Obstacles increase
            mov _stringx, 11
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 18
            call _printtext

            mov bp, offset line2_pg4        ;as you score!
            mov _stringx, 14
            mov _stringy, 19
            mov _stringcolor, 0fh
            mov _stringlength, 13
            call _printtext

            mov bp, offset line3_tutorial        ;[e] menu
            mov _stringx, 16
            mov _stringy, 23
            mov _stringcolor, 0eh
            mov _stringlength, 8
            call _printtext

            ; navigation bar
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 15     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1bh              ;character to print - left arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 07h              ;character to print - solid circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 5
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 20     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 09h              ;character to print - blank circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 23     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1ah              ;character to print - right arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h
            ret

        page5:
            mov si, offset coinsilver       ;silver coin
            mov rendercoordX, 119
            mov rendercoordY, 63
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov si, offset coin       ;gold coin
            mov rendercoordX, 119
            mov rendercoordY, 79
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov si, offset coinruby       ;ruby coin
            mov rendercoordX, 119
            mov rendercoordY, 95
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov bp, offset line1_menu       ;MAHARLIKA ASCENDANCE
            mov _stringx, 10
            mov _stringy, 2
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line1_pg5       ;5 points
            mov _stringx, 17
            mov _stringy, 8
            mov _stringcolor, 0fh
            mov _stringlength, 8
            call _printtext

            mov bp, offset line2_pg5       ;10 points
            mov _stringx, 17
            mov _stringy, 10
            mov _stringcolor, 0fh
            mov _stringlength, 9
            call _printtext

            mov bp, offset line3_pg5       ;20 points
            mov _stringx, 17
            mov _stringy, 12
            mov _stringcolor, 0fh
            mov _stringlength, 9
            call _printtext

            mov bp, offset line4_pg5        ;Keep an eye for coins
            mov _stringx, 10
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 21
            call _printtext

            mov bp, offset line5_pg5        ;to gain more points!
            mov _stringx, 10
            mov _stringy, 19
            mov _stringcolor, 0fh
            mov _stringlength, 20
            call _printtext

            mov bp, offset line3_tutorial        ;[e] menu
            mov _stringx, 16
            mov _stringy, 23
            mov _stringcolor, 0eh
            mov _stringlength, 8
            call _printtext

            ; navigation bar
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 15     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 1bh              ;character to print - left arrow
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21  
            mov dl, 17     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 07h              ;character to print - solid circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 5
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 21    
            mov dl, 21     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 09h              ;character to print - blank circle
            mov bh, 0          
            mov bl, 0ah             ;color
            mov cx, 1
            int 10h
            ret
    tutorial_printscreen endp

    tutorial_input proc near                    ; handles input for navigation
        mov ah, 00h             ; set mode to read input
        int 16h                 ; execute mode

        cmp al, 'a'             ; compare with 'a'
        je a_keyinput           ; if equal, jump to a_keyinput
        cmp al, 'A'             ; compare with 'A'
        je a_keyinput           ; if equal, jump to a_keyinput

        cmp al, 'd'
        je d_keyinput
        cmp al, 'D'
        je d_keyinput

        cmp al, 'e'
        je e_keyinput
        cmp al, 'E'
        je e_keyinput

        jmp tutorial_input          ; if no keys are pressed, jmp to tutorial_input again to check

        a_keyinput:
            cmp tutorial_page, 1
            je tutorial_input
            dec tutorial_page
            ret
        d_keyinput:
            cmp tutorial_page, 5
            je tutorial_input
            inc tutorial_page
            ret
        e_keyinput:
            mov game_state, 0
            mov tutorial_page, 1
            ret
    tutorial_input endp

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

	; Display the first line at row 4, column 5
        mov bp, offset line1_menu        ;[e] menu
        mov _stringx, 10
        mov _stringy, 04
        mov _stringcolor, 0fh
        mov _stringlength, 20
        call _printtext

        mov bp, offset line3_menu        ;[e] menu
        mov _stringx, 04
        mov _stringy, 13
        mov _stringcolor, 0eh
        mov _stringlength, 17
        call _printtext         

        ; Display the first line at row 4, column 5
        mov bp, offset line4_menu        ;[e] menu
        mov _stringx, 04
        mov _stringy, 15
        mov _stringcolor, 0eh
        mov _stringlength, 12
        call _printtext   


        ;box
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 02    
            mov dl, 08     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 05fh          ;character to print - solid line
            mov bh, 0          
            mov bl, 0fh             ;color
            mov cx, 24
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 05    
            mov dl, 08     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 05fh          ;character to print - solid line
            mov bh, 0          
            mov bl, 0fh             ;color
            mov cx, 24
            int 10h  
            
        ret
    menuscreen_printtext endp

    ; syntax
    ; mov bp, offset daString
    ; mov _stringx, 2               ; x position of string
    ; mov _stringy, 2               ; y position of string
    ; mov bl, _stringcolor
    ; mov _stringlength, 5
    ; call _printtext
    _printtext proc
        mov  ax, ds
        mov  es, ax
        mov dh, _stringy
        mov dl, _stringx
        mov bl, _stringcolor
        mov cx, _stringlength
        mov ax, 1301h   
        mov bh, 00h   ;page
        int 10h
        mov bp, 0
        ret 
    _printtext endp

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
        ; icicle has 3 states. 0 for inactive, 1 for tracking, 2 for active
        ; Inactive state basically ignores rendering the sprite and changing(moving) 
        ;   the icicle position
        ; Tracking state renders the sprite for every 2 centiseconds, clear_screen is 
        ;   called every game tick mimicking a flickering effect. It also sets
        ;   the icicleX position to be same as char_x + 4 position. Adding 4 pixels 
        ;   will make the icicle render at the middle of the character since they
        ;   differ in size. icicle = 10x15, player = 17x17
        cmp icicle_state, 1         ; tracking state
        je icicle_trackingrender

        cmp icicle_state, 2         ; active
        je icicle_activerender

        jmp exit_rendericicle
        icicle_trackingrender:
            mov ah, 2ch                     ; set mode to read time. dh = seconds, dl = 1/00 seconds, centiseconds
            int 21h                         ; execute mode

            xor ax, ax                      ; reset ax register to 0
            mov al, dl                      ;dl contains centiseconds
            mov bl, 2                       ;bl will be the divisor, interval = 2 centiseconds
            div bl                          ;divide current centiseconds to bl

            cmp ah, 0                       ;compare modulo
            jne icicle_activerender         ;if not 0, then render the sprite
            ret                             ;else, dont render and exit function

        icicle_activerender:
            push si                         ; save si register value
            mov si, offset icicle           ;tileset array, will refer for color to print
            mov ax, iciclex
            mov rendercoordX, ax            ;x coord
            mov ax, icicley
            mov rendercoordY, ax            ;y coord
            mov _rendersizeX, 10            ;x size
            mov _rendersizeY, 15            ;y size
            call _rendersprite
            pop si                          ; return previously saved si register value
            jmp exit_rendericicle

        exit_rendericicle:  ret
    render_icicle endp

    move_icicle proc near
        cmp icicle_state, 1             ; if icicle_state = 1(activating), copy char_x+4 to iciclex.
        je icicle_tracking

        cmp icicle_state, 2             ; if icicle_state = 2(active), add icicley to icicle_velocity. Once icicley reaches
        je icicle_active                ; y_bottomlimit+16, reset icicley position and change state to 0 (inactive)

        jmp exit_moveicicle             ;else (no conditions are satisfied), exit function

        icicle_tracking:                ; will track the player's x position, if enemy_state is 2 (active), then icicle_state = 1(tracking)
            mov ax, char_x
            add ax, 4                   ;add 4 to charx
            mov iciclex, ax         

            cmp enemy_state, 2
            je exit_moveicicle          ;if enemy is in active state, continue to track playerx position for next run

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

            mov icicle_state, 0         ;else, reset icicle_state to inactive and icicley to 8
            mov icicley, 8
            jmp exit_moveicicle
        exit_moveicicle:    ret
    move_icicle endp

    move_tower proc 
        push si                             ; save si register value
        mov si, offset towery               ; set si the address of towery, since towery is a data word(dw) array
                                            ; address is by 2s. si = 0, 2, 4, ...
        mov cx, 11                          ;set loop to 11

        loop_movetower:
            mov ax, y_velocity
            add [si], ax                    ;towery[si] += y_velocity

            mov ax, y_bottomlimit
            add ax, 32                      ; added 32 pixels since bottom limit is mainly used for restricting the player from going further
            cmp [si], ax                    ; compare towery[si] to y_bottomlimit
            jng loopcheck_movetower         ; if not obs_ypos[si] < y_bottomlimit                   

            ;returntop_tower
            mov ax, 9
            mov [si], ax                    ;mov obx_ypos[si] back to top

        loopcheck_movetower:
            add si, 2                       ;add 2 to address, for next loop
            loop loop_movetower             ;loop until cx is 0, decrements cx if cx has value
            pop si                          ;return previously saved si register value
            ret                             ;return function
    move_tower endp

    render_gametower proc near
        mov cx, 1                           ; loop 1 time
        mov towerx, 151                     ; first towerx is 151, second towerx is 239

        tower_segment1:
            mov si, offset towery
            mov ax, towerx
            mov rendercoordX, ax            ;x coord
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
            mov current_seconds, dh
            call increment_score

        exit_checktick:
            ret
    check_tick endp

    render_enemy proc near
        cmp enemy_state, 0              ; if enemy_state is inactive, exit function (doesn't render the enemy)
        je exit_drawenemy

        mov si, offset enemy            ;tileset array, will refer for color to print
        mov ax, enemy_x
        mov rendercoordX, ax            ;x coord
        mov ax, enemy_y
        mov rendercoordY, ax            ;y coord
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
            mov dh, 2               ;y pos
            mov dl, 26              ;x pos
            int 10h 

            mov ah, 0Eh             ;config for writing text with color
            mov al, '!'
            mov bh, 0
            mov bl, 20h             ;color of text
            int 10h

            mov ah, 2ch
            int 21h

            xor ax, ax
            mov al, dl      ;dl contains centiseconds
            mov bl, 2       ;divisor, interval = 2 centiseconds
            div bl          ;divide current centiseconds to bl

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
        call calculate_overallscore
        mov si, 0 
        ;score conditions for active obstacle
        cmp score_overallhex, 20
        jl lowdiff
        cmp score_overallhex, 60
        jl mediumdiff
        cmp score_overallhex, 100
        jl intermediatediff
        cmp score_overallhex, 300
        jl harddiff
        jmp extremediff
        exit_updatediff:    ret
        lowdiff:
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 0
            mov .obs_activetemp[si+4], 0
            mov .obs_activetemp[si+6], 0
            mov .obs_activetemp[si+8], 0
            jmp beginupdate
        mediumdiff:
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 0
            mov .obs_activetemp[si+4], 0
            mov .obs_activetemp[si+6], 1
            mov .obs_activetemp[si+8], 0
            jmp beginupdate
        intermediatediff:
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 0
            mov .obs_activetemp[si+4], 1
            mov .obs_activetemp[si+6], 0
            mov .obs_activetemp[si+8], 1
            jmp beginupdate
        harddiff:
            mov .obs_activetemp[si+0], 1
            mov .obs_activetemp[si+2], 1
            mov .obs_activetemp[si+4], 0
            mov .obs_activetemp[si+6], 1
            mov .obs_activetemp[si+8], 1
            jmp beginupdate
        extremediff:
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

        
            ret
    update_difficulty endp

    calculate_overallscore proc near
    	cmp score_ones, 10
   	    jl check_tens
    	sub score_ones, 10
    	inc score_tens
        check_tens:
    	cmp score_tens, 10
    	jl check_hund
    	sub score_tens, 10
    	inc score_hund
        check_hund:
    	cmp score_hund, 10
    	jl exit_adjust
        
        exit_adjust:
        xor ax, ax          ; reset ax register to 0
        mov score_overallhex, ax
        mov al, score_ones
        add score_overallhex, ax
        xor ax, ax          ; reset ax register to 0
        mov al, score_tens
        mov bl, 10
        mul bl
        add score_overallhex, ax
        xor ax, ax          ; reset ax register to 0
        mov al, score_hund
        mov bl, 100
        mul bl
        add score_overallhex, ax
        ret
    calculate_overallscore endp

    update_enemydifficulty proc
        cmp enemy_state, 0
        jne exit_updatteenemy
        cmp icicle_state, 0
        jne exit_updatteenemy

        update_enemy:
            call calculate_overallscore
            mov enemy_interval, 10
            mov ax, score_overallhex        ; Load score_tens into AX
            mov bx, enemy_interval    ; Load enemy_interval into BL

            xor dx, dx                ; Clear DX for division
            div bx                    ; Divide AX by BL, quotient in AL, remainder in DX
            cmp dx, 0
            jne exit_updatteenemy
            mov enemy_state, 1        ; Set enemy state to 1
            ret
        exit_updatteenemy:  ret
    update_enemydifficulty endp


    ; _update_obsXpos must be called after value in randomNum is called to change the obstacles x position
    _update_obsXpos proc near
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
    _update_obsXpos endp

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
        call _update_obsXpos
        mov char_xfixedpos, 1
        mov char_y, 0098h
        mov score_ones, 0
        mov score_hund, 0
        mov score_tens, 0
        mov allowscore, 0
        ret
    default_gamevalue endp 

    gameover_input proc near
        mov ah, 00h
        int 16h                 ; get the pressed key
        cmp al, 'r'             ; compare with 's'
        je gameover_keypress       ; if equal, jump to keypress_detected
        cmp al, 'R'             ; compare with 'S'
        je gameover_keypress       ; if equal, jump to keypress_detected

        jmp gameover_input          ; if no keys pressed, keep jumping to menu_input

        gameover_keypress:
            mov game_state, 0
            call default_gamevalue
            call generateseed
            call _update_obsXpos
            ret
    gameover_input endp


    gameover_rendersprite proc near
            mov si, offset coin
            mov rendercoordX, 136
            mov rendercoordY, 80
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov si, offset coin
            mov rendercoordX, 148
            mov rendercoordY, 80
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov si, offset coin
            mov rendercoordX, 160
            mov rendercoordY, 80
            mov _rendersizeX, 9
            mov _rendersizeY, 9
            call _rendersprite

            mov si, offset Player_up
            mov rendercoordX, 144
            mov rendercoordY, 96
            mov _rendersizeX, 16
            mov _rendersizeY, 16
            call _rendersprite
    gameover_rendersprite endp


    gameover_printtext proc near        
            ;box
            mov ah, 02h     
            mov bh, 00h     
            mov dh, 02    
            mov dl, 13     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 05fh          ;character to print - solid line
            mov bh, 0          
            mov bl, 0fh             ;color
            mov cx, 14
            int 10h

            mov ah, 02h     
            mov bh, 00h     
            mov dh, 05    
            mov dl, 13     
            int 10h
            mov ah, 09h             ;config for writing text with color
            mov al, 05fh          ;character to print - solid line
            mov bh, 0          
            mov bl, 0fh             ;color
            mov cx, 14
            int 10h 

            mov bp, offset line1_over        ;game over...
            mov _stringx, 14
            mov _stringy, 4
            mov _stringcolor, 04h
            mov _stringlength, 12
            call _printtext

            mov bp, offset line2_over        ;score
            mov _stringx, 15
            mov _stringy, 16
            mov _stringcolor, 0fh
            mov _stringlength, 6
            call _printtext

            mov bp, offset line3_over       ;press r
            mov _stringx, 7
            mov _stringy, 18
            mov _stringcolor, 0fh
            mov _stringlength, 27
            call _printtext

        mov ah, 02h
        mov dh, 10h
        mov dl, 0Eh
        call .printscore
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
        mov dh, 0eh
        mov dl, 02h
        int 10h
        mov ah, 09h
        mov dx, offset line5_game       ;score
        int 21h
        call calculate_overallscore
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
            call _update_obsXpos
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

    	sub score_tens, 10
    	inc score_hund
    	cmp score_hund, 10
    	jl exit_increment
    
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