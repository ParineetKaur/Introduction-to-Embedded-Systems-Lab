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
// ----------------------------------------------------------
// unsigned HalfWordAccess(int16_t *src) ;
// ----------------------------------------------------------

        .global     HalfWordAccess
        .thumb_func
        .align
HalfWordAccess:
            .rept           100             // repeats the process 100 times
            LDRH            R1, [R0]        // Used to load half-words (16 bits because it is LDRH) from memory
            .endr
            BX LR

// ----------------------------------------------------------
// unsigned FullWordAccess(int32_t *src) ;
// ----------------------------------------------------------
        .global     FullWordAccess
        .thumb_func
        .align
FullWordAccess:
            .rept           100             // repeats process 100 times
            LDR             R1, [R0]        // Used to load full words (32 bits) from memory
            .endr
            BX LR

// ----------------------------------------------------------
// unsigned NoAddressDependency(uint32_t *src) ;
// ----------------------------------------------------------

        .global     NoAddressDependency
        .thumb_func
        .align
NoAddressDependency:
            .rept           100           // repeats the process 100 times without address depdency
            // Loads data from memory pointed to by R0 without address dependency
            LDR             R1,[R0]
            LDR             R2,[R0]
            .endr
            BX LR
            // NoAddressDependency does not depend on one register to store data memory/address

// ----------------------------------------------------------
// unsigned AddressDependency(uint32_t *src) ;
// ----------------------------------------------------------

        .global     AddressDependency
        .thumb_func
        .align
AddressDependency:
            .rept           100             // repeats process 100 times with address dependency
            LDR             R1,[R0]         // Loads data from memory pointed to by R0
            LDR             R0,[R1]         // Loads data from memory pointed to by R1
           .endr
            BX LR
            //AddressDependency does not depend on one register to store data 
    
// ----------------------------------------------------------
// unsigned NoDataDependency(float f1) ;
// ----------------------------------------------------------

        .global     NoDataDependency
        .thumb_func
        .align
NoDataDependency:
            .rept           100               // 100 iterations of floating point addition without data depedency
            //Use VADD.F32 to perform floating point addition and store result in S1
            VADD.F32        S1,S0,S0
            //Use VADD.F32 to perform floating point addition and store result in S2
            VADD.F32        S2,S0,S0
            .endr
            VMOV            S1,S0            // Moves the result to S1
            BX LR

// ----------------------------------------------------------
// unsigned DataDependency(float f1) ;
// ----------------------------------------------------------

        .global     DataDependency
        .thumb_func
        .align
DataDependency:
            .rept           100             // 100 iterations of floating-point addition without dependency
            // Use VADD.F32 to perform floating point addition and store result in S1
            VADD.F32        S1,S0,S0
            // Use VADD.F32 to perform floating point addition and store result in S0
            VADD.F32        S0,S1,S1
            // Problem: S1 can not be used in arithemtic operations until it is not outputted
            .endr
            VMOV            S1,S0           // Moves the result to S1
            BX              LR 

// ----------------------------------------------------------
// void VDIVOverlap(float dividend, float divisor) ;
// ----------------------------------------------------------

        .global     VDIVOverlap
        .thumb_func
        .align
VDIVOverlap:
            VDIV.F32        S2,S1,S0        // Performs a floating-point division (`VDIV.F32`) of S1 to S0
            .rept           1
            // Includes a NOP instruction within a loop (1 repetition) for some delay
            NOP
            .endr
            VMOV            S3,S2           // Moves result to S3 which takes up 16 cycles  
            BX LR
        .end

// Results:
// Half word address = X…XX1 penalty: 2 cycles/instruction
// Total Penalty = Penalty for X...X00 (0) + Penalty for X...X00 (0) + Penalty for X...X10 (0) + Penalty for X...X11 (2)
// Explanation: Takes two cycles because of misalignment in memory. 
// Specifically, it Half-word (16-bit) data is more efficiently accessed when its address is a multiple of 2 (which means the LSB of the address is 0). 
// Here, the LSB is 1, represented as X...XX1. Therefore, the processor has to take some extra steps to access the data because the data is split across two memory bounds.

// Full word address = X…X01 penalty: 301 cycles/instruction
// Penalty = Misaligned Time−Aligned Time / 100​
// Exlanation: Becuase X...X00 is aligned, but X...X01 is not properly aligned. 
// The word is split into two physcial words, so processor gets 2 bytes at a time. 
// Generally, for a full-word access to be efficient, the data should be located at an address that is mulitple of 4 (which means it should end with 00). 
// Here, the address ends with 01 causing a misalignment of 1 byte. Therefore, one part of the word is fetched and other part (1 byte) is fetched afterwards. 
// The fetch does not happen in one operation.

// Full word address = X…X10 penalty: 201 cycles/instruction
// Penalty= Misaligned Time−Aligned Time / 100
// Explanation: Because X...X00 is properly algined and X...X10 has a trailing 10 alignment. 
// We know that 10 is not divisible by 4, which is required for a 32-bit word alignment. 
// The CPU, hence, takes 201 clock cycles to handle the misalignment

// Full word address = X…X11 penalty: 301 cycles/instruction
//  Penalty= Misaligned Time−Aligned Time / 100
// Explanation: Because X...X00 is properly aligned and X...X11 has a trailing 11 alignment. 
// We know that 11 is not a multiple of 4 because it is not divisible by 4. 
// The data, then, spans across two different memory blocks, so the CPU must perform additional operations to gather the full data. 

// Address dependency penalty: 400 cycles/instruction
// Address Dependecy Penalty = Address Dependency - No Dependency / Iterations
// Explanation: When we load from the memory, then we copy the value. 
// The problem is that we have to wait for previous instruction to finish. 
// In this case, this happens between LDR R1, [R0] and LDR R0, [R1] because the CPU cannot execute the second load until the first one is finished because R1 is not updated yet. 
// First memory access already takes many cycles and, on top of that, the second instruction has to execute as well after the massive delay.

// Data dependency penalty: 401 cycles/instruction
// Data Dependecy Penalty = Data Dependency - No Dependency / Iterations
// Explanantion: There is a problem that S1 can not be used in arithemtic operations until it is not outputted. 
// We must wait until the instruction finishes because we need the results from the previous instruction (similar to Address Dependency penalty). 

// Maximum VDIV/VSQRT overlap: 16  clock cycles
// Explanation: VDIC takes 14 cycles (free the process) and VMOV takes two more cycle in order to move the result. 
