USE shopeeweb_lab211;
GO

IF OBJECT_ID('dbo.users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(50) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        role VARCHAR(20) DEFAULT 'CUSTOMER' CHECK(role IN ('CUSTOMER', 'SELLER', 'ADMIN')),
        created_at DATETIME DEFAULT GETDATE(),
        email NVARCHAR(100),
        phone NVARCHAR(20),
        wallet DECIMAL(10,2) DEFAULT 0,
        note NVARCHAR(MAX),
        is_deleted BIT DEFAULT 0
    );
    PRINT N'✅ Đã tạo bảng users';
END
ELSE
    PRINT N'✅ Bảng users đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.categories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.categories (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        image_url NVARCHAR(255),
        is_deleted BIT DEFAULT 0
    );
    PRINT N'✅ Đã tạo bảng categories';
    
    -- Insert mock data array
    SET IDENTITY_INSERT dbo.categories ON;
    INSERT INTO dbo.categories (id, name, image_url) VALUES 
        (1, N'Thời Trang Nam', 'images/cat_thoi_trang_nam.webp'),
        (2, N'Điện Thoại & Phụ Kiện', 'images/cat_dien_thoai.webp'),
        (3, N'Thiết Bị Điện Tử', 'images/cat_thiet_bi_dien_tu.webp'),
        (4, N'Máy Tính & Laptop', 'images/cat_may_tinh_laptop.webp'),
        (5, N'Máy Ảnh & Máy Quay Phim', 'images/cat_may_anh.webp'),
        (6, N'Đồng Hồ', 'images/cat_dong_ho.webp'),
        (7, N'Giày Dép Nam', 'images/cat_giay_dep_nam.webp'),
        (8, N'Thiết Bị Điện Gia Dụng', 'images/cat_thiet_bi_gia_dung.webp'),
        (9, N'Thể Thao & Du Lịch', 'images/cat_the_thao.webp'),
        (10, N'Ô Tô & Xe Máy & Xe Đạp', 'images/cat_oto_xe_may.webp'),
        (11, N'Thời Trang Nữ', 'images/cat_thoi_trang_nu.webp'),
        (12, N'Mẹ & Bé', 'images/cat_me_be.webp'),
        (13, N'Nhà Cửa & Đời Sống', 'images/cat_nha_cua.webp'),
        (14, N'Sắc Đẹp', 'images/cat_sac_dep.webp'),
        (15, N'Sức Khỏe', 'images/cat_suc_khoe.webp'),
        (16, N'Giày Dép Nữ', 'images/cat_giay_dep_nu.webp'),
        (17, N'Túi Ví Nữ', 'images/cat_tui_vi_nu.webp'),
        (18, N'Phụ Kiện & Trang Sức Nữ', 'images/cat_phu_kien_nu.webp'),
        (19, N'Bách Hóa Online', 'images/cat_bach_hoa.webp'),
        (20, N'Nhà Sách Online', 'images/cat_nha_sach.webp');
    SET IDENTITY_INSERT dbo.categories OFF;
    PRINT N'✅ Đã thêm dữ liệu mẫu vào categories';
END
ELSE
    PRINT N'✅ Bảng categories đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.shops', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.shops (
        id INT IDENTITY(1,1) PRIMARY KEY,
        owner_id INT NOT NULL,
        shop_name NVARCHAR(100) NOT NULL,
        rating DECIMAL(2,1) DEFAULT 0.0,
        response_rate NVARCHAR(10) DEFAULT '0%',
        response_time NVARCHAR(50) DEFAULT N'chưa có',
        avatar NVARCHAR(500),
        location NVARCHAR(50) DEFAULT N'Hà Nội',
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (owner_id) REFERENCES dbo.users(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng shops';
END
ELSE
BEGIN
    -- Migration: thêm cột mới nếu chưa có
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.shops') AND name = 'response_rate')
        ALTER TABLE dbo.shops ADD response_rate NVARCHAR(10) DEFAULT '0%';
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.shops') AND name = 'response_time')
        ALTER TABLE dbo.shops ADD response_time NVARCHAR(50) DEFAULT N'chưa có';
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.shops') AND name = 'avatar')
        ALTER TABLE dbo.shops ADD avatar NVARCHAR(500);
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.shops') AND name = 'location')
        ALTER TABLE dbo.shops ADD location NVARCHAR(50) DEFAULT N'Hà Nội';
    PRINT N'✅ Bảng shops đã tồn tại - đã kiểm tra/thêm cột mới';
END
GO

IF OBJECT_ID('dbo.products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.products (
        id INT IDENTITY(1,1) PRIMARY KEY,
        shop_id INT NOT NULL,
        category_id INT DEFAULT 1,
        name NVARCHAR(255) NOT NULL,
        description NVARCHAR(MAX),
        price DECIMAL(10,2) NOT NULL,
        image_url NVARCHAR(255),
        created_at DATETIME DEFAULT GETDATE(),
        is_deleted BIT DEFAULT 0,
        FOREIGN KEY (shop_id) REFERENCES dbo.shops(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES dbo.categories(id)
    );
    PRINT N'✅ Đã tạo bảng products';
END
ELSE
    PRINT N'✅ Bảng products đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.product_variants', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_variants (
        id INT IDENTITY(1,1) PRIMARY KEY,
        product_id INT NOT NULL,
        color NVARCHAR(50),
        size NVARCHAR(10),
        stock INT NOT NULL DEFAULT 0,
        price DECIMAL(10,2) NOT NULL,
        note NVARCHAR(255),
        FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng product_variants';
END
ELSE
    PRINT N'✅ Bảng product_variants đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.orders (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        total_price DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'COMPLETED', 'CANCELLED')),
        created_at DATETIME DEFAULT GETDATE(),
        is_deleted BIT DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng orders';
END
ELSE
    PRINT N'✅ Bảng orders đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.order_items (
        id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL,
        variant_id INT NOT NULL,
        quantity INT NOT NULL,
        price_at_purchase DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES dbo.product_variants(id)
    );
    PRINT N'✅ Đã tạo bảng order_items';
END
ELSE
    PRINT N'✅ Bảng order_items đã tồn tại - giữ nguyên dữ liệu';
GO

IF OBJECT_ID('dbo.audit_logs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs (
        id INT IDENTITY(1,1) PRIMARY KEY,
        admin_id INT NOT NULL,
        action VARCHAR(50) NOT NULL,
        target_table VARCHAR(50) NOT NULL,
        target_id VARCHAR(50) NOT NULL,
        details NVARCHAR(255),
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (admin_id) REFERENCES dbo.users(id)
    );
    PRINT N'✅ Đã tạo bảng audit_logs';
END
ELSE
    PRINT N'✅ Bảng audit_logs đã tồn tại - giữ nguyên dữ liệu';
GO

-- Migration: Thêm cột gender và date_of_birth nếu chưa có
IF COL_LENGTH('dbo.users', 'gender') IS NULL
BEGIN
    ALTER TABLE dbo.users ADD gender NVARCHAR(10);
    PRINT N'✅ Đã thêm cột gender vào bảng users';
END
ELSE
    PRINT N'✅ Cột gender đã tồn tại - giữ nguyên';
GO

IF COL_LENGTH('dbo.users', 'date_of_birth') IS NULL
BEGIN
    ALTER TABLE dbo.users ADD date_of_birth DATE;
    PRINT N'✅ Đã thêm cột date_of_birth vào bảng users';
END
ELSE
    PRINT N'✅ Cột date_of_birth đã tồn tại - giữ nguyên';
GO

-- Chỉ thêm admin nếu chưa có
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE username = 'admin')
BEGIN
    INSERT INTO dbo.users (username, password, full_name, role) VALUES ('admin', 'admin123', 'System Admin', 'ADMIN');
    PRINT N'✅ Đã tạo tài khoản admin mặc định';
END
ELSE
    PRINT N'✅ Tài khoản admin đã tồn tại - giữ nguyên';
GO

-- Migration: Thêm category_id vào bảng products nếu chưa có
IF COL_LENGTH('dbo.products', 'category_id') IS NULL
BEGIN
    ALTER TABLE dbo.products ADD category_id INT;
    PRINT N'✅ Đã thêm cột category_id vào bảng products';
    
    -- Cập nhật dữ liệu cũ theo công thức random ban đầu
    EXEC('UPDATE dbo.products SET category_id = (id % 20) + 1 WHERE category_id IS NULL');
    
    -- Thêm khoá ngoại
    ALTER TABLE dbo.products ADD CONSTRAINT FK_Product_Category FOREIGN KEY (category_id) REFERENCES dbo.categories(id);
    PRINT N'✅ Đã cập nhật khoá ngoại category_id';
END
ELSE
    PRINT N'✅ Cột category_id đã tồn tại - giữ nguyên';
GO

-- ==========================================
-- MIGRATION: ADVANCED RBAC (ROLE-BASED ACCESS CONTROL)
-- ==========================================

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

-- ==========================================
-- MIGRATION: BẢNG WISHLIST (YÊU THÍCH)
-- ==========================================
IF OBJECT_ID('dbo.wishlist', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.wishlist (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        product_id INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_wishlist_user_product UNIQUE (user_id, product_id),
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng wishlist';
END
ELSE
    PRINT N'✅ Bảng wishlist đã tồn tại - giữ nguyên dữ liệu';
GO

-- ==========================================
-- MIGRATION: BẢNG SHOP_FOLLOWERS (THEO DÕI SHOP)
-- ==========================================
IF OBJECT_ID('dbo.shop_followers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.shop_followers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        shop_id INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_follow_user_shop UNIQUE (user_id, shop_id),
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
        FOREIGN KEY (shop_id) REFERENCES dbo.shops(id) ON DELETE CASCADE
    );
    PRINT N'✅ Đã tạo bảng shop_followers';
END
ELSE
    PRINT N'✅ Bảng shop_followers đã tồn tại - giữ nguyên dữ liệu';
GO

-- ==========================================
-- MIGRATION: Cập nhật dữ liệu thật cho shops
-- ==========================================
UPDATE dbo.shops SET 
    response_rate = CAST(CAST(70 + (id % 31) AS INT) AS NVARCHAR) + '%',
    response_time = CASE 
        WHEN id % 4 = 0 THEN N'trong vài phút'
        WHEN id % 4 = 1 THEN N'trong vài giờ'
        WHEN id % 4 = 2 THEN N'trong 1 giờ'
        ELSE N'trong 15 phút'
    END,
    avatar = CASE
        WHEN id % 5 = 0 THEN 'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?w=100&h=100&fit=crop'
        WHEN id % 5 = 1 THEN 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?w=100&h=100&fit=crop'
        WHEN id % 5 = 2 THEN 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?w=100&h=100&fit=crop'
        WHEN id % 5 = 3 THEN 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?w=100&h=100&fit=crop'
        ELSE 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?w=100&h=100&fit=crop'
    END,
    location = CASE
        WHEN id % 3 = 0 THEN N'Hà Nội'
        WHEN id % 3 = 1 THEN N'TP. Hồ Chí Minh'
        ELSE N'Thái Nguyên'
    END
WHERE response_rate IS NULL OR response_rate = '0%' OR location IS NULL;
PRINT N'✅ Đã cập nhật dữ liệu shops (response_rate, response_time, avatar, location)';
GO
