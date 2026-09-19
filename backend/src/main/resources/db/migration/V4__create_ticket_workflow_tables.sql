CREATE TABLE dbo.tickets (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_number VARCHAR(30) NOT NULL,
    reporter_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    form_version_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    asset_id BIGINT NULL,
    duplicate_of_ticket_id BIGINT NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    priority VARCHAR(20) NOT NULL
        CONSTRAINT df_tickets_priority DEFAULT 'NORMAL',
    ticket_status VARCHAR(30) NOT NULL
        CONSTRAINT df_tickets_status DEFAULT 'SUBMITTED',
    sla_due_at DATETIMEOFFSET(7) NULL,
    resolved_at DATETIMEOFFSET(7) NULL,
    closed_at DATETIMEOFFSET(7) NULL,
    version BIGINT NOT NULL
        CONSTRAINT df_tickets_version DEFAULT 0,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_tickets_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_tickets_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_tickets PRIMARY KEY (id),
    CONSTRAINT uq_tickets_ticket_number UNIQUE (ticket_number),
    CONSTRAINT uq_tickets_id_form_version UNIQUE (id, form_version_id),
    CONSTRAINT fk_tickets_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_tickets_category
        FOREIGN KEY (category_id) REFERENCES dbo.incident_categories(id),
    CONSTRAINT fk_tickets_category_form
        FOREIGN KEY (category_id, form_version_id)
        REFERENCES dbo.category_form_versions(category_id, id),
    CONSTRAINT fk_tickets_location
        FOREIGN KEY (location_id) REFERENCES dbo.locations(id),
    CONSTRAINT fk_tickets_asset
        FOREIGN KEY (asset_id) REFERENCES dbo.assets(id),
    CONSTRAINT fk_tickets_duplicate
        FOREIGN KEY (duplicate_of_ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT ck_tickets_priority
        CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    CONSTRAINT ck_tickets_status
        CHECK (ticket_status IN (
            'SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED', 'IN_PROGRESS',
            'RESOLVED', 'REOPENED', 'CLOSED', 'REJECTED', 'CANCELLED'
        )),
    CONSTRAINT ck_tickets_not_self_duplicate
        CHECK (duplicate_of_ticket_id IS NULL OR duplicate_of_ticket_id <> id),
    CONSTRAINT ck_tickets_lifecycle_timestamps
        CHECK (
            (resolved_at IS NULL OR ticket_status IN ('RESOLVED', 'CLOSED'))
            AND (closed_at IS NULL OR ticket_status = 'CLOSED')
        )
);

CREATE INDEX idx_tickets_status_created
    ON dbo.tickets (ticket_status, created_at DESC);
CREATE INDEX idx_tickets_reporter_created
    ON dbo.tickets (reporter_id, created_at DESC);
CREATE INDEX idx_tickets_category_status
    ON dbo.tickets (category_id, ticket_status);
CREATE INDEX idx_tickets_location_status
    ON dbo.tickets (location_id, ticket_status);
CREATE INDEX idx_tickets_asset_status
    ON dbo.tickets (asset_id, ticket_status)
    WHERE asset_id IS NOT NULL;
CREATE INDEX idx_tickets_sla_open
    ON dbo.tickets (ticket_status, sla_due_at, priority)
    WHERE sla_due_at IS NOT NULL;

CREATE TABLE dbo.ticket_field_values (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    form_version_id BIGINT NOT NULL,
    field_definition_id BIGINT NOT NULL,
    value_json NVARCHAR(MAX) NOT NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_field_values_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_field_values PRIMARY KEY (id),
    CONSTRAINT uq_ticket_field_values_field UNIQUE (ticket_id, field_definition_id),
    CONSTRAINT fk_ticket_field_values_ticket_form
        FOREIGN KEY (ticket_id, form_version_id)
        REFERENCES dbo.tickets(id, form_version_id),
    CONSTRAINT fk_ticket_field_values_definition_form
        FOREIGN KEY (form_version_id, field_definition_id)
        REFERENCES dbo.field_definitions(form_version_id, id),
    CONSTRAINT ck_ticket_field_values_json
        CHECK (ISJSON(value_json, VALUE) = 1)
);

CREATE INDEX idx_ticket_field_values_ticket
    ON dbo.ticket_field_values (ticket_id);

CREATE TABLE dbo.ticket_assignments (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    assigned_by BIGINT NOT NULL,
    assigned_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_assignments_assigned_at DEFAULT SYSUTCDATETIME(),
    accepted_at DATETIMEOFFSET(7) NULL,
    ended_at DATETIMEOFFSET(7) NULL,
    end_reason NVARCHAR(500) NULL,
    CONSTRAINT pk_ticket_assignments PRIMARY KEY (id),
    CONSTRAINT fk_ticket_assignments_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_assignments_technician
        FOREIGN KEY (technician_id) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_ticket_assignments_assigned_by
        FOREIGN KEY (assigned_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_assignments_times
        CHECK (
            (accepted_at IS NULL OR accepted_at >= assigned_at)
            AND (ended_at IS NULL OR ended_at >= assigned_at)
        )
);

CREATE UNIQUE INDEX uq_ticket_assignments_one_active
    ON dbo.ticket_assignments (ticket_id)
    WHERE ended_at IS NULL;
CREATE INDEX idx_ticket_assignments_technician_active
    ON dbo.ticket_assignments (technician_id, ended_at, assigned_at DESC);

CREATE TABLE dbo.ticket_status_history (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    transition_action VARCHAR(40) NOT NULL,
    reason NVARCHAR(1000) NULL,
    changed_by BIGINT NOT NULL,
    changed_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_status_history_changed_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_status_history PRIMARY KEY (id),
    CONSTRAINT fk_ticket_status_history_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_status_history_user
        FOREIGN KEY (changed_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_status_history_from
        CHECK (from_status IS NULL OR from_status IN (
            'SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED', 'IN_PROGRESS',
            'RESOLVED', 'REOPENED', 'CLOSED', 'REJECTED', 'CANCELLED'
        )),
    CONSTRAINT ck_ticket_status_history_to
        CHECK (to_status IN (
            'SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED', 'IN_PROGRESS',
            'RESOLVED', 'REOPENED', 'CLOSED', 'REJECTED', 'CANCELLED'
        ))
);

CREATE INDEX idx_ticket_status_history_ticket_time
    ON dbo.ticket_status_history (ticket_id, changed_at DESC);

CREATE TABLE dbo.work_logs (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    work_description NVARCHAR(MAX) NOT NULL,
    started_at DATETIMEOFFSET(7) NOT NULL,
    ended_at DATETIMEOFFSET(7) NULL,
    minutes_spent INT NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_work_logs_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_work_logs PRIMARY KEY (id),
    CONSTRAINT fk_work_logs_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_work_logs_technician
        FOREIGN KEY (technician_id) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_work_logs_times
        CHECK (ended_at IS NULL OR ended_at >= started_at),
    CONSTRAINT ck_work_logs_minutes
        CHECK (minutes_spent IS NULL OR minutes_spent > 0)
);

CREATE INDEX idx_work_logs_ticket_time
    ON dbo.work_logs (ticket_id, created_at DESC);

CREATE TABLE dbo.ticket_attachments (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    field_definition_id BIGINT NULL,
    uploaded_by BIGINT NOT NULL,
    attachment_type VARCHAR(30) NOT NULL,
    storage_key NVARCHAR(500) NOT NULL,
    original_name NVARCHAR(255) NOT NULL,
    content_type VARCHAR(120) NOT NULL,
    size_bytes BIGINT NOT NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_attachments_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_attachments PRIMARY KEY (id),
    CONSTRAINT uq_ticket_attachments_storage_key UNIQUE (storage_key),
    CONSTRAINT fk_ticket_attachments_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_attachments_field
        FOREIGN KEY (field_definition_id) REFERENCES dbo.field_definitions(id),
    CONSTRAINT fk_ticket_attachments_user
        FOREIGN KEY (uploaded_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_attachments_type
        CHECK (attachment_type IN ('REPORT_EVIDENCE', 'WORK_RESULT', 'COMMENT')),
    CONSTRAINT ck_ticket_attachments_size
        CHECK (size_bytes > 0)
);

CREATE INDEX idx_ticket_attachments_ticket_time
    ON dbo.ticket_attachments (ticket_id, created_at DESC);

CREATE TABLE dbo.ticket_comments (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    body NVARCHAR(2000) NOT NULL,
    visibility VARCHAR(20) NOT NULL
        CONSTRAINT df_ticket_comments_visibility DEFAULT 'PUBLIC',
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_comments_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_comments PRIMARY KEY (id),
    CONSTRAINT fk_ticket_comments_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_comments_author
        FOREIGN KEY (author_id) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_comments_visibility
        CHECK (visibility IN ('PUBLIC', 'INTERNAL'))
);

CREATE INDEX idx_ticket_comments_ticket_time
    ON dbo.ticket_comments (ticket_id, created_at ASC);

CREATE TABLE dbo.ticket_feedback (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    reporter_id BIGINT NOT NULL,
    rating TINYINT NOT NULL,
    comment NVARCHAR(1000) NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_feedback_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_feedback PRIMARY KEY (id),
    CONSTRAINT uq_ticket_feedback_ticket UNIQUE (ticket_id),
    CONSTRAINT fk_ticket_feedback_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_feedback_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_feedback_rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE dbo.ticket_accuracy_reviews (
    id BIGINT IDENTITY(1,1) NOT NULL,
    ticket_id BIGINT NOT NULL,
    review_result VARCHAR(40) NOT NULL,
    reason NVARCHAR(1000) NOT NULL,
    reviewed_by BIGINT NOT NULL,
    reviewed_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_ticket_accuracy_reviews_reviewed_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_ticket_accuracy_reviews PRIMARY KEY (id),
    CONSTRAINT fk_ticket_accuracy_reviews_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id),
    CONSTRAINT fk_ticket_accuracy_reviews_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_ticket_accuracy_reviews_result
        CHECK (review_result IN (
            'ACCURATE', 'INACCURATE', 'INSUFFICIENT_EVIDENCE', 'NO_FAULT_FOUND'
        ))
);

CREATE INDEX idx_ticket_accuracy_reviews_ticket_time
    ON dbo.ticket_accuracy_reviews (ticket_id, reviewed_at DESC);

CREATE TABLE dbo.notifications (
    id BIGINT IDENTITY(1,1) NOT NULL,
    recipient_id BIGINT NOT NULL,
    ticket_id BIGINT NULL,
    notification_type VARCHAR(40) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(1000) NOT NULL,
    read_at DATETIMEOFFSET(7) NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_notifications_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_notifications PRIMARY KEY (id),
    CONSTRAINT fk_notifications_recipient
        FOREIGN KEY (recipient_id) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_notifications_ticket
        FOREIGN KEY (ticket_id) REFERENCES dbo.tickets(id)
);

CREATE INDEX idx_notifications_recipient_unread
    ON dbo.notifications (recipient_id, created_at DESC)
    WHERE read_at IS NULL;
