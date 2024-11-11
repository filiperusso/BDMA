#include <ctype.h>            // For character handling functions like toupper
#include <string.h>           // For standard string manipulation functions

#include "postgres.h"         // Core PostgreSQL definitions and API functions
#include "fmgr.h"             // Function manager interface for PostgreSQL functions
#include "utils/builtins.h"   // For text handling functions
#include "libpq/pqformat.h"   // For StringInfo and related binary I/O functions

PG_MODULE_MAGIC;              // PostgreSQL module magic to ensure binary compatibility

/*******************************************************************************************************/

/*
 * dna_validate_and_format
 * Helper function to validate that the input string contains only 'A', 'C', 'G', and 'T'.
 * It also converts the characters to uppercase for consistent storage.
 */
static void
dna_validate_and_format(char *str)
{   
    // Check for an empty string
    if (*str == '\0') { 
        ereport(ERROR,
                (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("Invalid input syntax for DNA sequence: empty string."),
                 errdetail("DNA sequences cannot be empty.")));
    }

    for (char *ptr = str; *ptr; ptr++)
    {
        // Convert to uppercase
        *ptr = toupper(*ptr);                   
        if (!(*ptr == 'A' || *ptr == 'C' || *ptr == 'G' || *ptr == 'T'))
        {
            ereport(ERROR,
                    (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                     errmsg("Invalid input syntax for DNA sequence."),
                     errdetail("DNA sequences must only contain 'A', 'C', 'G', or 'T'.")));
        }
    }
}

/*
 * dna_in
 * Input function for the DNA type. Converts a C string to a validated DNA sequence.
 */
PG_FUNCTION_INFO_V1(dna_in);
Datum
dna_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);             // Get input as C string
    dna_validate_and_format(str);                 // Validate and format the DNA sequence
    PG_RETURN_TEXT_P(cstring_to_text(str));       // Return the DNA sequence as a text type
}

/*
 * dna_out
 * Output function for the DNA type. Converts the DNA type (text) to a C string.
 */
PG_FUNCTION_INFO_V1(dna_out);
Datum
dna_out(PG_FUNCTION_ARGS)
{
    text *dna = PG_GETARG_TEXT_P(0);              // Get input as text type
    PG_RETURN_CSTRING(text_to_cstring(dna));      // Convert to C string and return
}

/*
 * dna_cast_from_text
 * Casts a text value to the DNA type. Validates and formats the input.
 */
PG_FUNCTION_INFO_V1(dna_cast_from_text);
Datum
dna_cast_from_text(PG_FUNCTION_ARGS)
{
    text *txt = PG_GETARG_TEXT_P(0);              // Get input as text
    char *str = text_to_cstring(txt);             // Convert text to C string
    dna_validate_and_format(str);                 // Validate and format the DNA sequence
    PG_RETURN_TEXT_P(cstring_to_text(str));       // Return validated DNA sequence as text
}

/*
 * dna_cast_to_text
 * Casts the DNA type to a text value. Useful for conversions between types.
 */
PG_FUNCTION_INFO_V1(dna_cast_to_text);
Datum
dna_cast_to_text(PG_FUNCTION_ARGS)
{
    text *dna = PG_GETARG_TEXT_P(0);              // Get input as DNA type (text)
    PG_RETURN_TEXT_P(dna);                        // Directly return as text
}

/* dna_length function to get the length of a DNA sequence. */
PG_FUNCTION_INFO_V1(dna_length);
Datum
dna_length(PG_FUNCTION_ARGS)
{
    text *dna = PG_GETARG_TEXT_P(0);             // Get the DNA sequence as a text argument
    int32 len = strlen(text_to_cstring(dna));    // Access the header directly to calculate the length
    PG_RETURN_INT32(len);                        // Return the length as an integer
}

/*******************************************************************************************************/
