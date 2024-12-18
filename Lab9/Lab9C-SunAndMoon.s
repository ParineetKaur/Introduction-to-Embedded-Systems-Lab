/*
    This code was written to support the book, "ARM Assembly for Embedded Applications",
    by Daniel W. Lewis. Permission is granted to freely share this software provided
    that this notice is not removed. This software is intended to be used with a run-time
    library adapted by the author from the STM Cube Library for the 32F429IDISCOVERY 
    board and available for download from http://www.engr.scu.edu/~dlewis/book3.
*/
        .syntax         unified
        .cpu            cortex-m4
        .text

/* 
  What the function does - computes the Eccentric Anomaly (denoted as E) given the eccentricity (e) and the Mean Anomaly (M)
  float EccentricAnomaly(float e, float M)
*/

    

        .global         EccentricAnomaly
        .thumb_func
        .align
EccentricAnomaly:   // S0 = e, S1 = M
        PUSH            {LR}            
        VPUSH           {S16-S18}       // Saves the floating-point registers S16, S17, and S18 
        VMOV            S16, S0
        VMOV            S17, S1
        VMOV            S0, S17
        BL              sinDeg          
        VMOV            S18, S0
        VMOV            S0, S17
        BL              cosDeg
        VMUL.F32        S0, S0, S16     
        VMOV            S1, 1.0
        VADD.F32        S0, S0, S1
        VMUL.F32        S0, S0, S16
        VMUL.F32        S0, S0, S18
        BL              Rad2Deg         // Add the results together and convert the final result 
        VMOV            S1, S17         // moves the Mean Anomaly (M) back into S1
        VADD.F32        S0, S0, S1
        VPOP            {S16-S18}
        POP             {PC}

// float Kepler(float m, float ecc)

        .global         Kepler
        .thumb_func
        .align
Kepler: // S0 = m, S1 = ecc
        PUSH            {R3,LR}
        VPUSH           {S16-S19}
        VMOV            S16,S1          // S16 = ecc
        BL              Deg2Rad         // S0  = Deg2Rad(m)
        VMOV            S17,S0          // S17 = m
        VMOV            S18,S0          // S18 = e
top:    VMOV            S0,S18          // S0  = e
        BL              sinf            // S0  = sinf(e)
        VMUL.F32        S1,S0,S16       // S1  = ecc*sinf(e)
        VSUB.F32        S1,S18,S1       // S1  = e - ecc*sinf(e)
        VSUB.F32        S19,S1,S17      // S19 = delta = e - ecc*sinf(e) - m
        VMOV            S0,S18          // S0  = e
        BL              cosf            // S0  = cosf(e)
        VMOV            S1,1.0          // S1  = 1.0
        VMLS.F32        S1,S16,S0       // S1  = 1.0 - ecc*cosf(e)
        VDIV.F32        S0,S19,S1       // S0  = delta / (1.0 - ecc*cosf(e)
        VSUB.F32        S18,S18,S0      // S18 = e = e - delta / (1.0 - ecc*cosf(e)
        VABS.F32        S0,S19          // S0  = fabsf(delta)
        VLDR            S1,epsilon      // S1  = epsilon
        VCMP.F32        S0,S1           // fabs(delta) > epsilon?
        VMRS            APSR_nzcv,FPSCR
        BGT             top
        VMOV            S0,S18
        VPOP            {S16-S19}
        POP             {R3,PC}

        .align
epsilon:
        .float          1E-6

        .end
