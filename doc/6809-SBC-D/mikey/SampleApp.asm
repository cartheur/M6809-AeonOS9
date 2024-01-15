            org   0

            LDB   #'A'
            BSR   PUTC

            LDX   #MSG
            BSR   PUTS

INLOOP      BSR   GETC
            TSTB
            BEQ   INLOOP
            
            BSR   PUTC

            LDX   #BUFR
            LDA   #100
            BSR   GETS

            LDX   #BUFR
            BSR   PUTS

            RTS
                
MSG         FCB   "HELLO",13,0

            INCLUDE "BIOS_IF.asm"

BUFR        RMB   100
