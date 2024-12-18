.syntax     unified
			.cpu        cortex-m4
			.text
			.global     MxPlusB
			.thumb_func
			.align

// int32_t MxPlusB(int32_t x, int32_t mtop, int32_t mbtm, int32_t b) ;
// R0 -> x, R1 -> mtop, R2 -> mbtm, R3 -> b
// The function calculates the result of the equation mtop * x + b and then divides the result by mbtm.

MxPlusB:	
            // We need R4-R12 and LR because we are using them to store values of the variables each time we perform an operation
            PUSH		{R4-R12, LR}	    // Save registers because we are using them and we need to restore them before returning
            // Multiply mtop by x and store in R4
			MUL			R4, R1, R0		    // R4 = mtop * x (the numerator)
            // Multiply by mbtm and store in R5
			SMMUL		R5, R4, R2		    // R5 = dvnd * dvsr = (mtop * x) * mbtm
            // Checking if result is negative and store in R6
			ASR			R6, R5, 31		    // R6 = (dvnd * dvsr) >> 31 (sign check)
            // If the result is negative, multiply by mbtm and store in R7 and if positive, shift by 1 and store in R8
			MUL 		R7, R6, R2		    // R7 = (sign adjustment) * mbtm
            // Use the below to check if the sign is positive
			LSL			R8, R7, 1		    // R8 = (sign adjustment) << 1
            // Step 5: If the result is positive, shift by 1
            // ADD the sign adjustment to the divisor
			ADD			R9, R8, R2		    // R9 = rounding = (sign adjustment + dvsr)
            // Step 6: Load 2 into R4 because we need to divide by 2
			LDR			R4, =2			    
            // Divide the result by 2 and store in R10
			SDIV		R10, R9, R4	
            // Multiply by mtop and store in R11
			MUL			R11, R1, R0 
            // Add the result to the divisor and store in R12	 
			ADD			R12, R11, R10
            // Divide the result by mbtm and store in R0	    
			SDIV		R0, R12, R2	
			ADD			R0, R0, R3	        // R0 = (mtop * x + b) / mbtm. Add b to the result which will be stored in R0 and return it	
            POP			{R4-R12, PC}	    // Restore registers and return PC to the caller

            .end

