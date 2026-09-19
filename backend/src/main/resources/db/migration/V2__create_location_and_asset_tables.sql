CREATE TABLE dbo.locations (
    id BIGINT IDENTITY(1,1) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    location_type VARCHAR(20) NOT NULL,
    parent_id BIGINT NULL,
    description NVARCHAR(500) NULL,
    active BIT NOT NULL
        CONSTRAINT df_locations_active DEFAULT 1,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_locations_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_locations_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_locations PRIMARY KEY (id),
    CONSTRAINT uq_locations_code UNIQUE (code),
    CONSTRAINT fk_locations_parent
        FOREIGN KEY (parent_id) REFERENCES dbo.locations(id),
    CONSTRAINT ck_locations_type
        CHECK (location_type IN ('CAMPUS', 'BUILDING', 'FLOOR', 'ROOM', 'AREA')),
    CONSTRAINT ck_locations_not_self_parent
        CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE INDEX idx_locations_parent_id ON dbo.locations (parent_id);
CREATE INDEX idx_locations_active_type ON dbo.locations (active, location_type);

CREATE TABLE dbo.equipment_types (
    id BIGINT IDENTITY(1,1) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    description NVARCHAR(500) NULL,
    active BIT NOT NULL
        CONSTRAINT df_equipment_types_active DEFAULT 1,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_equipment_types_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_equipment_types_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_equipment_types PRIMARY KEY (id),
    CONSTRAINT uq_equipment_types_code UNIQUE (code)
);

CREATE TABLE dbo.assets (
    id BIGINT IDENTITY(1,1) NOT NULL,
    asset_code VARCHAR(80) NOT NULL,
    serial_number NVARCHAR(120) NULL,
    equipment_type_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    asset_status VARCHAR(30) NOT NULL
        CONSTRAINT df_assets_status DEFAULT 'ACTIVE',
    description NVARCHAR(500) NULL,
    purchased_at DATE NULL,
    version BIGINT NOT NULL
        CONSTRAINT df_assets_version DEFAULT 0,
    created_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_assets_created_at DEFAULT SYSUTCDATETIME(),
    updated_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_assets_updated_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_assets PRIMARY KEY (id),
    CONSTRAINT uq_assets_asset_code UNIQUE (asset_code),
    CONSTRAINT fk_assets_equipment_type
        FOREIGN KEY (equipment_type_id) REFERENCES dbo.equipment_types(id),
    CONSTRAINT fk_assets_location
        FOREIGN KEY (location_id) REFERENCES dbo.locations(id),
    CONSTRAINT ck_assets_status
        CHECK (asset_status IN ('ACTIVE', 'UNDER_MAINTENANCE', 'OUT_OF_SERVICE', 'RETIRED'))
);

CREATE INDEX idx_assets_equipment_type_id ON dbo.assets (equipment_type_id);
CREATE INDEX idx_assets_location_status ON dbo.assets (location_id, asset_status);

CREATE TABLE dbo.asset_status_history (
    id BIGINT IDENTITY(1,1) NOT NULL,
    asset_id BIGINT NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    reason NVARCHAR(500) NOT NULL,
    changed_by BIGINT NULL,
    changed_at DATETIMEOFFSET(7) NOT NULL
        CONSTRAINT df_asset_status_history_changed_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT pk_asset_status_history PRIMARY KEY (id),
    CONSTRAINT fk_asset_status_history_asset
        FOREIGN KEY (asset_id) REFERENCES dbo.assets(id),
    CONSTRAINT fk_asset_status_history_user
        FOREIGN KEY (changed_by) REFERENCES dbo.app_users(id),
    CONSTRAINT ck_asset_history_from_status
        CHECK (from_status IS NULL OR from_status IN ('ACTIVE', 'UNDER_MAINTENANCE', 'OUT_OF_SERVICE', 'RETIRED')),
    CONSTRAINT ck_asset_history_to_status
        CHECK (to_status IN ('ACTIVE', 'UNDER_MAINTENANCE', 'OUT_OF_SERVICE', 'RETIRED'))
);

CREATE INDEX idx_asset_status_history_asset_time
    ON dbo.asset_status_history (asset_id, changed_at DESC);
