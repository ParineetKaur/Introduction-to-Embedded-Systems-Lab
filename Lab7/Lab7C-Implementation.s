        .syntax     unified
        .cpu        cortex-m4
        .text

// void PutNibble(void *nibbles, uint32_t index, uint32_t nibble) ;

        .global     PutNibble
        .thumb_func
        .align

// ANDEQ has EQ condition code, so it will only execute if the condition code is equal
// ORREQ has EQ condition code, so it will only execute if the condition code is equal
// ANDNE has NE condition code, so it will only execute if the condition code is not equal
// Similar for other cases

// General Explanation for PutNibble
// Since each byte contains two nibbles, the function first determines which byte and nibble (upper or lower) to target based on the given index.
// To do this, we calculate the address of the target byte by dividing the index by 2 (using a right shift operation) and add this offset to the base address of the array.
// We then loads the target byte into a register.
// Check whether the nibble is the upper or lower one by isolating the least significant bit of the index
// Upper Nibble: Shift left 4 bits
// Lower Nibble: Clear the lower nibble and insert the newer nibble in the same way

PutNibble:
	PUSH    {R4, LR}                // Save R4 and LR
    ADD 	R4, R0, R1, LSR 1       // R4 = nibbles + (index >> 1)
    LDRB	R3, [R4]                // R3 = *R4
    AND 	R1, R1, 1               // R1 = index & 1
    CMP 	R1, 1                   // if (index & 1)
    IT      EQ                      // then
    LSLEQ   R2, R2, 4               // nibble = nibble << 4
    CMP     R1, 1                   // if (index & 1)
    ITTEE   EQ                      // then
    ANDEQ   R3, R3, 0b00001111      // *R4 = *R4 & 0x0F (using a mask input here)
    ORREQ	R3, R3, R2              // *R4 = *R4 | nibble
    ANDNE   R3, R3, 0b11110000      // else
    ORRNE   R3, R3, R2              // *R4 = *R4 | nibble
    STRB    R3, [R4]                // *R4 = R3
    POP     {R4, PC}                // Restore R4 and PC

// uint32_t GetNibble(void *nibbles, uint32_t index) ;

        .global     GetNibble
        .thumb_func
        .align

// General Explanation for GetNibble:
// We determine whether the nibble is in the lower or upper half of the byte by isolating the least significant bit of the index
// Upper Nibble: Shift left 4 bits
// AND to isolate the 4-bit nibble, ensuring no extra bits remain after this

GetNibble:
    LSR     R3, R1, 1               // R3 = index >> 1 (divide by 2)
    LDRB    R2, [R0, R3]            // R2 = *(nibbles + (index >> 1))
    AND     R1, R1, 1               // R1 = index & 1 (check if index is odd or even)
    CMP     R1, 1                   // Compare (is index odd?)
    IT      EQ                      // If index is odd, execute following instruction
    LSREQ   R2, R2, 4               // If odd, shift R2 right by 4 bits to get the upper nibble
    AND     R2, R2, 0x0F            // Mask lower nibble (R2 now holds the nibble)
    MOV     R0, R2                  // Return in R0 because needed for returning 
    BX      LR                      
        
    .end
