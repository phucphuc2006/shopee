USE shopeeweb_lab211;
GO

-- ==========================================
-- PERFORMANCE: Tạo các index tối ưu tốc độ truy vấn
-- ==========================================

-- Index cho bảng products (bảng chính, truy vấn nhiều nhất)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_products_category_deleted' AND object_id = OBJECT_ID('products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_products_category_deleted 
    ON products(category_id, is_deleted) 
    INCLUDE (name, image_url, shop_id, price);
    PRINT N'✅ Đã tạo index IX_products_category_deleted';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_products_name' AND object_id = OBJECT_ID('products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_products_name 
    ON products(name) 
    INCLUDE (category_id, is_deleted, shop_id, image_url);
    PRINT N'✅ Đã tạo index IX_products_name';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_products_shop_id' AND object_id = OBJECT_ID('products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_products_shop_id 
    ON products(shop_id) 
    INCLUDE (category_id, is_deleted);
    PRINT N'✅ Đã tạo index IX_products_shop_id';
END
GO

-- Index cho bảng product_variants (JOIN thường xuyên)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_variants_product_price' AND object_id = OBJECT_ID('product_variants'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_variants_product_price 
    ON product_variants(product_id) 
    INCLUDE (price, stock_quantity);
    PRINT N'✅ Đã tạo index IX_variants_product_price';
END
GO

-- Index cho bảng order_items (LEFT JOIN trong search)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_order_items_variant' AND object_id = OBJECT_ID('order_items'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_order_items_variant 
    ON order_items(variant_id) 
    INCLUDE (quantity);
    PRINT N'✅ Đã tạo index IX_order_items_variant';
END
GO

-- Index cho bảng shops (JOIN trong search)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_shops_rating_location' AND object_id = OBJECT_ID('shops'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_shops_rating_location 
    ON shops(id) 
    INCLUDE (shop_name, rating, location);
    PRINT N'✅ Đã tạo index IX_shops_rating_location';
END
GO

-- Index cho bảng categories (filter)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_categories_deleted' AND object_id = OBJECT_ID('categories'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_categories_deleted 
    ON categories(is_deleted) 
    INCLUDE (name, image_url);
    PRINT N'✅ Đã tạo index IX_categories_deleted';
END
GO

-- Update statistics để SQL Server biết dùng index mới
UPDATE STATISTICS products;
UPDATE STATISTICS product_variants;
UPDATE STATISTICS order_items;
UPDATE STATISTICS shops;
UPDATE STATISTICS categories;
PRINT N'✅ Đã cập nhật statistics cho tất cả bảng';
GO

PRINT N'✅ HOÀN TẤT tạo indexes tối ưu hiệu suất!';
GO
