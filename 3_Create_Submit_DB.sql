SET search_path = public, pg_catalog;

DROP TABLE IF EXISTS "Immun_Submission";
CREATE TABLE "Immun_Submission" (
    "Id" UUID NOT NULL,
    "Transaction_Id" VARCHAR(50) NOT NULL,
    "Session_Id" VARCHAR(50) NOT NULL,
    "Object_Version" VARCHAR(50) NOT NULL,
    "Object_Profile" VARCHAR(50) NOT NULL,
    "Immun_Object" BYTEA,
    "Transaction_Token" VARCHAR(500) NOT NULL,
    "Failed_Validation" boolean DEFAULT FALSE,
    "Attempt_History" text COLLATE pg_catalog."default" DEFAULT ''::text,
    "Created_At" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS "Submission_Attachment";
CREATE TABLE "Submission_Attachment" (
    "Id" UUID NOT NULL,
    "Transaction_Id" VARCHAR(50) NOT NULL,
    "Original_Filename" VARCHAR(260) NOT NULL,
    "File_Mime_Type" VARCHAR(130) NOT NULL,
    "File_Content" BYTEA,
    "Created_At" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY "Immun_Submission"
    ADD CONSTRAINT "Immun_Submission_pkey" PRIMARY KEY ("Id");

ALTER TABLE ONLY "Submission_Attachment"
    ADD CONSTRAINT "Submission_Attachment_pkey" PRIMARY KEY ("Id");

CREATE OR REPLACE FUNCTION file_upload_check() RETURNS trigger AS $file_upload_check$
    DECLARE
        counter_ integer := 0;
    BEGIN
        -- Count all records with matching transaction id
        SELECT count(*) into counter_ FROM public."Submission_Attachment" WHERE "Transaction_Id" = NEW."Transaction_Id";
        -- Check amount of records matching transaction id
        IF counter_ >= 2 THEN
            RAISE EXCEPTION 'CONFLICT: There cannot be more than two files associated with a transaction id';
        END IF;
        -- Save the record
        RETURN NEW;
    END;
$file_upload_check$ LANGUAGE plpgsql;

CREATE TRIGGER file_upload_check BEFORE INSERT ON "Submission_Attachment"
    FOR EACH ROW EXECUTE PROCEDURE file_upload_check();
