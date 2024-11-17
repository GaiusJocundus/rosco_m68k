;------------------------------------------------------------
;                                  ___ ___ _   
;  ___ ___ ___ ___ ___       _____|  _| . | |_ 
; |  _| . |_ -|  _| . |     |     | . | . | '_|
; |_| |___|___|___|___|_____|_|_|_|___|___|_,_| 
;                     |_____|       software v1                 
;------------------------------------------------------------
; Copyright (c)2020 Ross Bamford
; Updated 2024 remove CPU detection and use sdb block
; See top-level LICENSE.md for licence information.
;------------------------------------------------------------

    section .text

IIHANDLER:
    move.b  #1,IIFLAG                 ; Set the flag
    move.l  CONTADDR,(2,A7)           ; Update continue PC
    rte

BERR_HANDLER::
    move.w  D0,-(A7)
    move.w  ($8,A7),D0                ; Get format
    and.w   #$F000,D0                 ; Mask vector
    cmp.w   #$8000,D0                 ; Is it an 010 BERR frame?
    bne.w   .LFRAME                   ; Assume it's a longer (later CPU) frame if not
                                      ; For 020, this would be either A000 or B000 -
                                      ; for our purposes, they are equivalent. 
                                      ; TODO this might need checking again on later
                                      ; CPUs!

    move.w  ($A,A7),D0                ; If we're here, it's an 010 frame...                
    bset    #15,D0                    ; ... so just set the RR (rerun) flag
    move.w  D0,($A,A7)
    bra.s   .DONE 

.LFRAME:
    move.w  ($C,A7),D0                ; If we're here, it's an 020 frame...                
    bclr    #8,D0                     ; ... we only care about data faults here... Hopefully :D
    move.w  D0,($C,A7)    

.DONE
    move.b  #1,BERRFLAG
    move.w  (A7)+,D0
    rte


INSTALL_BERR_HANDLER::
    move.l  $8,SAVEDHANDLER
    move.l  #BERR_HANDLER,$8
    rts

RESTORE_BERR_HANDLER::
    move.l  SAVEDHANDLER,$8
    rts

    section .data,data
    align   2
SAVEDHANDLER    dc.l  0

    section .bss,bss
    align 4
IISAVED   ds.l    1
FLSAVED   ds.l    1
CONTADDR  ds.l    1
IIFLAG    ds.b    1 
