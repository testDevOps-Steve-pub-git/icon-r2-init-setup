-- SET STATEMENT BEHAVIORS ---------------------------------------------------------------------------------
-- 
SET statement_timeout = 0;
SET lock_timeout = 0;
--SET idle_in_transaction_session_timeout = 0; // pg 9.6+ only
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET search_path = public, pg_catalog;

-- CREAT EXTENSIONS ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA pg_catalog;

-- DROP SCHEMA ---------------------------------------------------------------------------------
-- DROP SCHEMA IF EXISTS public CASCADE;
-- CREATE SCHEMA public;

-- CREATE DATA TYPE ----------------------------------------------------------------------------
DROP DOMAIN IF EXISTS prevalence_range;
CREATE DOMAIN prevalence_range AS smallint
CHECK (VALUE >= 1 AND VALUE <= 9 OR NULL);

-- CREATE TABLES -------------------------------------------------------------------------------

CREATE TABLE trades
(
  snomed bigint,
  friendly_en_name varchar (100),
  friendly_fr_name varchar (100),
  manufacturer varchar (100),
  ontario_start_year int,
  ontario_finish_year int,
  prevalence_index prevalence_range,
  panorama_name varchar (100),
  CONSTRAINT trades_pkey PRIMARY KEY (snomed)
);

CREATE TABLE agents
(
    snomed bigint,
    short_en_name varchar (100),
    short_fr_name varchar (100),
    long_en_name varchar (100),
    long_fr_name varchar (100),
    is_user_view boolean,
    prevalence_index prevalence_range,
    ontario_start_year int,
    ontario_finish_year int,
  CONSTRAINT agents_pkey PRIMARY KEY (snomed)
);

CREATE TABLE diseases
(
  snomed bigint,
  friendly_en_name varchar (100),
  friendly_fr_name varchar (100),
  yellow_card_order prevalence_range,
  CONSTRAINT diseases_pkey PRIMARY KEY (snomed)
);

CREATE TABLE lots
(
  lot_id serial,
  lot_number varchar(15),
  expiry date,
  agent_snomed bigint,
  trade_panorama_name varchar(100),
  CONSTRAINT lots_pkey PRIMARY KEY (lot_id)
);

CREATE TABLE trades_agents
(
    agent_snomed bigint,
  trade_snomed bigint,
  CONSTRAINT trades_agents_pkey PRIMARY KEY (agent_snomed, trade_snomed),
  CONSTRAINT agents_fkey FOREIGN KEY (agent_snomed)
    REFERENCES agents(snomed) ON DELETE CASCADE,
  CONSTRAINT trades_fkey FOREIGN KEY (trade_snomed)
    REFERENCES trades(snomed) ON DELETE CASCADE
);

CREATE TABLE agents_diseases
(
    agent_snomed bigint,
    disease_snomed bigint,
  CONSTRAINT agents_diseases_pkey PRIMARY KEY (agent_snomed, disease_snomed),
  CONSTRAINT agents_fkey FOREIGN KEY (agent_snomed)
    REFERENCES agents(snomed) ON DELETE CASCADE,
  CONSTRAINT diseases_fkey FOREIGN KEY (disease_snomed)
    REFERENCES diseases(snomed) ON DELETE CASCADE
);

CREATE TABLE schools_daycares
(
  identifier varchar(50),
  phu varchar(100),
  org_type varchar(100),
  name varchar(100),
  address varchar(100),
  postal_code varchar(8),
  city varchar(100),
  CONSTRAINT schools_daycares_pkey PRIMARY KEY (identifier)
);

CREATE TABLE geocodes
(
    postal_code varchar(7),
    city varchar(100),
    province varchar(50) ,
    province_abbr varchar(10),
    latitude double precision,
    longitude double precision,
    street_name varchar(100),
    street_type varchar(20),
    street_dir varchar(20),
    street_from_no bigint,
    street_to_no bigint,
    rural_route varchar(100),
    country varchar(100),
    street_type_full varchar(20),
    street_dir_full varchar(20)
);

CREATE TABLE process_lock (
  process_name varchar(50) NOT NULL UNIQUE,
  updated_at date not null default CURRENT_DATE
);

-- Get a lock on row for processing
-- Other callers will get a failed transaction if the date is too recent
-- or, they will be unable to get a lock if it's already being held by another caller - ie. only one worker can run this.
-- First entry will need to be added programatically before setting up the scheduler.
-- Set it xx days in the past to get an update immediately, otherwise you'll have to wait for the full time
--
-- begin; select * from process_lock where current_date - interval '10 days' >= updated_at and process_name='data-dictionary' for update nowait;
--
--  .. do the updates ..
--
-- update process_lock set updated_at = current_date where process_name = 'data-dictionary'
-- commit;

-- insert the first record or this won't ever run.
-- this should be in sync with the month frequency in the app config
INSERT INTO process_lock VALUES ('data-dictionary', current_date - interval '60 days');

-- CREATE INDEX ---------------------------------------------------------------------------------

-- Foreign Key Indexes --
CREATE INDEX trades_agents_agent_snomed_fkey_idx ON trades_agents(agent_snomed);
CREATE INDEX trades_agents_trade_snomed_fkey_idx ON trades_agents(trade_snomed);
CREATE INDEX agents_diseases_agent_snomed_fkey_idx ON agents_diseases(agent_snomed);
CREATE INDEX agents_diseases_disease_snomed_fkey_idx ON agents_diseases(disease_snomed);

-- Join Field Indexes --
CREATE INDEX lots_agent_jf_idx ON lots(agent_snomed);
CREATE INDEX lots_trade_jf_idx ON lots(trade_panorama_name);
CREATE INDEX trades_jf_idx ON trades(panorama_name);

-- CREATE VIEWS -------------------------------------------------------------------------------

CREATE OR REPLACE VIEW diseases_index AS
  SELECT
    snomed,
    friendly_en_name,
    friendly_fr_name,
    yellow_card_order,
    json_build_object('snomed', snomed,
                      'yellowCardOrder', yellow_card_order,
                      'longName', json_build_object ('en', friendly_en_name,
                                                     'fr', friendly_fr_name)) AS json
  FROM diseases;

CREATE OR REPLACE VIEW agents_index AS
SELECT
    agents.snomed,
    agents.short_en_name,
    agents.short_fr_name,
    agents.long_en_name,
    agents.long_fr_name,
    agents.is_user_view,
    agents.prevalence_index,
    agents.ontario_start_year,
    agents.ontario_finish_year,
    json_build_object('snomed', agents.snomed,
                      'shortName', json_build_object('en', agents.short_en_name,
                                                     'fr', agents.short_fr_name),
                      'longName',  json_build_object('en', agents.long_en_name,
                                                     'fr', agents.long_fr_name),
                      'prevalenceIndex', agents.prevalence_index,
                      'ontarioStartYear', agents.ontario_start_year,
                      'ontarioFinishYear', agents.ontario_finish_year) AS json
  FROM agents;

CREATE OR REPLACE VIEW trades_index AS
  SELECT
    trades.snomed,
    trades.friendly_en_name,
    trades.friendly_fr_name,
    trades.manufacturer,
    trades.ontario_start_year,
    trades.ontario_finish_year,
    trades.prevalence_index,
    trades.panorama_name,
    json_build_object('snomed', trades.snomed,
                      'longName', json_build_object('en', trades.friendly_en_name,
                                                      'fr', trades.friendly_fr_name),
                      'manufacturer', trades.manufacturer,
                      'ontarioStartYear', trades.ontario_start_year,
                      'ontarioFinishYear', trades.ontario_finish_year,
                      'prevalenceIndex', trades.prevalence_index,
                      'panoramaName', trades.panorama_name) AS json
  FROM trades;

CREATE OR REPLACE VIEW lots_index AS
  SELECT
    lots.lot_number,
    lots.expiry,
    lots.agent_snomed,
    lots.trade_panorama_name,
    json_build_object('lotNumber', lots.lot_number,
                      'expiry', lots.expiry) AS json
  FROM lots;

CREATE MATERIALIZED VIEW schools_daycares_index AS
  SELECT
    schools_daycares.identifier,
    schools_daycares.phu,
    schools_daycares.org_type,
    initcap(schools_daycares.name) AS name,
    initcap(schools_daycares.address) AS address,
    upper(schools_daycares.postal_code) AS postal_code,
    initcap(schools_daycares.city) AS city
  FROM schools_daycares
  WITH NO DATA;

CREATE MATERIALIZED VIEW geocodes_index AS
  SELECT
    upper(geocodes.postal_code) AS postal_code,
    initcap(geocodes.city) AS city,
    initcap(geocodes.province) AS province,
    geocodes.province_abbr,
    geocodes.latitude,
    geocodes.longitude,
    initcap(geocodes.street_name) AS street_name,
    geocodes.street_type AS street_type_abbr,
    geocodes.street_dir AS street_dir_abbr,
    geocodes.street_from_no,
    geocodes.street_to_no,
    geocodes.rural_route,
    geocodes.country,
    geocodes.street_type_full AS street_type,
    geocodes.street_dir_full AS street_dir
  FROM geocodes
  WITH NO DATA;

CREATE MATERIALIZED VIEW cities_index AS
  SELECT DISTINCT initcap(geocodes_index.city) AS city
  FROM geocodes_index
  ORDER BY (initcap(geocodes_index.city))
WITH NO DATA;

CREATE OR REPLACE VIEW immunization_lookups AS
  SELECT
  lower(agents.long_en_name) AS agent_long_en,
  lower(agents.long_fr_name) AS agent_long_fr,
  lower(agents.short_en_name) AS agent_short_en,
  lower(agents.short_fr_name) AS agent_short_fr,
  agents.prevalence_index,
  lower(trades.friendly_en_name) AS trade_en,
  lower(trades.friendly_fr_name) AS trade_fr,
  jsonb_build_object('agent', jsonb_build_object('snomed', agents.snomed,
                                               'shortName', jsonb_build_object('en', agents.short_en_name,
                                                                              'fr', agents.short_fr_name),
                                               'longName', jsonb_build_object('en', agents.long_en_name,
                                                                             'fr', agents.long_fr_name),
                                               'prevalenceIndex', agents.prevalence_index,
                                               'ontarioStartYear', agents.ontario_start_year,
                                               'ontarioFinishYear', agents.ontario_finish_year,
                                               'diseases',((SELECT
                                                            json_agg(diseases_index.json)
                                                            FROM diseases_index
                                                            WHERE diseases_index.snomed = ANY (array_agg(diseases.snomed)::bigint[])))),
                    'trade',((SELECT
                              trades_index.json
                              FROM trades_index
                              WHERE trades_index.snomed = ANY (array_agg(trades.snomed)::bigint[])))) AS json
  FROM agents
  LEFT OUTER JOIN trades_agents ON agents.snomed = trades_agents.agent_snomed
  LEFT OUTER JOIN trades ON trades_agents.trade_snomed = trades.snomed
  LEFT OUTER JOIN agents_diseases ON agents.snomed = agents_diseases.agent_snomed
  LEFT OUTER JOIN diseases ON agents_diseases.disease_snomed = diseases.snomed
  WHERE agents.is_user_view = true
  GROUP BY agents.snomed,
           agents.long_en_name,
           agents.long_fr_name,
           agents.short_en_name,
           agents.short_fr_name,
           trades.friendly_en_name,
           trades.friendly_fr_name,
           trades.snomed
  UNION
  SELECT 
  lower(agents.long_en_name) AS agent_long_en,
  lower(agents.long_fr_name) AS agent_long_fr,
  lower(agents.short_en_name) AS agent_short_en,
  lower(agents.short_fr_name) AS agent_short_fr,
  agents.prevalence_index,
  NULL AS trade_en,
  NULL AS trade_fr,
  jsonb_build_object('agent', jsonb_build_object('snomed', agents.snomed,
                                               'shortName', jsonb_build_object('en', agents.short_en_name,
                                                                              'fr', agents.short_fr_name),
                                               'longName', jsonb_build_object('en', agents.long_en_name,
                                                                             'fr', agents.long_fr_name),
                                               'prevalenceIndex', agents.prevalence_index,
                                               'ontarioStartYear', agents.ontario_start_year,
                                               'ontarioFinishYear', agents.ontario_finish_year,
                                               'diseases',((SELECT
                                                            json_agg(diseases_index.json)
                                                            FROM diseases_index
                                                            WHERE diseases_index.snomed = ANY (array_agg(diseases.snomed)::bigint[])))),
                    'trade', NULL) AS json
  FROM agents
  LEFT OUTER JOIN agents_diseases ON agents.snomed = agents_diseases.agent_snomed
  LEFT OUTER JOIN diseases ON agents_diseases.disease_snomed = diseases.snomed
  WHERE agents.is_user_view = true
  GROUP BY agents.snomed,
           agents.long_en_name,
           agents.long_fr_name,
           agents.short_en_name,
           agents.short_fr_name
  ORDER BY prevalence_index,
           agent_long_en,
           agent_long_fr;

CREATE OR REPLACE VIEW lot_lookups AS
  SELECT
    agents.snomed,
    json_build_object('lots', ((SELECT
                                json_agg(lots_index.json)
                                FROM lots_index
                                WHERE lots_index.agent_snomed = ANY (array_agg(agents.snomed))))) AS json
  FROM agents
  GROUP BY agents.snomed
  UNION ALL
  SELECT
    trades.snomed,
    json_build_object('lots', ((SELECT
                                json_agg(lots_index.json)
                                FROM lots_index
                                WHERE lots_index.trade_panorama_name = ANY (array_agg(trades.panorama_name))))) AS json
  FROM trades
  GROUP BY trades.snomed;

CREATE OR REPLACE VIEW retrieval_lookups AS
  SELECT
    agents.snomed,
    json_build_object('agent', json_build_object('snomed', agents.snomed,
                                                 'shortName', json_build_object('en', agents.short_en_name,
                                                                                'fr', agents.short_fr_name),
                                                 'longName', json_build_object('en', agents.long_en_name,
                                                                               'fr', agents.long_fr_name),
                                                 'prevalenceIndex', agents.prevalence_index,
                                                 'ontarioStartYear', agents.ontario_start_year,
                                                 'ontarioFinishYear', agents.ontario_finish_year,
                                                 'diseases',((SELECT
                                                              json_agg(diseases_index.json)
                                                              FROM diseases_index
                                                              WHERE diseases_index.snomed = ANY (array_agg(diseases.snomed)::bigint[])))),
                      'trade', null) AS json
  FROM agents
  LEFT OUTER JOIN agents_diseases ON agents.snomed = agents_diseases.agent_snomed
  LEFT OUTER JOIN diseases ON agents_diseases.disease_snomed = diseases.snomed
  GROUP BY agents.snomed
  UNION ALL
  SELECT
    trades.snomed,
    json_build_object('agent', json_build_object('snomed', agents.snomed,
                                                 'shortName', json_build_object('en', agents.short_en_name,
                                                                                'fr', agents.short_fr_name),
                                                 'longName', json_build_object('en', agents.long_en_name,
                                                                               'fr', agents.long_fr_name),
                                                 'prevalenceIndex', agents.prevalence_index,
                                                 'ontarioStartYear', agents.ontario_start_year,
                                                 'ontarioFinishYear', agents.ontario_finish_year,
                                                 'diseases',((SELECT
                                                              json_agg(diseases_index.json)
                                                              FROM diseases_index
                                                              WHERE diseases_index.snomed = ANY (array_agg(diseases.snomed)::bigint[])))),
                      'trade',((SELECT
                                trades_index.json
                                FROM trades_index
                                WHERE trades_index.snomed = ANY (array_agg(trades.snomed)::bigint[])))) AS json
    FROM trades
    LEFT OUTER JOIN trades_agents ON trades.snomed = trades_agents.trade_snomed
    LEFT OUTER JOIN agents ON trades_agents.agent_snomed = agents.snomed
    LEFT OUTER JOIN agents_diseases ON agents.snomed = agents_diseases.agent_snomed
    LEFT OUTER JOIN diseases ON agents_diseases.disease_snomed = diseases.snomed
    GROUP BY trades.snomed, 
             agents.snomed;

-- CREATE FUNCTIONS -------------------------------------------------------------------------------

-----------------------------------------------------
-- Schools Daycares Loader
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS  load_schools_daycares (values text);

CREATE OR REPLACE FUNCTION load_schools_daycares() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- preflight
  DROP TABLE IF EXISTS schools_daycares_bak;
  CREATE TABLE schools_daycares_bak AS SELECT * FROM schools_daycares;
  DELETE FROM schools_daycares;

  -- tranform the data
  INSERT INTO schools_daycares (phu, org_type, name, identifier, address, postal_code, city)

  SELECT
    values->>'phu' AS phu,
    values->>'orgType' AS org_type,
    values->>'name' AS name,
    values->>'identifier' AS identifier,
    values->>'streetAddress' AS address,
    values->>'postalCode' AS postal_code,
    values->>'city' AS city
  FROM (
    SELECT json_array_elements(replace(values,'\','\\')::json) AS values -- '
    FROM load_schools_daycares
  ) a;

  -- post-flight
  DELETE FROM load_schools_daycares;
  REFRESH MATERIALIZED VIEW schools_daycares_index;

  RETURN NEW;
END;
$$;

-- Add the trigger to xform and transfer data
DROP TRIGGER IF EXISTS load_schools_daycares on load_schools_daycares;

CREATE TRIGGER load_schools_daycares
AFTER INSERT ON load_schools_daycares
FOR EACH ROW
EXECUTE PROCEDURE load_schools_daycares();

----------------------------------------
-- Lots loader
----------------------------------------
CREATE TABLE IF NOT EXISTS load_lots (values text);

CREATE TABLE IF NOT EXISTS lots
(
	lot_id serial,
	lot_number varchar(15),
  expiry date,
  agent_snomed bigint,
  trade_panorama_name varchar(100),
  CONSTRAINT lots_pkey PRIMARY KEY (lot_id)
);


CREATE OR REPLACE FUNCTION load_lots() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- preflight
  DROP TABLE IF EXISTS lots_bak;
  CREATE TABLE lots_bak AS SELECT * FROM lots;
  DELETE FROM lots;

  -- tranform the data
  INSERT INTO lots(lot_number, expiry, agent_snomed, trade_panorama_name)

  SELECT
    values ->> 'lotNumber' AS lot_number,
    to_date((values ->> 'lotExpiryDate'), 'MM-DD-YYYY')  AS expiry,
    (values ->> 'agentSnomedCode')::bigint AS agent_snomed,
    values ->> 'tradeName' AS trade_panorama_name
  FROM (
    SELECT json_array_elements(replace(values,'\','\\')::json) AS values -- '
    FROM load_lots
  ) a;

  -- post-flight
  DELETE FROM load_lots;

  RETURN NEW;
END;
$$;

-- Add the trigger to xform and transfer data
DROP TRIGGER IF EXISTS load_lots on load_lots;

CREATE TRIGGER load_lots
AFTER INSERT ON load_lots
FOR EACH ROW
EXECUTE PROCEDURE load_lots();
