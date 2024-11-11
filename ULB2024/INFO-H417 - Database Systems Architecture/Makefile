EXTENSION = dna_type          # The name of the extension
DATA = dna_type--1.0.sql      # SQL file for defining the extension
MODULES = dna_type            # C file name without extension

# Set PostgreSQL configuration path
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

