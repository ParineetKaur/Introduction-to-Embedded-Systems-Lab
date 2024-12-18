#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const int len = 8;
static const char hex[] = "0123456789ABCDEF";


// Alternative Method Used: Creating magnitude to string conversion helper function
// Usage: In Bits2OctalString, Bits2UnsignedString and Bits2HexString
// Based on specfic radix given to it

void unsignedMagnitudetoString(uint8_t bits, int radix, char string[]) {
    char v[8] = { 0 };
    int c = 0;
    // Handle zero case
    if (bits == 0) {
        string[0] = '0'; // If the number is zero, return "0"
        string[1] = '\0'; // Null-terminate the string
        return;
    }

    // to extract each digit of the number in the given base.
    while (bits != 0) {
        v[c++] = hex[bits % radix]; // Convert the remainder to a character and store it in 'v'
        bits /= radix;
    }

    if (radix == 2) {
        while (c < len) {
            v[c++] = '0'; // Append '0' to 'v' until it reaches the desired length.
        }
    }

    for (int k = 0; k < c; k++) {
        string[k] = v[c - k - 1];
    }

    string[c] = '\0'; // Null-terminate the string
    // Fill with zeros if less than len
    for (int i = c + 1; i < len; i++) {
        string[i] = '0';
    }
    string[len] = '\0'; // Ensure null termination in case the loop above changes it for some reason
}

//radix 8
void Bits2OctalString(uint8_t bits, char string[]){
    unsignedMagnitudetoString(bits, 8, string);
}

//radix 16
void Bits2HexString(uint8_t bits, char string[]){
    unsignedMagnitudetoString(bits, 16, string);
}

//radix 10
void Bits2UnsignedString(uint8_t bits, char string[]){
    unsignedMagnitudetoString(bits, 10, string);
}

// The function below is used to convert the bits to a ones' complement string
void Bits2TwosCompString(uint8_t bits, char string[]){
    char b[8]; // stores the binary representation of the bits 
    int i = len - 1; 
    unsignedMagnitudetoString(bits, 2, b);
   // Check if the number is positive
    if (b[0] == '0') {
        unsignedMagnitudetoString(bits, 10, string);
    }
    else {
        char mag[8]; 
        while (b[i] == '0' && i >= 0) {
            mag[i] = '0';
            i--;
        }
        mag[i] = '1';
        i--;
        while (i >= 0) {
            if (b[i] == '0')
                mag[i] = '1';
            else
                mag[i] = '0';
            i--;
        }

        //Convert new to decimal
        int v = 1;
        int m = 0;
        for (int x = len - 1; x >= 0; x--) {
            if (mag[x] == '1')
                m += v;
            v *= 2;
        }
        unsignedMagnitudetoString(m, 10, mag); // Convert the magnitude to a string
        string[0] = '-';
        for (int j = 1; j < len; j++){
            string[j] = mag[j-1]; // Copy the magnitude to the output string
        }
    }
}

// The function below is used to convert the bits to a sign-magnitude string
void Bits2SignMagString(uint8_t bits, char string[]) {
    char b[8]; 
    int m = 0;
    unsignedMagnitudetoString(bits, 2, b);
    if (b[0]== '0') { // Check if the number is positive
        string[0] = '+';
        m= bits;
    }
    else { // Check if the number is negative
        string[0] = '-';
        m= bits - 128;
    }
    char magnitude[8];
    unsignedMagnitudetoString(m, 10, magnitude); // Convert the magnitude to a string
    for (int j = 1; j < len; j++){
        string[j] = magnitude[j - 1]; // Copy the magnitude to the output string
    }
}
