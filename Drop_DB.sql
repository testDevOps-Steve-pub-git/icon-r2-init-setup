-- DROP VIEWS

DROP VIEW IF EXISTS "retrieval_lookups" CASCADE;
DROP VIEW IF EXISTS "lot_lookups" CASCADE;
DROP VIEW IF EXISTS "immunization_lookups" CASCADE;
DROP MATERIALIZED VIEW IF EXISTS "cities_index" CASCADE;
DROP MATERIALIZED VIEW IF EXISTS "geocodes_index" CASCADE;
DROP MATERIALIZED VIEW IF EXISTS "schools_daycares_index" CASCADE;
DROP VIEW IF EXISTS "lots_index" CASCADE;
DROP VIEW IF EXISTS "trades_index" CASCADE;
DROP VIEW IF EXISTS "agents_index" CASCADE;
DROP VIEW IF EXISTS "diseases_index" CASCADE;

-- Drop lookup tables

DROP TABLE IF EXISTS "agents_diseases" CASCADE;
DROP TABLE IF EXISTS "trades_agents" CASCADE;
DROP TABLE IF EXISTS "lots" CASCADE;
DROP TABLE IF EXISTS "diseases" CASCADE;
DROP TABLE IF EXISTS "agents" CASCADE;
DROP TABLE IF EXISTS "trades" CASCADE;
DROP TABLE IF EXISTS "geocodes" CASCADE;
DROP TABLE IF EXISTS "schools_daycares" CASCADE;

-- Drop submission tables
DROP TABLE IF EXISTS "Submission_Attachment" CASCADE;
DROP TABLE IF EXISTS "Immun_Submission" CASCADE;

-- Drop process lock table

DROP TABLE IF EXISTS "process_lock" CASCADE;

-- Drop loading tables

DROP TABLE IF EXISTS "load_lots" CASCADE;
DROP TABLE IF EXISTS "lots_bak" CASCADE;
DROP TABLE IF EXISTS "load_schools_daycares" CASCADE;
DROP TABLE IF EXISTS "schools_daycares_bak" CASCADE;

-- Drop functions

DROP FUNCTION IF EXISTS load_lots();
DROP FUNCTION IF EXISTS load_schools_daycares();

-- Drop domain

DROP DOMAIN IF EXISTS prevalence_range;
