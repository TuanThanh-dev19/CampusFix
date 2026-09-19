# CampusFix SQL Server schema

## Nguồn khởi tạo database

CampusFix dùng Flyway làm nguồn duy nhất để tạo và nâng cấp bảng ứng dụng:

```text
backend/src/main/resources/db/migration/
├── V1__create_user_and_role_tables.sql
├── V2__create_location_and_asset_tables.sql
├── V3__create_dynamic_category_tables.sql
├── V4__create_ticket_workflow_tables.sql
├── V5__seed_reference_data.sql
├── V6__complete_erd_support_tables.sql
└── V7__seed_skill_and_sla_reference_data.sql
```

Docker service `sqlserver-init` chỉ tạo database rỗng `campusfix`. Khi backend
khởi động, Flyway tự chạy lần lượt V1 đến V7 để tạo bảng, khóa ngoại, constraint,
index và dữ liệu nền.

## File SQL gộp để chạy thủ công

File `infrastructure/sqlserver/campusfix_full_schema.sql` chứa toàn bộ nội dung
V1 đến V7 trong một file duy nhất. File này dành cho việc nộp bài, đọc schema,
hoặc khởi tạo thủ công bằng SSMS/`sqlcmd` trên database mới và rỗng.

Không chạy file gộp trên database đã được Flyway quản lý, và không dùng đồng
thời hai cách khởi tạo trên cùng database:

- Phát triển Spring Boot: dùng Flyway bằng cách khởi động backend.
- Khởi tạo thủ công độc lập: dùng `campusfix_full_schema.sql` một lần trên
  database rỗng.

Chạy file gộp trong SQL Server Docker:

```powershell
docker compose exec -T sqlserver /bin/bash -c '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -d master -i /opt/campusfix/sql/campusfix_full_schema.sql'
```

Trong SSMS, mở file, kết nối SQL Server và chọn **Execute**. Script tự tạo
database `campusfix` nếu database chưa tồn tại và dừng với lỗi nếu database đã
có bảng, nhằm tránh ghi đè dữ liệu.

Khi nhóm thêm migration V8 trở lên, file gộp cũng phải được cập nhật nếu vẫn
muốn dùng nó để nộp hoặc khởi tạo thủ công. Flyway migrations mới vẫn là nguồn
chính thức của backend.

## Nhóm bảng

| Nhóm | Bảng vật lý chính |
|---|---|
| User và role | `app_users`, `roles`, `user_roles` |
| Kỹ thuật viên | `technician_profiles`, `skills`, `technician_skills`, `technician_service_areas` |
| Địa điểm và thiết bị | `locations`, `equipment_types`, `assets`, `asset_status_history` |
| Category động | `incident_categories`, `category_form_versions`, `field_definitions`, `field_options` |
| Ticket workflow | `tickets`, `ticket_field_values`, `ticket_assignments`, `ticket_status_history`, `work_logs`, `ticket_comments`, `ticket_attachments` |
| Hậu xử lý | `ticket_feedback`, `notifications`, `audit_logs` |
| Kiểm tra thông tin | `ticket_accuracy_reviews`, `violation_cases`, `violation_appeals` |
| SLA | `sla_policies` |

Hai bảng `violation_cases` và `violation_appeals` thuộc scope P1. Chúng có sẵn
trong schema để đúng ERD, nhưng nhóm có thể chưa làm API/UI cho chúng trong MVP.
Kết quả `NO_FAULT_FOUND` không tự động tạo violation; manager phải mở case và
xem xét bằng chứng.

## Quyết định physical model

ERD là logical model nên dùng tên entity số ít và kiểu `UUID`. Physical schema
dùng tên bảng số nhiều và `BIGINT IDENTITY` để JPA/SQL đơn giản hơn cho project
SBA301. Các quan hệ nghiệp vụ chính được bảo vệ bằng PK, FK, unique constraint
và filtered unique index.

Một số khác biệt có chủ đích so với logical ERD:

- `tickets.form_version_id` và `tickets.location_id` là bắt buộc trong physical
  schema để mọi ticket đã lưu luôn có category form và địa điểm rõ ràng.
- `incident_categories.created_by`, `asset_status_history.changed_by` và
  `user_roles.assigned_by` cho phép `NULL` để hỗ trợ seed/migration do hệ thống
  thực hiện, không phải thao tác trực tiếp của user.
- SLA là reference policy dùng chung; form version lưu FK đến policy. Nếu cần
  thay đổi thời hạn mà vẫn giữ snapshot tuyệt đối, hãy tạo policy mới thay vì
  cập nhật policy đã được form published sử dụng.

`TICKET_FIELD_VALUE` trong ERD mô tả các giá trị typed. Physical schema lưu giá
trị động trong `value_json` có `ISJSON` constraint; backend phải kiểm tra type,
required, min/max và option dựa trên `field_definitions.validation_rules`.

Các rule liên bảng như “feedback phải do đúng reporter tạo” hoặc “user được
assign phải có role TECHNICIAN” vẫn phải được kiểm tra ở service layer và bằng
integration test; chúng không phù hợp để biểu diễn hoàn toàn bằng FK đơn giản.

## Khởi tạo local

Tại thư mục gốc repository:

```powershell
Copy-Item .env.example .env
docker compose up -d

cd backend
.\mvnw.cmd spring-boot:run
```

Khi backend khởi động lần đầu, log phải hiển thị Flyway migrate đến version `7`.
Không chạy lại hoặc sửa migration đã áp dụng; thay đổi schema tiếp theo phải tạo
V8, V9, ...

Sau khi migration hoàn tất, dừng backend bằng `Ctrl+C`, quay lại thư mục gốc và
kiểm tra schema bằng SQL Server container:

```powershell
cd ..
docker compose exec -T sqlserver /bin/bash -c '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -d campusfix -i /opt/campusfix/sql/verify-schema.sql'
```

File được mount read-only vào container bởi `compose.yaml`. Cách kiểm tra độc
lập trên database sạch là chạy integration test SQL Server thật:

```powershell
cd backend
$env:RUN_SQLSERVER_IT='true'
.\mvnw.cmd -Dtest=SqlServerMigrationIntegrationTest test
Remove-Item Env:RUN_SQLSERVER_IT
```
