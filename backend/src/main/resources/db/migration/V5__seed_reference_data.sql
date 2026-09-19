IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE code = 'REQUESTER')
    INSERT INTO dbo.roles (code, name) VALUES ('REQUESTER', N'Người báo cáo');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE code = 'TECHNICIAN')
    INSERT INTO dbo.roles (code, name) VALUES ('TECHNICIAN', N'Kỹ thuật viên');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE code = 'MANAGER')
    INSERT INTO dbo.roles (code, name) VALUES ('MANAGER', N'Quản lý vận hành');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE code = 'ADMIN')
    INSERT INTO dbo.roles (code, name) VALUES ('ADMIN', N'Quản trị viên');

IF NOT EXISTS (SELECT 1 FROM dbo.locations WHERE code = 'CAMPUS-MAIN')
    INSERT INTO dbo.locations (code, name, location_type, description)
    VALUES ('CAMPUS-MAIN', N'Campus chính', 'CAMPUS', N'Dữ liệu mẫu cho môi trường phát triển');

DECLARE @campus_id BIGINT = (SELECT id FROM dbo.locations WHERE code = 'CAMPUS-MAIN');

IF NOT EXISTS (SELECT 1 FROM dbo.locations WHERE code = 'BLD-ALPHA')
    INSERT INTO dbo.locations (code, name, location_type, parent_id)
    VALUES ('BLD-ALPHA', N'Tòa Alpha', 'BUILDING', @campus_id);

DECLARE @building_id BIGINT = (SELECT id FROM dbo.locations WHERE code = 'BLD-ALPHA');

IF NOT EXISTS (SELECT 1 FROM dbo.locations WHERE code = 'FL-ALPHA-1')
    INSERT INTO dbo.locations (code, name, location_type, parent_id)
    VALUES ('FL-ALPHA-1', N'Tầng 1 - Alpha', 'FLOOR', @building_id);

DECLARE @floor_id BIGINT = (SELECT id FROM dbo.locations WHERE code = 'FL-ALPHA-1');

IF NOT EXISTS (SELECT 1 FROM dbo.locations WHERE code = 'ROOM-A101')
    INSERT INTO dbo.locations (code, name, location_type, parent_id)
    VALUES ('ROOM-A101', N'Phòng A101', 'ROOM', @floor_id);
IF NOT EXISTS (SELECT 1 FROM dbo.locations WHERE code = 'ROOM-A102')
    INSERT INTO dbo.locations (code, name, location_type, parent_id)
    VALUES ('ROOM-A102', N'Phòng A102', 'ROOM', @floor_id);

IF NOT EXISTS (SELECT 1 FROM dbo.equipment_types WHERE code = 'PROJECTOR')
    INSERT INTO dbo.equipment_types (code, name, description)
    VALUES ('PROJECTOR', N'Máy chiếu', N'Máy chiếu trong phòng học hoặc phòng họp');
IF NOT EXISTS (SELECT 1 FROM dbo.equipment_types WHERE code = 'AIR_CONDITIONER')
    INSERT INTO dbo.equipment_types (code, name, description)
    VALUES ('AIR_CONDITIONER', N'Điều hòa', N'Thiết bị điều hòa không khí');

DECLARE @room_a101 BIGINT = (SELECT id FROM dbo.locations WHERE code = 'ROOM-A101');
DECLARE @room_a102 BIGINT = (SELECT id FROM dbo.locations WHERE code = 'ROOM-A102');
DECLARE @projector_type BIGINT = (SELECT id FROM dbo.equipment_types WHERE code = 'PROJECTOR');
DECLARE @aircon_type BIGINT = (SELECT id FROM dbo.equipment_types WHERE code = 'AIR_CONDITIONER');

IF NOT EXISTS (SELECT 1 FROM dbo.assets WHERE asset_code = 'PRJ-A101-01')
    INSERT INTO dbo.assets (asset_code, serial_number, equipment_type_id, location_id, description)
    VALUES ('PRJ-A101-01', N'PJ-DEMO-0001', @projector_type, @room_a101, N'Máy chiếu mẫu tại A101');
IF NOT EXISTS (SELECT 1 FROM dbo.assets WHERE asset_code = 'AC-A102-01')
    INSERT INTO dbo.assets (asset_code, serial_number, equipment_type_id, location_id, description)
    VALUES ('AC-A102-01', N'AC-DEMO-0001', @aircon_type, @room_a102, N'Điều hòa mẫu tại A102');

IF NOT EXISTS (SELECT 1 FROM dbo.incident_categories WHERE code = 'PROJECTOR_ISSUE')
    INSERT INTO dbo.incident_categories
        (code, name, description, asset_policy, default_priority, sla_hours)
    VALUES
        ('PROJECTOR_ISSUE', N'Sự cố máy chiếu', N'Lỗi hiển thị, tín hiệu hoặc đèn báo', 'REQUIRED', 'NORMAL', 24);
IF NOT EXISTS (SELECT 1 FROM dbo.incident_categories WHERE code = 'AIR_CONDITIONER_ISSUE')
    INSERT INTO dbo.incident_categories
        (code, name, description, asset_policy, default_priority, sla_hours)
    VALUES
        ('AIR_CONDITIONER_ISSUE', N'Sự cố điều hòa', N'Điều hòa không mát, chảy nước hoặc có tiếng ồn', 'OPTIONAL', 'NORMAL', 24);
IF NOT EXISTS (SELECT 1 FROM dbo.incident_categories WHERE code = 'WATER_LEAK')
    INSERT INTO dbo.incident_categories
        (code, name, description, asset_policy, default_priority, sla_hours)
    VALUES
        ('WATER_LEAK', N'Rò rỉ nước', N'Rò nước tại phòng học hoặc khu vực chung', 'FORBIDDEN', 'HIGH', 4);
IF NOT EXISTS (SELECT 1 FROM dbo.incident_categories WHERE code = 'SAFETY_INCIDENT')
    INSERT INTO dbo.incident_categories
        (code, name, description, asset_policy, default_priority, sla_hours)
    VALUES
        ('SAFETY_INCIDENT', N'Sự cố an toàn', N'Nguy cơ ảnh hưởng đến an toàn con người hoặc tài sản', 'OPTIONAL', 'URGENT', 1);

DECLARE @projector_category BIGINT = (SELECT id FROM dbo.incident_categories WHERE code = 'PROJECTOR_ISSUE');
DECLARE @aircon_category BIGINT = (SELECT id FROM dbo.incident_categories WHERE code = 'AIR_CONDITIONER_ISSUE');
DECLARE @water_category BIGINT = (SELECT id FROM dbo.incident_categories WHERE code = 'WATER_LEAK');
DECLARE @safety_category BIGINT = (SELECT id FROM dbo.incident_categories WHERE code = 'SAFETY_INCIDENT');

IF NOT EXISTS (SELECT 1 FROM dbo.category_form_versions WHERE category_id = @projector_category AND version_number = 1)
    INSERT INTO dbo.category_form_versions (category_id, version_number, form_status, published_at)
    VALUES (@projector_category, 1, 'PUBLISHED', SYSUTCDATETIME());
IF NOT EXISTS (SELECT 1 FROM dbo.category_form_versions WHERE category_id = @aircon_category AND version_number = 1)
    INSERT INTO dbo.category_form_versions (category_id, version_number, form_status, published_at)
    VALUES (@aircon_category, 1, 'PUBLISHED', SYSUTCDATETIME());
IF NOT EXISTS (SELECT 1 FROM dbo.category_form_versions WHERE category_id = @water_category AND version_number = 1)
    INSERT INTO dbo.category_form_versions (category_id, version_number, form_status, published_at)
    VALUES (@water_category, 1, 'PUBLISHED', SYSUTCDATETIME());
IF NOT EXISTS (SELECT 1 FROM dbo.category_form_versions WHERE category_id = @safety_category AND version_number = 1)
    INSERT INTO dbo.category_form_versions (category_id, version_number, form_status, published_at)
    VALUES (@safety_category, 1, 'PUBLISHED', SYSUTCDATETIME());

DECLARE @projector_form BIGINT = (
    SELECT id FROM dbo.category_form_versions WHERE category_id = @projector_category AND version_number = 1
);
DECLARE @aircon_form BIGINT = (
    SELECT id FROM dbo.category_form_versions WHERE category_id = @aircon_category AND version_number = 1
);
DECLARE @water_form BIGINT = (
    SELECT id FROM dbo.category_form_versions WHERE category_id = @water_category AND version_number = 1
);
DECLARE @safety_form BIGINT = (
    SELECT id FROM dbo.category_form_versions WHERE category_id = @safety_category AND version_number = 1
);

IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @projector_form AND field_key = 'screen_image')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, help_text, required, display_order, validation_rules)
    VALUES
        (@projector_form, 'screen_image', N'Ảnh màn hình hoặc hình ảnh lỗi', 'IMAGE',
         N'Chụp rõ màn hình và đèn báo nếu có', 1, 1,
         N'{"minFiles":1,"maxFiles":3,"allowedTypes":["image/jpeg","image/png"]}');
IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @projector_form AND field_key = 'asset_code')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, placeholder, required, display_order, validation_rules)
    VALUES
        (@projector_form, 'asset_code', N'Mã thiết bị', 'TEXT', N'Ví dụ: PRJ-A101-01', 1, 2,
         N'{"minLength":3,"maxLength":80}');
IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @projector_form AND field_key = 'indicator_description')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@projector_form, 'indicator_description', N'Mô tả đèn báo và hiện tượng', 'TEXTAREA', 1, 3,
         N'{"minLength":10,"maxLength":500}');

IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @aircon_form AND field_key = 'room_number')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@aircon_form, 'room_number', N'Số phòng', 'TEXT', 1, 1, N'{"maxLength":30}');
IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @aircon_form AND field_key = 'symptom')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@aircon_form, 'symptom', N'Hiện tượng', 'SELECT', 1, 2, N'{}');
IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @aircon_form AND field_key = 'occurred_at')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@aircon_form, 'occurred_at', N'Thời điểm xảy ra', 'DATETIME', 1, 3, N'{"notInFuture":true}');

DECLARE @symptom_field BIGINT = (
    SELECT id FROM dbo.field_definitions WHERE form_version_id = @aircon_form AND field_key = 'symptom'
);
IF NOT EXISTS (SELECT 1 FROM dbo.field_options WHERE field_definition_id = @symptom_field AND option_value = 'NOT_COOLING')
    INSERT INTO dbo.field_options (field_definition_id, option_value, option_label, display_order)
    VALUES (@symptom_field, 'NOT_COOLING', N'Không mát', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.field_options WHERE field_definition_id = @symptom_field AND option_value = 'WATER_LEAK')
    INSERT INTO dbo.field_options (field_definition_id, option_value, option_label, display_order)
    VALUES (@symptom_field, 'WATER_LEAK', N'Chảy nước', 2);
IF NOT EXISTS (SELECT 1 FROM dbo.field_options WHERE field_definition_id = @symptom_field AND option_value = 'NOISE')
    INSERT INTO dbo.field_options (field_definition_id, option_value, option_label, display_order)
    VALUES (@symptom_field, 'NOISE', N'Tiếng ồn bất thường', 3);

IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @water_form AND field_key = 'leak_image')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@water_form, 'leak_image', N'Ảnh vị trí rò nước', 'IMAGE', 1, 1,
         N'{"minFiles":1,"maxFiles":5,"allowedTypes":["image/jpeg","image/png"]}');
IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @water_form AND field_key = 'precise_location')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, required, display_order, validation_rules)
    VALUES
        (@water_form, 'precise_location', N'Vị trí cụ thể', 'TEXTAREA', 1, 2,
         N'{"minLength":10,"maxLength":500}');

IF NOT EXISTS (SELECT 1 FROM dbo.field_definitions WHERE form_version_id = @safety_form AND field_key = 'impact_scope')
    INSERT INTO dbo.field_definitions
        (form_version_id, field_key, label, field_type, help_text, required, display_order, validation_rules)
    VALUES
        (@safety_form, 'impact_scope', N'Phạm vi ảnh hưởng', 'TEXTAREA',
         N'Nêu khu vực, số người hoặc tài sản có thể bị ảnh hưởng', 1, 1,
         N'{"minLength":20,"maxLength":1000}');
