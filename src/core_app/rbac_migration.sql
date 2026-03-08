USE shopeeweb_lab211;
GO

IF OBJECT_ID('dbo.admin_permissions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.admin_permissions (
        id VARCHAR(50) PRIMARY KEY,
        description NVARCHAR(255) NOT NULL
    );
    PRINT N'✅ Đã tạo bảng admin_permissions';
END
GO

IF OBJECT_ID('dbo.admin_roles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.admin_roles (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL UNIQUE,
        description NVARCHAR(MAX)
    );
    PRINT N'✅ Đã tạo bảng admin_roles';
END
GO

IF OBJECT_ID('dbo.admin_role_permissions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.admin_role_permissions (
        role_id INT NOT NULL,
        permission_id VARCHAR(50) NOT NULL,
        PRIMARY KEY (role_id, permission_id),
        FOREIGN KEY (role_id) REFERENCES dbo.admin_roles(id) ON DELETE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES dbo.admin_permissions(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng admin_role_permissions';
END
GO

IF COL_LENGTH('dbo.users', 'admin_role_id') IS NULL
BEGIN
    ALTER TABLE dbo.users ADD admin_role_id INT;
    ALTER TABLE dbo.users ADD CONSTRAINT FK_User_AdminRole FOREIGN KEY (admin_role_id) REFERENCES dbo.admin_roles(id) ON DELETE SET NULL;
    PRINT N'✅ Đã thêm cột admin_role_id vào bảng users';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.admin_permissions)
BEGIN
    INSERT INTO dbo.admin_permissions (id, description) VALUES 
    ('VIEW_DASHBOARD', N'Xem Tổng Quan'),
    ('MANAGE_PRODUCTS', N'Quản lý Sản phẩm'),
    ('MANAGE_CATEGORIES', N'Quản lý Danh mục'),
    ('MANAGE_ORDERS', N'Quản lý Đơn hàng'),
    ('MANAGE_USERS', N'Quản lý Khách hàng'),
    ('VIEW_AUDIT_LOGS', N'Xem Nhật ký hệ thống'),
    ('MANAGE_SYSTEM', N'Tạo & Import dữ liệu, Quản lý Roles');
    PRINT N'✅ Đã thêm dữ liệu mẫu permissions';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.admin_roles)
BEGIN
    SET IDENTITY_INSERT dbo.admin_roles ON;
    INSERT INTO dbo.admin_roles (id, name, description) VALUES 
    (1, N'Super Admin', N'Toàn quyền quản trị hệ thống'),
    (2, N'Quản lý Cửa Hàng', N'Quản lý sản phẩm, đơn hàng, danh mục');
    SET IDENTITY_INSERT dbo.admin_roles OFF;
    PRINT N'✅ Đã thêm dữ liệu mẫu roles';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.admin_role_permissions)
BEGIN
    -- Cấp full quyền cho Super Admin
    INSERT INTO dbo.admin_role_permissions (role_id, permission_id) 
    SELECT 1, id FROM dbo.admin_permissions;
    
    -- Cấp quyền cho Quản lý cửa hàng
    INSERT INTO dbo.admin_role_permissions (role_id, permission_id) VALUES 
    (2, 'VIEW_DASHBOARD'), (2, 'MANAGE_PRODUCTS'), (2, 'MANAGE_CATEGORIES'), (2, 'MANAGE_ORDERS');
    PRINT N'✅ Đã cấp quyền mẫu cho role';
END
GO

IF EXISTS (SELECT 1 FROM dbo.users WHERE username = 'admin' AND admin_role_id IS NULL)
BEGIN
    UPDATE dbo.users SET admin_role_id = 1 WHERE username = 'admin';
    PRINT N'✅ Đã cấp Super Admin cho tk admin mặc định';
END
GO
