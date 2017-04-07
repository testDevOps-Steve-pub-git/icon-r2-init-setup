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

