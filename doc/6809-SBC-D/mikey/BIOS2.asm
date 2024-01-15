;-----------------------------------------------------------------------------
; Mini 6809 BIOS
; Mike Christle (c) 2014
;-----------------------------------------------------------------------------
;                        TERMS OF USE: MIT License
;-----------------------------------------------------------------------------
; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.
;-----------------------------------------------------------------------------

;===============================================================
ENABLE_IRQ        EQU   $EF
DISABLE_IRQ       EQU   $10
ENABLE_FIRQ       EQU   $BF
DISABLE_FIRQ      EQU   $40

;===============================================================
; UART Mode - BAUD Rate 28800
; CR10  =  11 = Reset UART
; CR10  =  10 = Clock divider, /64
; CR432 = 100 = 8N2
; CR65  =  01 = TX interrupt enabled
; CR7   =   1 = RX interrupt enabled
;---------------------------------------------------------------
UART_RESET        EQU   $03 ;%0_00_000_11
UART_TX_ENABLE    EQU   $B2 ;%1_01_100_10
UART_TX_DISABLE   EQU   $92 ;%1_00_100_10

UART_STAT         EQU   $8000
UART_CNTL         EQU   $8000
UART_DATA         EQU   $8001

UART_RX_READY     EQU   $01
UART_TX_EMPTY     EQU   $02
UART_ERROR        EQU   $70
UART_IRQ          EQU   $80

CHAR_LF           EQU   10
CHAR_CR           EQU   13

;===============================================================
PIA_DA            EQU   $8010
PIA_CA            EQU   $8011
PIA_DB            EQU   $8012
PIA_CB            EQU   $8013

;===============================================================
                  ORG   $7C00

RXBUF             RMB   $100
TXBUF             RMB   $100
CMDBUF            RMB   $100

FIRQ_VEC          RMB   2

RXTOP             RMB   1
RXBOT             RMB   1
TXTOP             RMB   1
TXBOT             RMB   1

POINTER           RMB   1
POINTERLO         RMB   1
TEMP0             RMB   1
TEMP1             RMB   1

;===============================================================
                  ORG   $9000

RESET_VEC
                  LDS   #$7C00

                  LDA   #UART_RESET
                  STA   UART_CNTL

                  CLR   RXTOP
                  CLR   RXBOT
                  CLR   TXTOP
                  CLR   TXBOT

                  LDA   #UART_TX_DISABLE
                  STA   UART_CNTL
                  ANDCC #ENABLE_IRQ

                  LDX   #HEADER
                  JSR   PUTS

CMND_LOOP         LDX   #PROMPT
                  JSR   PUTS

                  CLR   CMDBUF
                  LDX   #CMDBUF
                  LDA   #255
                  JSR   GETS

                  LDA   CMDBUF
                  ORA   #$20
                  CMPA  #'s'
                  BNE   CMND_LOOP_1
                  JSR   DOWNLOAD
                  BRA   CMND_LOOP

CMND_LOOP_1       CMPA  #'d'
                  BNE   CMND_LOOP_2
                  JSR   DUMPMEMORY
                  BRA   CMND_LOOP

CMND_LOOP_2       CMPA  #'r'
                  BNE   CMND_LOOP_3
                  JSR   0
                  BRA   CMND_LOOP

CMND_LOOP_3       CMPA  #'f'
                  BNE   CMND_LOOP
                  JSR   FILLMEMORY
                  BRA   CMND_LOOP

HEADER            FCB   "Mini 6809", CHAR_CR, 0
PROMPT            FCB   ">", 0

;===============================================================
UART_INT          PSHS  CC,A,B,X

                  LDA   UART_STAT
                  ANDA  #UART_RX_READY
                  BEQ   UART_INT_1

                  LDA   UART_DATA
                  LDX   #RXBUF
                  LDB   RXTOP
                  STA   B, X

                  INCB 
                  CMPB  RXBOT
                  BEQ   UART_INT_1
                  STB   RXTOP

UART_INT_1        LDA   UART_STAT
                  ANDA  #UART_TX_EMPTY
                  BEQ   UART_INT_X

                  LDB   TXBOT
                  CMPB  TXTOP
                  BNE   UART_INT_2

                  LDA   #UART_TX_DISABLE
                  STA   UART_CNTL
                  BRA   UART_INT_X

UART_INT_2        LDX   #TXBUF
                  LDA   B, X
                  STA   UART_DATA
                  INCB
                  STB   TXBOT

UART_INT_X        PULS  CC,A,B,X
                  RTI

;===============================================================
; Input     X = Pointer to string buffer
;           A = Max buffer size
; Output    None
;---------------------------------------------------------------
GETS              PSHS  B

GETS_1            BSR   GETC
                  TSTB
                  BEQ   GETS_1

                  CMPB  #CHAR_CR
                  BEQ   GETS_X

                  STB   ,X+
                  DECA
                  BNE   GETS_1

GETS_X            CLR   ,X
                  PULS  B
                  RTS

;===============================================================
; Input     None
; Output    B = Value, or Zero if fail
;---------------------------------------------------------------
GETC              PSHS  A, X
                  CLRB
                  LDA   RXBOT
                  CMPA  RXTOP
                  BEQ   GETC_X

                  LDX   #RXBUF
                  LDB   A, X
                  INCA
                  STA   RXBOT

GETC_X            PULS  A, X
                  RTS

;===============================================================
; Input     X = Pointer to string
; Output    None
;---------------------------------------------------------------
PUTS              PSHS  B

PUTS_1            LDB   ,X+
                  BEQ   PUTS_X

                  BSR   PUTC
                  BRA   PUTS_1

PUTS_X            PULS  B
                  RTS

;===============================================================
; Input     B = Value
; Output    None
;---------------------------------------------------------------
PUTC              PSHS  A, X

PUTC_1            LDA   TXTOP
                  INCA
                  CMPA  TXBOT
                  BNE   PUTC_2

                  ANDCC #ENABLE_IRQ
                  SYNC
                  BRA   PUTC_1

PUTC_2            DECA
                  LDX   #TXBUF
                  STB   A, X
                  INCA
                  STA   TXTOP
                  LDA   #UART_TX_ENABLE
                  STA   UART_CNTL

PUTC_X            PULS  A, X
                  RTS

;===============================================================
DOWNLOAD          LDX   #CMDBUF
                  LDB   ,X+         ;Skip 'S'
                  CLR   TEMP1       ;Clear checksum

                  LDB   ,X+         ;Get record type
                  CMPB  #'1'
                  BNE   DOWNLOAD_X  ;Exit on end record

                  JSR   SCANHEX
                  TFR   B, A        ;Byte count
                  SUBA  #3          ;Sub address and count
                  ADDB  TEMP1
                  STB   TEMP1

                  JSR   SCANHEX
                  STB   POINTER
                  ADDB  TEMP1
                  STB   TEMP1

                  JSR   SCANHEX
                  STB   POINTERLO
                  ADDB  TEMP1
                  STB   TEMP1

                  LDY   POINTER

DOWNLOAD_1        JSR   SCANHEX
                  STB   ,Y+
                  ADDB  TEMP1
                  STB   TEMP1
                  DECA
                  BNE   DOWNLOAD_1

                  JSR   SCANHEX
                  ADDB  TEMP1
                  INCB
                  BEQ   DOWNLOAD_X

                  LDB   #'X'
                  JSR   PUTC

DOWNLOAD_X        RTS

;===============================================================
; Input     X = Pointer to string
; Output    B = Value
;           X = X + 2
;---------------------------------------------------------------
SCANHEX           LDB   ,X+
                  BSR   HEX2INT
                  LSLB
                  LSLB
                  LSLB
                  LSLB
                  STB   TEMP0
                  LDB   ,X+
                  BSR   HEX2INT
                  ORB   TEMP0
                  RTS

;===============================================================
; Input     B = ASCII Hexidecimal character
; Output    B = Value
;---------------------------------------------------------------
HEX2INT           ORB   #$20
                  SUBB  #$30
                  CMPB  #10
                  BLO   HEX2INT_X

                  SUBB  #39

HEX2INT_X         RTS

;===============================================================
DUMPMEMORY        LDX   #0
                  LDA   #8
                  
DUMPMEMORY_1      PSHS  A
                  LDA   #16
                  PSHS  X
                  PULS  B
                  JSR   PRINTHEX
                  PULS  B
                  JSR   PRINTHEX

DUMPMEMORY_2      LDB   #' '
                  JSR   PUTC
                  LDB   ,X+
                  JSR   PRINTHEX
                  DECA
                  BNE   DUMPMEMORY_2

                  LDB   #CHAR_CR
                  JSR   PUTC

                  PULS  A
                  DECA
                  BNE   DUMPMEMORY_1

                  RTS

;===============================================================
; Input     B = Number to print in HEX
; Output    None
;---------------------------------------------------------------
PRINTHEX          PSHS  X
                  LDX   #PRINTHEX_T

                  PSHS  B
                  LSRB
                  LSRB
                  LSRB
                  LSRB
                  LDB   B, X
                  JSR   PUTC

                  PULS  B
                  ANDB  #15
                  LDB   B, X
                  JSR   PUTC

                  PULS  X
                  RTS

PRINTHEX_T        FCB   "0123456789ABCDEF"

;===============================================================
FILLMEMORY        LDX   #0
                  CLRA

FILLMEMORY_1      STA   ,X+
                  INCA
                  BNE   FILLMEMORY_1

                  RTS

;===============================================================
NMI_INT           RTI

;===============================================================
FIRQ_INT          PSHS  Y
                  LDY   FIRQ_VEC
                  JSR   ,Y
                  PULS  Y
                  RTI

;===============================================================
SWI2_VEC          RTI
SWI3_VEC          RTI
SWI_VEC           RTI

;===============================================================
                  ORG   $FF00

VECTOR_TABLE      FDB   PUTC
                  FDB   GETC
                  FDB   PUTS
                  FDB   GETS

;===============================================================
                  ORG   $FFF0
                  FDB   0
                  FDB   SWI3_VEC
                  FDB   SWI2_VEC
                  FDB   FIRQ_INT
                  FDB   UART_INT    ;IRQ_VEC
                  FDB   SWI_VEC
                  FDB   NMI_INT
                  FDB   RESET_VEC
