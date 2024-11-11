-- dna_type--1.0.sql

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION DNA" to load this file. \quit

/******************************************************************************
 * Input/Output
 ******************************************************************************/

/* CREATE FUNCTION dna_in(cstring) */
CREATE OR REPLACE FUNCTION dna_in(cstring) 
    RETURNS dna
    AS 'MODULE_PATHNAME', 'dna_in'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION dna_out(dna) 
    RETURNS cstring
    AS 'MODULE_PATHNAME', 'dna_out'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/* Should define here the from and to binary data functions
-- Define the receive function for dna type (converts binary data to internal dna representation)
CREATE OR REPLACE FUNCTION dna_recv(internal)
	RETURNS dna
    AS 'MODULE_PATHNAME', 'dna_recv'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Define the send function for dna type (converts internal dna representation to binary data)
CREATE OR REPLACE FUNCTION dna_send(dna) 
	RETURNS bytea
    AS 'MODULE_PATHNAME', 'dna_send'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
*/

CREATE TYPE dna (
    internallength = variable,
    input          = dna_in,
    output         = dna_out--,
   /* receive        = dna_recv,
    send           = dna_send */
);

-- Define cast function from text to dna. Not so sure about the naming convention here.
CREATE OR REPLACE FUNCTION dna(text) 
	RETURNS dna
    AS 'MODULE_PATHNAME', 'dna_cast_from_text'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Define cast function from dna to text. Not so sure about the naming convention here.
CREATE OR REPLACE FUNCTION text(dna) 
	RETURNS text
    AS 'MODULE_PATHNAME', 'dna_cast_to_text'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Add explicit casts using the functions. Not so sure about the naming convention here.
-- Does this somehow scramble the original CAST function? Or just adds functionality?
CREATE CAST (text AS dna) WITH FUNCTION dna(text) AS IMPLICIT;
CREATE CAST (dna AS text) WITH FUNCTION text(dna) AS IMPLICIT;

/****************************************************************************
 * Define dna_length function to get the size of a DNA sequence.
 * Not so sure about doing dna_length or just length. Same problem as above.
 * I think I solved this with the implicit casting from the code above.
 ****************************************************************************/
CREATE OR REPLACE FUNCTION dna_length(dna) 
    RETURNS integer
    AS 'MODULE_PATHNAME', 'dna_length'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;



