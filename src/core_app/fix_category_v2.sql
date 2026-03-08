-- =====================================================
-- FIX CATEGORY MAPPING V2 - Comprehensive Reset & Reassign
-- =====================================================
USE shopeeweb_lab211;
GO

PRINT N'=== BƯỚC 1: Reset TẤT CẢ category_id về NULL ==='
UPDATE products SET category_id = NULL WHERE is_deleted = 0;
PRINT N'Đã reset ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- =====================================================
-- BƯỚC 2: Gán category_id theo tên sản phẩm
-- =====================================================

-- Category 1: Thời Trang Nam (Áo phông, Áo khoác, Áo thun CANIFA, Quần Jean, Nón, Ví da)
PRINT N'--- Category 1: Thời Trang Nam ---'
UPDATE products SET category_id = 1
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%phông%' 
    OR name LIKE N'%khoác%'
    OR name LIKE N'%thun%CANIFA%'
    OR name LIKE N'%Jean%'
    OR name LIKE N'%Nón%'
    OR name LIKE N'%nón%'
    OR name LIKE N'%Ví da nam%'
    OR name LIKE N'%ví da nam%'
    OR name LIKE N'%Quần short%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 2: Điện Thoại & Phụ Kiện (Ốp lưng iPhone)
PRINT N'--- Category 2: Điện Thoại & Phụ Kiện ---'
UPDATE products SET category_id = 2
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%ốp lưng%'
    OR name LIKE N'%Ốp lưng%'
    OR name LIKE N'%ốp lung%'
    OR name LIKE N'%iPhone%'
    OR name LIKE N'%Samsung%'
    OR name LIKE N'%điện thoại%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 3: Thiết Bị Điện Tử (Tai nghe Bluetooth)
PRINT N'--- Category 3: Thiết Bị Điện Tử ---'
UPDATE products SET category_id = 3
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Tai nghe%'
    OR name LIKE N'%tai nghe%'
    OR name LIKE N'%Bluetooth%'
    OR name LIKE N'%bluetooth%'
    OR name LIKE N'%loa%'
    OR name LIKE N'%Loa%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 6: Đồng Hồ
PRINT N'--- Category 6: Đồng Hồ ---'
UPDATE products SET category_id = 6
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Đồng hồ%'
    OR name LIKE N'%đồng hồ%'
    OR name LIKE N'%dong ho%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 7: Giày Dép Nam (Giày Sneaker, Dép quai ngang)
PRINT N'--- Category 7: Giày Dép Nam ---'
UPDATE products SET category_id = 7
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Giày%' 
    OR name LIKE N'%giày%'
    OR name LIKE N'%Sneaker%'
    OR name LIKE N'%sneaker%'
    OR name LIKE N'%Dép%'
    OR name LIKE N'%dép%'
    OR name LIKE N'%sandal%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 9: Thể Thao & Du Lịch (Balo)
PRINT N'--- Category 9: Thể Thao & Du Lịch ---'
UPDATE products SET category_id = 9
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Balo%'
    OR name LIKE N'%balo%'
    OR name LIKE N'%ba lô%'
    OR name LIKE N'%thể thao%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 13: Nhà Cửa & Đời Sống (Đèn LED)
PRINT N'--- Category 13: Nhà Cửa & Đời Sống ---'
UPDATE products SET category_id = 13
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Đèn%'
    OR name LIKE N'%đèn%'
    OR name LIKE N'%LED%'
    OR name LIKE N'%nến%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 14: Sắc Đẹp (Kính mát)
PRINT N'--- Category 14: Sắc Đẹp ---'
UPDATE products SET category_id = 14
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Kính%'
    OR name LIKE N'%kính%'
    OR name LIKE N'%mắt%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- Category 17: Túi Ví Nữ (Túi đeo chéo)
PRINT N'--- Category 17: Túi Ví Nữ ---'
UPDATE products SET category_id = 17
WHERE is_deleted = 0 AND category_id IS NULL
AND (
    name LIKE N'%Túi%'
    OR name LIKE N'%túi%'
);
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm'
GO

-- =====================================================
-- BƯỚC 3: Gán tất cả sản phẩm còn NULL về Thời Trang Nam (default)
-- =====================================================
PRINT N'--- Default → Category 1: Thời Trang Nam ---'
UPDATE products SET category_id = 1
WHERE is_deleted = 0 AND category_id IS NULL;
PRINT N'  → Đã gán ' + CAST(@@ROWCOUNT AS VARCHAR) + N' sản phẩm còn lại'
GO

-- =====================================================
-- BƯỚC 4: Kiểm tra kết quả
-- =====================================================
PRINT N''
PRINT N'=== KẾT QUẢ CUỐI CÙNG ==='
SELECT c.id, c.name AS category_name, COUNT(p.id) AS product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id AND p.is_deleted = 0
WHERE c.is_deleted = 0
GROUP BY c.id, c.name
ORDER BY c.id;

-- Kiểm tra còn NULL không
SELECT COUNT(*) AS products_without_category
FROM products
WHERE is_deleted = 0 AND category_id IS NULL;

PRINT N'=== HOÀN TẤT fix_category_v2.sql ==='
GO
