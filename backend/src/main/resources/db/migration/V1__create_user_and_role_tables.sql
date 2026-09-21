CREATE TABLE dbo.app_users (
    id BIGINT IDENTITY(1,1) NOT NULL,
    email NVARCHAR(254) NOT NULL,
    normalized_email AS LOWER(LTRIM(RTRIM(email))) PERSISTED,
    password_hash NVARCHAR(100) NOT NULL,
    full_name NVARCHAR(120) NOT NULL,
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_app_users_status DEFAULT 'ACTIVE',
    version BIGINT NOT NULL
        CONSTRAINT df_app_users_version DEFAULT 0,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_app_users_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_app_users_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_app_users PRIMARY KEY (id),
    CONSTRAINT ck_app_users_status
        CHECK (status IN ('ACTIVE', 'LOCKED', 'DISABLED'))
);

CREATE UNIQUE INDEX uq_app_users_normalized_email
    ON dbo.app_users (normalized_email);

CREATE TABLE dbo.roles (
    id SMALLINT IDENTITY(1,1) NOT NULL,
    code VARCHAR(30) NOT NULL,
    name NVARCHAR(80) NOT NULL,
    CONSTRAINT pk_roles PRIMARY KEY (id),
    CONSTRAINT uq_roles_code UNIQUE (code),
    CONSTRAINT ck_roles_code
        CHECK (code IN ('REQUESTER', 'TECHNICIAN', 'MANAGER', 'ADMIN'))
);

CREATE TABLE dbo.user_roles (
    user_id BIGINT NOT NULL,
    role_id SMALLINT NOT NULL,
    assigned_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_user_roles_assigned_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id) REFERENCES dbo.app_users(id),
    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id) REFERENCES dbo.roles(id)
);

CREATE INDEX idx_user_roles_role_id ON dbo.user_roles (role_id);
