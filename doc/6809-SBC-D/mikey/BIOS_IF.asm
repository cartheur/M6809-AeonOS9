;-----------------------------------------------------------------------------
; Mini 6809 BIOS Interface
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

PIA_PORTA         EQU   $8010
PIA_CNTLA         EQU   $8011
PIA_PORTB         EQU   $8012
PIA_CNTLB         EQU   $8013
FIRQ_VEC          EQU   $7F00

;---------------------------------------------------------------
; Put char to console
; Input: B = Char
PUTC              LDY   $FF00 
                  JSR   ,Y
                  RTS

;---------------------------------------------------------------
; Get char from console
; Output: B = Char
GETC              LDY   $FF02
                  JSR   ,Y
                  RTS

;---------------------------------------------------------------
; Put string  to console
; Input: X = String pointer
PUTS              LDY   $FF04 
                  JSR   ,Y
                  RTS

;---------------------------------------------------------------
; Get string from console
; Input: X = String pointer
;        A = Max char count
GETS              LDY   $FF06
                  JSR   ,Y
                  RTS
