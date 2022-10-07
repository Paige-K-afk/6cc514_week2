# we are still in a 16 bit processor, 
# but we've broken out of the first part of the bootloader
# and are into the second stage. 

.code16                         # Assemble for 16-bit mode
.globl start
start:
    jmp     real_start


# Write to the console using BIOS.
# Input: SI contains the address of the null-terminated string to be displayed
# I Could use an include, but I won't.

cons_write:
    movb    $0x0e, %ah           # 0x0e is the INT 10h BIOS call to output the value contained in AL to screen

cons_write_rpt:
    movb    (%si), %al          # Load the byte at the location contained in the SI register into AL   
    inc     %si                 # Add 1 to the value in SI
    cmp     $0, %al             # Compare the value in AL with 0
    jz      cons_write_done     # If it is zero, then we are done
    int     $0x10               # Output the character in AL to the screen
    jmp     cons_write_rpt      # and continue

cons_write_done:                # Something that is called will never return 
    ret                         # until a 'ret' instruction is encountered.  Labels do 
                                # not give a program any structure.  They just give a 
                                # memory location a name that we can use in our code. 

cons_write_crlf:
    movb    $0x0e, %ah          # Output CR
    movb    $0x0d, %al
    int     $0x10
    movb    $0x0a, %al          # Output LF
    int     $0x10
    ret

cons_writeline:
    call    cons_write
    call    cons_write_crlf
    ret    

display_disk_message:
    movw    $reading_from_disk_drive_msg, %si  # Send in disk drive message
    jmp display_messages_decided

real_start:
    movw    $second_stage_msg, %si  # Display our Second Stage message
    call    cons_writeline
    cmp     $0, %dl
    jnz display_disk_message    # to hard disk
    movw    $reading_from_floppy_msg, %si  # Send in floppy disk message
display_messages_decided:
    call    cons_writeline

    # where things will continue from.

endless_loop:                   # Loop forever more
    jmp     endless_loop   

second_stage_msg:
.string "Second Stage V1.0"

reading_from_floppy_msg:
.string "Reading From Floppy Disk"
reading_from_disk_drive_msg:
.string "Reading From Disk Drive"