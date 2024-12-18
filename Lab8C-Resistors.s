/*
    This code was written to support the book, "ARM Assembly for Embedded Applications",
    by Daniel W. Lewis. Permission is granted to freely share this software provided
    that this notice is not removed. This software is intended to be used with a run-time
    library adapted by the author from the STM Cube Library for the 32F429IDISCOVERY 
    board and available for download from http://www.engr.scu.edu/~dlewis/book3.
*/
        .syntax     unified
        .cpu        cortex-m4
        .text

// uint32_t Mul32X10(uint32_t multiplicand) ;

        .global     Mul32X10
        .thumb_func
        .align
Mul32X10:                                   // unsigned multiplication by 10
        ADD         R0, R0, R0, LSL 2       // Multiplies R0 by 5 (R0 + 4 * R0)
        LSL         R0, R0, 1               // Doubles the value: 10 * R0
        BX          LR

// uint32_t Mul64X10(uint32_t multiplicand) ;

        .global     Mul64X10
        .thumb_func
        .align
Mul64X10:                                   // 64-bit multiplication by 10 using shifts and addition 
        PUSH        {R4, R5, LR}
        LSL         R3, R1, 3               // R3 = R1 * 8 (higher 32 bits) 
        LSR         R2, R0, 29              // Extracts the top 3 bits of R0 by shifting right by 29 bits.
        ORR         R3, R2, R3              // Combines the top 3 bits of R0 (R2) with R3
        LSL         R2, R0, 3               // R2 = R0 * 8 (lower 32 bits)
        LSL         R5, R1, 1               // Multiplies the upper part (R1) by 2.
        LSR         R4, R0, 31              // Extracts the top bit of R0 by shifting right by 31 bits
        ORR         R5, R4, R5              // Combines the top bit of R0 with the upper part (R5)
        LSL         R4, R0, 1               // Multiplies the lower part (R0) by 2
        ADDS        R0, R2, R4              // Add low parts: R0 = R0*8 + R0*2 = R0*10
        ADC         R1, R3, R5              // Add upper parts: R1 = R1*8 + R1*2 + carry = R1*10
        POP         {R4, R5, PC}

// uint32_t Div32X10(uint32_t dividend) ;

        .global     Div32X10
        .thumb_func
        .align
Div32X10:
        LDR         R1,=3435973837          // Loads the number into R1 (precomputed constant used for division)
        UMULL       R2,R1,R1,R0             // Performs unsigned 32-bit multiplication of R1 and R0 (dividend).
        LSRS.N      R0,R1,3                 // Right-shifts the upper part of the result by 3 bits to compute R0 = result/2^3
        BX          LR

        .end