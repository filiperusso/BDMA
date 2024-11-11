-- Remove extension and table, if needed.
DROP EXTENSION dna_type CASCADE;
DROP TABLE dna_sequences;

-- Add extension, create table with dna type and populate it.
CREATE EXTENSION dna_type;

CREATE TABLE dna_sequences (
    id serial PRIMARY KEY,
    sequence dna
);

INSERT INTO dna_sequences (sequence) VALUES ('ACGT');
INSERT INTO dna_sequences (sequence) VALUES ('GATTACA');
INSERT INTO dna_sequences (sequence) VALUES ('CCGGTTAA');

SELECT *
FROM dna_sequences;

INSERT INTO dna_sequences (sequence) VALUES ('AAAA'::dna);
INSERT INTO dna_sequences (sequence) VALUES ('cCcC'); -- example of implicit casting

SELECT length('A');
SELECT length('a');
SELECT dna_length('aTatA'::dna);

-- solved this with implicit casting, not sure if done right though.
-- may have scrambled the cast function instead of length one.
SELECT length('aTatA'::dna); 

-- some input output tests
SELECT dna_out(dna_in('A'));
SELECT dna_in('t');

-- some casting tests
SELECT dna_in('t')::text;
SELECT text('a')::dna;

SELECT dna('c');
SELECT text('c'::dna);

SELECT CAST('a'::DNA AS text);
SELECT CAST('a'::DNA::text AS DNA);

-- testing if the DNA data type only accepts adequate strings
SELECT dna('');
SELECT dna('b');


