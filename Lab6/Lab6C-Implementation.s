// void CopyCell(uint32_t *dst, uint32_t *src) ;        // R0 = dst, R1 = src

            .syntax     unified
            .cpu        cortex-m4
            .text

            .global     CopyCell
            .thumb_func
            .align

CopyCell:   
    // Save R4 and LR on stack because we will use them in this function
    PUSH    {R4-R11}                // Push registers R4-R11 and Link Register (LR) onto the stack to save their current state 
                                    // for later restoration at the end of the function.
    MOV     R2, 60                  // row count = 60

NextRow1:   
    // Each pair of LDMIA and STMIA loads 40 bytes (4 bytes per register * 10 registers).
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}
    LDMIA       R1!, {R3-R12}
    STMIA       R0!, {R3-R12}

    ADD         R0, R0, 720                                     // Compute offset (4*240-60)
    ADD         R1, R1, 720
    SUBS.N      R2, R2, 1
    BNE         NextRow1                                      // Decrement row counter and check if we are done. If not done with the rows, repeat

    // Restore registers and return
    POP         {R4-R11}
    BX          LR 

// void FillCell(uint32_t *dst, uint32_t color) ;           // R0 = dst, R1 = color

            .global     FillCell
            .thumb_func
            .align      
 
FillCell:   
    MOV         R2, 60                                      // row count = 60

NextRow2:   
    MOV         R3, 30                                  // column counter = 60 

NextCol2:   
    // Store the color (R1) to the current destination (R0)
    STRD        R1, R1, [R0], 8                      // Store color at the position in current column
    
    SUBS.N      R3, R3, 1                           // Decrement column counter R3 and check if it reached zero. If not, repeat for the next column.
    BNE         NextCol2                            // If not done with the columns, then repeat
    ADD         R0, R0, 720                         // Compute offset (4*240-60)
    SUBS.N      R2, R2, 1
    BNE         NextRow2
    BX          LR

    .end














