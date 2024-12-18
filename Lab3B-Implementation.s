        .syntax         unified
        .cpu            cortex-m4
        .text


// int32_t Return32Bits(void) ;
        .global         Return32Bits
        .thumb_func
        .align

// The following function returns the integer 10 
Return32Bits:
	//Implementation Code
        // Load 10 into R0
        LDR 	       R0,=10                   // Load 10 into R0      
        BX             LR


// int64_t Return64Bits(void) ;
        .global         Return64Bits
        .thumb_func
        .align

// The following function returns the integer -10 
Return64Bits:
	//Implementation
    LDR 	        R0,=-10		                // Load 10 into R0
	LDR 	        R1,=-1		                // Load -1 into R1 to represent 0xFFFFFFFF in 32-bit representation
    // Returning a 64-bit signed integer, then R1 represents the upper 32 bits. Setting R1 to -1 corresponds to 0xFFFFFFFF in 32-bit representation
    BX              LR 


// uint8_t Add8Bits(uint8_t x, uint8_t y) ;
        .global         Add8Bits
        .thumb_func
        .align

// The following function sums 2 8-bit integers
Add8Bits:
	    //Implementation
        ADD             R0, R0, R1                   // Add x and y, store the result in R0 
        // AND is faster than MOV, so used this 
        AND             R0, R0, #0xFF               // lower 8 bits are kept because the function should return an 8-bit value
        // 0xFF is used to to isolate a byte in an integer, by truncating the integer to one byte's worth of 1's
        BX              LR                          


// uint32_t FactSum32(uint32_t x, uint32_t y) ;
        .global         FactSum32
        .thumb_func
        .align

// The following function returns the factorial of the sum of two integers
FactSum32:
	    //Implementation 
        PUSH            {R4, LR}                       
        ADD             R0, R0, R1                    // Add x and y, store the result in R0
        BL              Factorial                    // Call FactSum32 function to calculate the factorial of the sum
        POP             {R4, PC}                    //  Restore R4 and return to the caller
        BX              LR 


// uint32_t XPlusGCD(uint32_t x, uint32_t y, uint32_t z) ;
        .global         XPlusGCD
        .thumb_func
        .align

// The following function returns the sum of two integers and GCD 
XPlusGCD:
	//Implementation
    PUSH 	        {R4, LR}
	MOV 	        R4, R0		            // Store value of x in R4 to be used later
	MOV 	        R0, R1	               // Store value of y in R0 to be used in the Factorial function
	MOV 	        R1, R2	              // Store value of z in R1 to be used in the Factorial function
	BL 		        gcd	                 // Call gcd function to calculate the GCD of y and z
	ADD 	        R0, R0, R4	        // Add x to the result of the GCD
	POP 	        {R4, PC}	       // Restore R4 and return to the caller
    BX              LR 

    .end


