CREATE TABLE dbo.incident_categories (
    id BIGINT IDENTITY(1,1) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    description NVARCHAR(1000) NULL,
    asset_policy VARCHAR(20) NOT NULL
        CONSTRAINT df_incident_categories_asset_policy DEFAULT 'OPTIONAL',
    location_required BIT NOT NULL
        CONSTRAINT df_incident_categories_location_required DEFAULT 1,
    default_priority VARCHAR(20) NOT NULL
        CONSTRAINT df_incident_categories_priority DEFAULT 'NORMAL',
    sla_hours INT NULL,
    active BIT NOT NULL
        CONSTRAINT df_incident_categories_active DEFAULT 1,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_incident_categories_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_incident_categories_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_incident_categories PRIMARY KEY (id),
    CONSTRAINT uq_incident_categories_code UNIQUE (code),
    CONSTRAINT ck_incident_categories_asset_policy
        CHECK (asset_policy IN ('REQUIRED', 'OPTIONAL', 'FORBIDDEN')),
    CONSTRAINT ck_incident_categories_priority
        CHECK (default_priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    CONSTRAINT ck_incident_categories_sla_hours
        CHECK (sla_hours IS NULL OR sla_hours > 0)
);

CREATE INDEX idx_incident_categories_active_name
    ON dbo.incident_categories (active, name);

CREATE TABLE dbo.category_form_versions (
    id BIGINT IDENTITY(1,1) NOT NULL,
    category_id BIGINT NOT NULL,
    version_number INT NOT NULL,
    form_status VARCHAR(20) NOT NULL
        CONSTRAINT df_category_form_versions_status DEFAULT 'DRAFT',
    created_by BIGINT NULL,
    published_by BIGINT NULL,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_category_form_versions_created_at DEFAULT SYSUTCDATETIME(),
    published_at DATETIMEOFFSET(7) NULL,
    CONSTRAINT pk_category_form_versions PRIMARY KEY (id),
    CONSTRAINT uq_category_form_versions_number
        UNIQUE (category_id, version_number),
    CONSTRAINT uq_category_form_versions_category_id
        UNIQUE (category_id, id),
    CONSTRAINT fk_category_form_versions_category
        FOREIGN KEY (category_id) REFERENCES dbo.incident_categories(id),
    CONSTRAINT fk_category_form_versions_created_by
        FOREIGN KEY (created_by) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_category_form_versions_published_by
        FOREIGN KEY (published_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_category_form_versions_status
        CHECK (form_status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT ck_category_form_versions_publish_metadata
        CHECK (
            (form_status = 'DRAFT' AND published_at IS NULL)
            OR (form_status IN ('PUBLISHED', 'ARCHIVED') AND published_at IS NOT NULL)
        )
);

CREATE UNIQUE INDEX uq_category_form_versions_one_published
    ON dbo.category_form_versions (category_id)
    WHERE form_status = 'PUBLISHED';

CREATE TABLE dbo.field_definitions (
    id BIGINT IDENTITY(1,1) NOT NULL,
    form_version_id BIGINT NOT NULL,
    field_key VARCHAR(80) NOT NULL,
    label NVARCHAR(150) NOT NULL,
    field_type VARCHAR(30) NOT NULL,
    help_text NVARCHAR(500) NULL,
    placeholder NVARCHAR(250) NULL,
    required BIT NOT NULL
        CONSTRAINT df_field_definitions_required DEFAULT 0,
    display_order INT NOT NULL,
    validation_rules NVARCHAR(MAX) NOT NULL
        CONSTRAINT df_field_definitions_validation DEFAULT N'{}',
    CONSTRAINT pk_field_definitions PRIMARY KEY (id),
    CONSTRAINT uq_field_definitions_key
        UNIQUE (form_version_id, field_key),
    CONSTRAINT uq_field_definitions_form_id
        UNIQUE (form_version_id, id),
    CONSTRAINT fk_field_definitions_form_version
        FOREIGN KEY (form_version_id) REFERENCES dbo.category_form_versions(id),
    CONSTRAINT ck_field_definitions_type
        CHECK (field_type IN (
            'TEXT', 'TEXTAREA', 'NUMBER', 'SELECT', 'MULTI_SELECT',
            'DATE', 'DATETIME', 'BOOLEAN', 'IMAGE'
        )),
    CONSTRAINT ck_field_definitions_display_order
        CHECK (display_order >= 0),
    CONSTRAINT ck_field_definitions_validation_json
        CHECK (ISJSON(validation_rules, OBJECT) = 1)
);

CREATE INDEX idx_field_definitions_form_order
    ON dbo.field_definitions (form_version_id, display_order);

CREATE TABLE dbo.field_options (
    id BIGINT IDENTITY(1,1) NOT NULL,
    field_definition_id BIGINT NOT NULL,
    option_value VARCHAR(100) NOT NULL,
    option_label NVARCHAR(150) NOT NULL,
    display_order INT NOT NULL,
    active BIT NOT NULL
        CONSTRAINT df_field_options_active DEFAULT 1,
    CONSTRAINT pk_field_options PRIMARY KEY (id),
    CONSTRAINT uq_field_options_value
        UNIQUE (field_definition_id, option_value),
    CONSTRAINT fk_field_options_field_definition
        FOREIGN KEY (field_definition_id) REFERENCES dbo.field_definitions(id),
    CONSTRAINT ck_field_options_display_order
        CHECK (display_order >= 0)
);

CREATE INDEX idx_field_options_field_order
    ON dbo.field_options (field_definition_id, display_order);
