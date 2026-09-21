-- Complete the physical SQL Server schema for the workforce, SLA, audit,
-- and reviewed false-report areas shown in the CampusFix ERD.
-- Existing V1-V5 migrations remain immutable; this migration adds the
-- missing structures and enriches existing tables without dropping data.

CREATE TABLE dbo.technician_profiles (
    technician_id BIGINT NOT NULL,
    max_active_tickets INT NOT NULL
        CONSTRAINT df_technician_profiles_max_active DEFAULT 5,
    available BIT NOT NULL
        CONSTRAINT df_technician_profiles_available DEFAULT 1,
    version BIGINT NOT NULL
        CONSTRAINT df_technician_profiles_version DEFAULT 0,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_technician_profiles_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_technician_profiles_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_technician_profiles PRIMARY KEY (technician_id),
    CONSTRAINT fk_technician_profiles_user
        FOREIGN KEY (technician_id) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_technician_profiles_max_active
        CHECK (max_active_tickets > 0)
);

CREATE TABLE dbo.skills (
    id BIGINT IDENTITY(1,1) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    active BIT NOT NULL
        CONSTRAINT df_skills_active DEFAULT 1,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_skills_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_skills_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_skills PRIMARY KEY (id),
    CONSTRAINT uq_skills_code UNIQUE (code)
);

CREATE TABLE dbo.technician_skills (
    technician_id BIGINT NOT NULL,
    skill_id BIGINT NOT NULL,
    proficiency_level TINYINT NOT NULL,
    assigned_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_technician_skills_assigned_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_technician_skills PRIMARY KEY (technician_id, skill_id),
    CONSTRAINT fk_technician_skills_technician
        FOREIGN KEY (technician_id) REFERENCES dbo.technician_profiles(technician_id),
    CONSTRAINT fk_technician_skills_skill
        FOREIGN KEY (skill_id) REFERENCES dbo.skills(id),
    CONSTRAINT ck_technician_skills_proficiency
        CHECK (proficiency_level BETWEEN 1 AND 5)
);

CREATE INDEX idx_technician_skills_skill
    ON dbo.technician_skills (skill_id, proficiency_level DESC);

CREATE TABLE dbo.technician_service_areas (
    technician_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    CONSTRAINT pk_technician_service_areas PRIMARY KEY (technician_id, location_id),
    CONSTRAINT fk_technician_service_areas_technician
        FOREIGN KEY (technician_id) REFERENCES dbo.technician_profiles(technician_id),
    CONSTRAINT fk_technician_service_areas_location
        FOREIGN KEY (location_id) REFERENCES dbo.locations(id)
);

CREATE INDEX idx_technician_service_areas_location
    ON dbo.technician_service_areas (location_id, technician_id);

CREATE TABLE dbo.sla_policies (
    id BIGINT IDENTITY(1,1) NOT NULL,
    policy_name NVARCHAR(150) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    resolution_minutes INT NOT NULL,
    pause_waiting_requester BIT NOT NULL
        CONSTRAINT df_sla_policies_pause_requester DEFAULT 0,
    active BIT NOT NULL
        CONSTRAINT df_sla_policies_active DEFAULT 1,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_sla_policies_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_sla_policies_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_sla_policies PRIMARY KEY (id),
    CONSTRAINT uq_sla_policies_name UNIQUE (policy_name),
    CONSTRAINT ck_sla_policies_priority
        CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    CONSTRAINT ck_sla_policies_resolution_minutes
        CHECK (resolution_minutes > 0)
);

ALTER TABLE dbo.user_roles
ADD assigned_by BIGINT NULL;
GO

ALTER TABLE dbo.user_roles
ADD CONSTRAINT fk_user_roles_assigned_by
    FOREIGN KEY (assigned_by) REFERENCES dbo.app_users(id);

ALTER TABLE dbo.equipment_types
ADD brand NVARCHAR(100) NULL,
    model NVARCHAR(100) NULL;

ALTER TABLE dbo.assets
ADD warranty_until DATE NULL;

IF EXISTS (
    SELECT serial_number
    FROM dbo.assets
    WHERE serial_number IS NOT NULL
    GROUP BY serial_number
    HAVING COUNT(*) > 1
)
    THROW 51001, 'Cannot enforce unique asset serial numbers. Resolve duplicate serial_number values before applying V6.', 1;

CREATE UNIQUE INDEX uq_assets_serial_number
    ON dbo.assets (serial_number)
    WHERE serial_number IS NOT NULL;

ALTER TABLE dbo.asset_status_history
ADD ticket_id BIGINT NULL;
GO

ALTER TABLE dbo.asset_status_history
ADD CONSTRAINT fk_asset_status_history_ticket
    FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id);

CREATE INDEX idx_asset_status_history_ticket
    ON dbo.asset_status_history (ticket_id, changed_at DESC)
    WHERE ticket_id IS NOT NULL;

ALTER TABLE dbo.incident_categories
ADD created_by BIGINT NULL;
GO

ALTER TABLE dbo.incident_categories
ADD CONSTRAINT fk_incident_categories_created_by
    FOREIGN KEY (created_by) REFERENCES dbo.app_users(id);

ALTER TABLE dbo.category_form_versions
ADD requires_equipment BIT NOT NULL
        CONSTRAINT df_category_form_versions_requires_equipment DEFAULT 0,
    min_attachment_count INT NOT NULL
        CONSTRAINT df_category_form_versions_min_attachments DEFAULT 0,
    default_skill_id BIGINT NULL,
    default_sla_policy_id BIGINT NULL;
GO

ALTER TABLE dbo.category_form_versions
ADD CONSTRAINT ck_category_form_versions_min_attachments
        CHECK (min_attachment_count >= 0),
    CONSTRAINT fk_category_form_versions_default_skill
        FOREIGN KEY (default_skill_id) REFERENCES dbo.skills(id),
    CONSTRAINT fk_category_form_versions_default_sla
        FOREIGN KEY (default_sla_policy_id) REFERENCES dbo.sla_policies(id);

CREATE INDEX idx_category_form_versions_default_skill
    ON dbo.category_form_versions (default_skill_id)
    WHERE default_skill_id IS NOT NULL;

ALTER TABLE dbo.tickets
ADD required_skill_id BIGINT NULL,
    resolution_outcome VARCHAR(30) NULL;
GO

ALTER TABLE dbo.tickets
ADD CONSTRAINT fk_tickets_required_skill
        FOREIGN KEY (required_skill_id) REFERENCES dbo.skills(id),
    CONSTRAINT ck_tickets_resolution_outcome
        CHECK (
            resolution_outcome IS NULL
            OR (
                resolution_outcome IN (
                    'FIXED', 'TEMPORARY_FIX', 'NO_FAULT_FOUND', 'DUPLICATE', 'UNRESOLVED'
                )
                AND ticket_status IN ('RESOLVED', 'CLOSED')
            )
        );

CREATE INDEX idx_tickets_required_skill_status
    ON dbo.tickets (required_skill_id, ticket_status)
    WHERE required_skill_id IS NOT NULL;

ALTER TABLE dbo.ticket_assignments
ADD override_reason NVARCHAR(1000) NULL;

ALTER TABLE dbo.ticket_assignments
ADD CONSTRAINT ck_ticket_assignments_accept_before_end
    CHECK (accepted_at IS NULL OR ended_at IS NULL OR accepted_at <= ended_at);

ALTER TABLE dbo.work_logs
ADD log_type VARCHAR(30) NOT NULL
    CONSTRAINT df_work_logs_type DEFAULT 'PROGRESS';
GO

ALTER TABLE dbo.work_logs
ADD CONSTRAINT ck_work_logs_type
    CHECK (log_type IN (
        'DIAGNOSIS', 'PROGRESS', 'REPAIR', 'RESOLUTION', 'NO_FAULT_FOUND'
    ));

ALTER TABLE dbo.ticket_comments
ADD edited_at DATETIMEOFFSET(7) NULL;
GO

ALTER TABLE dbo.ticket_comments
ADD CONSTRAINT ck_ticket_comments_edited_at
    CHECK (edited_at IS NULL OR edited_at >= created_at);

ALTER TABLE dbo.ticket_attachments
ADD form_version_id BIGINT NULL;
GO

UPDATE attachment
SET attachment.form_version_id = ticket.form_version_id
FROM dbo.ticket_attachments AS attachment
JOIN dbo.tickets AS ticket ON ticket.id = attachment.ticket_id;

ALTER TABLE dbo.ticket_attachments
ALTER COLUMN form_version_id BIGINT NOT NULL;

ALTER TABLE dbo.ticket_attachments
ADD CONSTRAINT fk_ticket_attachments_ticket_form
        FOREIGN KEY (ticket_id, form_version_id)
        REFERENCES dbo.tickets(id, form_version_id),
    CONSTRAINT fk_ticket_attachments_definition_form
        FOREIGN KEY (form_version_id, field_definition_id)
        REFERENCES dbo.field_definitions(form_version_id, id);

-- Backfill a profile for any technician already referenced before changing
-- these foreign keys to the ERD-authoritative TECHNICIAN_PROFILE target.
INSERT INTO dbo.technician_profiles (technician_id)
SELECT referenced.technician_id
FROM (
    SELECT technician_id FROM dbo.ticket_assignments
    UNION
    SELECT technician_id FROM dbo.work_logs
) AS referenced
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.technician_profiles profile
    WHERE profile.technician_id = referenced.technician_id
);

ALTER TABLE dbo.ticket_assignments
DROP CONSTRAINT fk_ticket_assignments_technician;
GO

ALTER TABLE dbo.ticket_assignments
ADD CONSTRAINT fk_ticket_assignments_technician
    FOREIGN KEY (technician_id)
    REFERENCES dbo.technician_profiles(technician_id);

ALTER TABLE dbo.work_logs
DROP CONSTRAINT fk_work_logs_technician;
GO

ALTER TABLE dbo.work_logs
ADD CONSTRAINT fk_work_logs_technician
    FOREIGN KEY (technician_id)
    REFERENCES dbo.technician_profiles(technician_id);

CREATE TABLE dbo.audit_logs (
    id BIGINT IDENTITY(1,1) NOT NULL,
    actor_id BIGINT NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(80) NOT NULL,
    target_id BIGINT NOT NULL,
    before_data NVARCHAR(MAX) NULL,
    after_data NVARCHAR(MAX) NULL,
    reason NVARCHAR(1000) NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_audit_logs_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_audit_logs PRIMARY KEY (id),
    CONSTRAINT fk_audit_logs_actor
        FOREIGN KEY (actor_id) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_audit_logs_before_json
        CHECK (before_data IS NULL OR ISJSON(before_data) = 1),
    CONSTRAINT ck_audit_logs_after_json
        CHECK (after_data IS NULL OR ISJSON(after_data) = 1)
);

CREATE INDEX idx_audit_logs_target_time
    ON dbo.audit_logs (target_type, target_id, created_at DESC);
CREATE INDEX idx_audit_logs_actor_time
    ON dbo.audit_logs (actor_id, created_at DESC)
    WHERE actor_id IS NOT NULL;

-- P1 tables: NO_FAULT_FOUND never creates a violation automatically.
-- A manager must explicitly open and review a case with evidence.
CREATE TABLE dbo.violation_cases (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    subject_user_id BIGINT NOT NULL,
    opened_by BIGINT NOT NULL,
    review_status VARCHAR(30) NOT NULL
        CONSTRAINT df_violation_cases_status DEFAULT 'OPEN',
    allegation_reason NVARCHAR(2000) NOT NULL,
    decision_reason NVARCHAR(2000) NULL,
    reviewed_by BIGINT NULL,
    restriction_until DATETIMEOFFSET(7) NULL,
    opened_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_violation_cases_opened_at DEFAULT SYSUTCDATETIME(),
    reviewed_at DATETIMEOFFSET(7) NULL,
    CONSTRAINT pk_violation_cases PRIMARY KEY (id),
    CONSTRAINT uq_violation_cases_ticket UNIQUE (ticket_id),
    CONSTRAINT fk_violation_cases_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_violation_cases_subject
        FOREIGN KEY (subject_user_id) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_violation_cases_opened_by
        FOREIGN KEY (opened_by) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_violation_cases_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_violation_cases_status
        CHECK (review_status IN (
            'OPEN', 'UNDER_REVIEW', 'CONFIRMED', 'DISMISSED', 'RESTRICTED'
        )),
    CONSTRAINT ck_violation_cases_review_metadata
        CHECK (
            (review_status IN ('OPEN', 'UNDER_REVIEW') AND reviewed_at IS NULL)
            OR (review_status IN ('CONFIRMED', 'DISMISSED', 'RESTRICTED')
                AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL
                AND decision_reason IS NOT NULL)
        )
);

CREATE INDEX idx_violation_cases_subject_status
    ON dbo.violation_cases (subject_user_id, review_status, opened_at DESC);

CREATE TABLE dbo.violation_appeals (
    id BIGINT IDENTITY(1,1) NOT NULL,
    violation_case_id BIGINT NOT NULL,
    submitted_by BIGINT NOT NULL,
    appeal_text NVARCHAR(2000) NOT NULL,
    appeal_status VARCHAR(30) NOT NULL
        CONSTRAINT df_violation_appeals_status DEFAULT 'SUBMITTED',
    reviewed_by BIGINT NULL,
    decision_note NVARCHAR(2000) NULL,
    submitted_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_violation_appeals_submitted_at DEFAULT SYSUTCDATETIME(),
    reviewed_at DATETIMEOFFSET(7) NULL,
    CONSTRAINT pk_violation_appeals PRIMARY KEY (id),
    CONSTRAINT fk_violation_appeals_case
        FOREIGN KEY (violation_case_id) REFERENCES dbo.violation_cases(id),
    CONSTRAINT fk_violation_appeals_submitted_by
        FOREIGN KEY (submitted_by) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_violation_appeals_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_violation_appeals_status
        CHECK (appeal_status IN (
            'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'WITHDRAWN'
        )),
    CONSTRAINT ck_violation_appeals_review_metadata
        CHECK (
            (appeal_status IN ('SUBMITTED', 'UNDER_REVIEW', 'WITHDRAWN')
                AND reviewed_at IS NULL)
            OR (appeal_status IN ('APPROVED', 'REJECTED')
                AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL
                AND decision_note IS NOT NULL)
        )
);

CREATE INDEX idx_violation_appeals_case_time
    ON dbo.violation_appeals (violation_case_id, submitted_at DESC);
