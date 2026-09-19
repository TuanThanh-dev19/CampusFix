IF NOT EXISTS (SELECT 1 FROM dbo.skills WHERE code = 'PROJECTOR')
    INSERT INTO dbo.skills (code, name) VALUES ('PROJECTOR', N'Sửa chữa máy chiếu');
IF NOT EXISTS (SELECT 1 FROM dbo.skills WHERE code = 'HVAC')
    INSERT INTO dbo.skills (code, name) VALUES ('HVAC', N'Điều hòa và thông gió');
IF NOT EXISTS (SELECT 1 FROM dbo.skills WHERE code = 'PLUMBING')
    INSERT INTO dbo.skills (code, name) VALUES ('PLUMBING', N'Cấp thoát nước');
IF NOT EXISTS (SELECT 1 FROM dbo.skills WHERE code = 'SAFETY')
    INSERT INTO dbo.skills (code, name) VALUES ('SAFETY', N'An toàn cơ sở vật chất');

IF NOT EXISTS (SELECT 1 FROM dbo.sla_policies WHERE policy_name = N'Low - 72 hours')
    INSERT INTO dbo.sla_policies
        (policy_name, priority, resolution_minutes, pause_waiting_requester)
    VALUES (N'Low - 72 hours', 'LOW', 4320, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.sla_policies WHERE policy_name = N'Normal - 24 hours')
    INSERT INTO dbo.sla_policies
        (policy_name, priority, resolution_minutes, pause_waiting_requester)
    VALUES (N'Normal - 24 hours', 'NORMAL', 1440, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.sla_policies WHERE policy_name = N'High - 4 hours')
    INSERT INTO dbo.sla_policies
        (policy_name, priority, resolution_minutes, pause_waiting_requester)
    VALUES (N'High - 4 hours', 'HIGH', 240, 0);
IF NOT EXISTS (SELECT 1 FROM dbo.sla_policies WHERE policy_name = N'Urgent - 1 hour')
    INSERT INTO dbo.sla_policies
        (policy_name, priority, resolution_minutes, pause_waiting_requester)
    VALUES (N'Urgent - 1 hour', 'URGENT', 60, 0);

DECLARE @projector_skill BIGINT = (SELECT id FROM dbo.skills WHERE code = 'PROJECTOR');
DECLARE @hvac_skill BIGINT = (SELECT id FROM dbo.skills WHERE code = 'HVAC');
DECLARE @plumbing_skill BIGINT = (SELECT id FROM dbo.skills WHERE code = 'PLUMBING');
DECLARE @safety_skill BIGINT = (SELECT id FROM dbo.skills WHERE code = 'SAFETY');
DECLARE @normal_sla BIGINT = (
    SELECT id FROM dbo.sla_policies WHERE policy_name = N'Normal - 24 hours'
);
DECLARE @high_sla BIGINT = (
    SELECT id FROM dbo.sla_policies WHERE policy_name = N'High - 4 hours'
);
DECLARE @urgent_sla BIGINT = (
    SELECT id FROM dbo.sla_policies WHERE policy_name = N'Urgent - 1 hour'
);

UPDATE form_version
SET form_version.requires_equipment = 1,
    form_version.min_attachment_count = 1,
    form_version.default_skill_id = @projector_skill,
    form_version.default_sla_policy_id = @normal_sla
FROM dbo.category_form_versions AS form_version
JOIN dbo.incident_categories AS category
    ON category.id = form_version.category_id
WHERE category.code = 'PROJECTOR_ISSUE'
  AND form_version.version_number = 1
  AND form_version.form_status = 'PUBLISHED';

UPDATE form_version
SET form_version.requires_equipment = 0,
    form_version.min_attachment_count = 0,
    form_version.default_skill_id = @hvac_skill,
    form_version.default_sla_policy_id = @normal_sla
FROM dbo.category_form_versions AS form_version
JOIN dbo.incident_categories AS category
    ON category.id = form_version.category_id
WHERE category.code = 'AIR_CONDITIONER_ISSUE'
  AND form_version.version_number = 1
  AND form_version.form_status = 'PUBLISHED';

UPDATE form_version
SET form_version.requires_equipment = 0,
    form_version.min_attachment_count = 1,
    form_version.default_skill_id = @plumbing_skill,
    form_version.default_sla_policy_id = @high_sla
FROM dbo.category_form_versions AS form_version
JOIN dbo.incident_categories AS category
    ON category.id = form_version.category_id
WHERE category.code = 'WATER_LEAK'
  AND form_version.version_number = 1
  AND form_version.form_status = 'PUBLISHED';

UPDATE form_version
SET form_version.requires_equipment = 0,
    form_version.min_attachment_count = 0,
    form_version.default_skill_id = @safety_skill,
    form_version.default_sla_policy_id = @urgent_sla
FROM dbo.category_form_versions AS form_version
JOIN dbo.incident_categories AS category
    ON category.id = form_version.category_id
WHERE category.code = 'SAFETY_INCIDENT'
  AND form_version.version_number = 1
  AND form_version.form_status = 'PUBLISHED';
