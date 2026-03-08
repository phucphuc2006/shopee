USE shopeeweb_lab211;
GO

-- ==========================================
-- FIX: Cập nhật category_id cho sản phẩm dựa trên tên
-- Danh mục:
--  1  = Thời Trang Nam
--  2  = Điện Thoại & Phụ Kiện
--  3  = Thiết Bị Điện Tử
--  4  = Máy Tính & Laptop
--  5  = Máy Ảnh & Máy Quay Phim
--  6  = Đồng Hồ
--  7  = Giày Dép Nam
--  8  = Thiết Bị Điện Gia Dụng
--  9  = Thể Thao & Du Lịch
--  10 = Ô Tô & Xe Máy & Xe Đạp
--  11 = Thời Trang Nữ
--  12 = Mẹ & Bé
--  13 = Nhà Cửa & Đời Sống
--  14 = Sắc Đẹp
--  15 = Sức Khỏe
--  16 = Giày Dép Nữ
--  17 = Túi Ví Nữ
--  18 = Phụ Kiện & Trang Sức Nữ
--  19 = Bách Hóa Online
--  20 = Nhà Sách Online
-- ==========================================

-- 2 = Điện Thoại & Phụ Kiện (iPhone, Samsung, điện thoại, ốp lưng, sạc, tai nghe, cáp)
UPDATE dbo.products SET category_id = 2
WHERE name LIKE N'%iPhone%' 
   OR name LIKE N'%Samsung%'
   OR name LIKE N'%điện thoại%'
   OR name LIKE N'%ốp lưng%'
   OR name LIKE N'%Ốp Lưng%'
   OR name LIKE N'%ốp lung%'
   OR name LIKE N'%Op lung%'
   OR name LIKE N'%sạc%'
   OR name LIKE N'%tai nghe%'
   OR name LIKE N'%Tai Nghe%'
   OR name LIKE N'%airpod%'
   OR name LIKE N'%AirPod%'
   OR name LIKE N'%cáp%'
   OR name LIKE N'%cable%'
   OR name LIKE N'%phụ kiện điện thoại%'
   OR name LIKE N'%kính cường lực%'
   OR name LIKE N'%miếng dán%' 
   OR name LIKE N'%pin sạc%'
   OR name LIKE N'%củ sạc%'
   OR name LIKE N'%dây sạc%';

PRINT N'✅ Đã cập nhật Điện Thoại & Phụ Kiện';

-- 1 = Thời Trang Nam (áo nam, quần nam, áo thun nam, áo khoác nam)
UPDATE dbo.products SET category_id = 1
WHERE (name LIKE N'%áo%' OR name LIKE N'%Áo%' OR name LIKE N'%ao%') 
  AND (name LIKE N'%nam%' OR name LIKE N'%Nam%')
  AND category_id NOT IN (7, 9, 16);

UPDATE dbo.products SET category_id = 1
WHERE (name LIKE N'%quần%' OR name LIKE N'%Quần%' OR name LIKE N'%quan%') 
  AND (name LIKE N'%nam%' OR name LIKE N'%Nam%')
  AND category_id NOT IN (7, 9);

UPDATE dbo.products SET category_id = 1
WHERE name LIKE N'%áo phông nam%'
   OR name LIKE N'%áo thun nam%'
   OR name LIKE N'%áo sơ mi nam%'
   OR name LIKE N'%áo khoác nam%'
   OR name LIKE N'%quần jean nam%'
   OR name LIKE N'%quần short nam%'
   OR name LIKE N'%quần kaki nam%';

PRINT N'✅ Đã cập nhật Thời Trang Nam';

-- 11 = Thời Trang Nữ (áo nữ, quần nữ, đầm, váy)
UPDATE dbo.products SET category_id = 11
WHERE (name LIKE N'%áo%' OR name LIKE N'%Áo%') 
  AND (name LIKE N'%nữ%' OR name LIKE N'%Nữ%')
  AND category_id NOT IN (7, 16, 17, 18);

UPDATE dbo.products SET category_id = 11
WHERE (name LIKE N'%quần%' OR name LIKE N'%Quần%') 
  AND (name LIKE N'%nữ%' OR name LIKE N'%Nữ%')
  AND category_id NOT IN (7, 16, 17);

UPDATE dbo.products SET category_id = 11
WHERE name LIKE N'%đầm%'
   OR name LIKE N'%váy%'
   OR name LIKE N'%Váy%'
   OR name LIKE N'%Đầm%'
   OR name LIKE N'%chân váy%'
   OR name LIKE N'%áo croptop%'
   OR name LIKE N'%áo kiểu nữ%'
   OR name LIKE N'%set nữ%';

PRINT N'✅ Đã cập nhật Thời Trang Nữ';

-- Với sản phẩm có "nam nữ" (unisex) - gán vào Thời Trang Nam
UPDATE dbo.products SET category_id = 1
WHERE (name LIKE N'%áo phông nam nữ%' OR name LIKE N'%áo thun nam nữ%')
  AND category_id NOT IN (1);

-- 4 = Máy Tính & Laptop
UPDATE dbo.products SET category_id = 4
WHERE name LIKE N'%laptop%'
   OR name LIKE N'%Laptop%'
   OR name LIKE N'%máy tính%'
   OR name LIKE N'%Máy Tính%'
   OR name LIKE N'%bàn phím%'
   OR name LIKE N'%chuột%'
   OR name LIKE N'%mouse%'
   OR name LIKE N'%keyboard%'
   OR name LIKE N'%màn hình%'
   OR name LIKE N'%monitor%'
   OR name LIKE N'%ram%'
   OR name LIKE N'%SSD%'
   OR name LIKE N'%ổ cứng%'
   OR name LIKE N'%USB%'
   OR name LIKE N'%lót chuột%';

PRINT N'✅ Đã cập nhật Máy Tính & Laptop';

-- 3 = Thiết Bị Điện Tử (loa, camera, smart, thiết bị)
UPDATE dbo.products SET category_id = 3
WHERE name LIKE N'%loa%'
   OR name LIKE N'%Loa%'
   OR name LIKE N'%TV%'
   OR name LIKE N'%tivi%'
   OR name LIKE N'%camera%'
   OR name LIKE N'%Camera%'
   OR name LIKE N'%smart%'
   OR name LIKE N'%robot%'
   OR name LIKE N'%Robot%'
   OR name LIKE N'%bluetooth%';

PRINT N'✅ Đã cập nhật Thiết Bị Điện Tử';

-- 7 = Giày Dép Nam
UPDATE dbo.products SET category_id = 7
WHERE (name LIKE N'%giày%' OR name LIKE N'%Giày%' OR name LIKE N'%dép%' OR name LIKE N'%Dép%' OR name LIKE N'%sandal%')
  AND (name LIKE N'%nam%' OR name LIKE N'%Nam%');

PRINT N'✅ Đã cập nhật Giày Dép Nam';

-- 16 = Giày Dép Nữ
UPDATE dbo.products SET category_id = 16
WHERE (name LIKE N'%giày%' OR name LIKE N'%Giày%' OR name LIKE N'%dép%' OR name LIKE N'%Dép%' OR name LIKE N'%sandal%' OR name LIKE N'%guốc%' OR name LIKE N'%cao gót%')
  AND (name LIKE N'%nữ%' OR name LIKE N'%Nữ%');

PRINT N'✅ Đã cập nhật Giày Dép Nữ';

-- 6 = Đồng Hồ
UPDATE dbo.products SET category_id = 6
WHERE name LIKE N'%đồng hồ%'
   OR name LIKE N'%Đồng Hồ%'
   OR name LIKE N'%dong ho%';

PRINT N'✅ Đã cập nhật Đồng Hồ';

-- 5 = Máy Ảnh & Máy Quay Phim
UPDATE dbo.products SET category_id = 5
WHERE name LIKE N'%máy ảnh%'
   OR name LIKE N'%Máy Ảnh%'
   OR name LIKE N'%máy quay%'
   OR name LIKE N'%chân máy%'
   OR name LIKE N'%tripod%'
   OR name LIKE N'%gopro%'
   OR name LIKE N'%GoPro%'
   OR name LIKE N'%ống kính%';

PRINT N'✅ Đã cập nhật Máy Ảnh & Máy Quay Phim';

-- 8 = Thiết Bị Điện Gia Dụng (nồi, quạt, máy giặt, tủ lạnh, bếp, lò, ấm)
UPDATE dbo.products SET category_id = 8
WHERE name LIKE N'%nồi%'
   OR name LIKE N'%quạt%'
   OR name LIKE N'%máy giặt%'
   OR name LIKE N'%tủ lạnh%'
   OR name LIKE N'%bếp%'
   OR name LIKE N'%lò%'
   OR name LIKE N'%ấm%'
   OR name LIKE N'%máy xay%'
   OR name LIKE N'%máy hút%'
   OR name LIKE N'%bàn ủi%'
   OR name LIKE N'%máy sấy%'
   OR name LIKE N'%máy lọc%';

PRINT N'✅ Đã cập nhật Thiết Bị Điện Gia Dụng';

-- 9 = Thể Thao & Du Lịch
UPDATE dbo.products SET category_id = 9
WHERE name LIKE N'%thể thao%'
   OR name LIKE N'%bóng đá%'
   OR name LIKE N'%bóng rổ%'
   OR name LIKE N'%tập gym%'
   OR name LIKE N'%yoga%'
   OR name LIKE N'%cầu lông%'
   OR name LIKE N'%vợt%'
   OR name LIKE N'%balo%'
   OR name LIKE N'%ba lô%'
   OR name LIKE N'%vali%'
   OR name LIKE N'%du lịch%';

PRINT N'✅ Đã cập nhật Thể Thao & Du Lịch';

-- 10 = Ô Tô & Xe Máy & Xe Đạp  
UPDATE dbo.products SET category_id = 10
WHERE name LIKE N'%xe máy%'
   OR name LIKE N'%ô tô%'
   OR name LIKE N'%xe đạp%'
   OR name LIKE N'%mũ bảo hiểm%'
   OR name LIKE N'%Mũ Bảo Hiểm%'
   OR name LIKE N'%phụ tùng%'
   OR name LIKE N'%đèn xe%'
   OR name LIKE N'%nhớt%';

PRINT N'✅ Đã cập nhật Ô Tô & Xe Máy & Xe Đạp';

-- 12 = Mẹ & Bé
UPDATE dbo.products SET category_id = 12
WHERE name LIKE N'%bỉm%'
   OR name LIKE N'%tã%'
   OR name LIKE N'%sữa bột%'
   OR name LIKE N'%bình sữa%'
   OR name LIKE N'%đồ chơi bé%'
   OR name LIKE N'%trẻ em%'
   OR name LIKE N'%em bé%'
   OR name LIKE N'%baby%';

PRINT N'✅ Đã cập nhật Mẹ & Bé';

-- 13 = Nhà Cửa & Đời Sống (đèn, kệ, thảm, chậu, rèm, gối)
UPDATE dbo.products SET category_id = 13
WHERE name LIKE N'%đèn led%'
   OR name LIKE N'%kệ%'
   OR name LIKE N'%thảm%'
   OR name LIKE N'%chậu%'
   OR name LIKE N'%rèm%'
   OR name LIKE N'%gối%'
   OR name LIKE N'%ga giường%'
   OR name LIKE N'%chăn%'
   OR name LIKE N'%nệm%'
   OR name LIKE N'%khăn tắm%'
   OR name LIKE N'%giặt%'
   OR name LIKE N'%drap%';

PRINT N'✅ Đã cập nhật Nhà Cửa & Đời Sống';

-- 14 = Sắc Đẹp (mỹ phẩm, son, kem, nước hoa, serum, tẩy trang)
UPDATE dbo.products SET category_id = 14
WHERE name LIKE N'%son%'
   OR name LIKE N'%Son%'
   OR name LIKE N'%kem%'
   OR name LIKE N'%nước hoa%'
   OR name LIKE N'%serum%'
   OR name LIKE N'%tẩy trang%'
   OR name LIKE N'%phấn%'
   OR name LIKE N'%mascara%'
   OR name LIKE N'%mỹ phẩm%'
   OR name LIKE N'%makeup%'
   OR name LIKE N'%trang điểm%'
   OR name LIKE N'%sữa rửa mặt%'
   OR name LIKE N'%mặt nạ%';

PRINT N'✅ Đã cập nhật Sắc Đẹp';

-- 15 = Sức Khỏe
UPDATE dbo.products SET category_id = 15
WHERE name LIKE N'%vitamin%'
   OR name LIKE N'%thực phẩm chức năng%'
   OR name LIKE N'%khẩu trang%'
   OR name LIKE N'%Khẩu Trang%'
   OR name LIKE N'%nhiệt kế%'
   OR name LIKE N'%thuốc%'
   OR name LIKE N'%cân%'
   OR name LIKE N'%máy đo%';

PRINT N'✅ Đã cập nhật Sức Khỏe';

-- 17 = Túi Ví Nữ
UPDATE dbo.products SET category_id = 17
WHERE (name LIKE N'%túi%' OR name LIKE N'%Túi%' OR name LIKE N'%ví%' OR name LIKE N'%Ví%' OR name LIKE N'%clutch%')
  AND (name LIKE N'%nữ%' OR name LIKE N'%Nữ%');

PRINT N'✅ Đã cập nhật Túi Ví Nữ';

-- 18 = Phụ Kiện & Trang Sức Nữ
UPDATE dbo.products SET category_id = 18
WHERE name LIKE N'%vòng tay%'
   OR name LIKE N'%dây chuyền%'
   OR name LIKE N'%khuyên tai%'
   OR name LIKE N'%nhẫn%'
   OR name LIKE N'%trang sức%'
   OR name LIKE N'%kẹp tóc%'
   OR name LIKE N'%cài tóc%'
   OR name LIKE N'%bông tai%';

PRINT N'✅ Đã cập nhật Phụ Kiện & Trang Sức Nữ';

-- 19 = Bách Hóa Online (đồ ăn, snack, nước, gia vị)
UPDATE dbo.products SET category_id = 19
WHERE name LIKE N'%snack%'
   OR name LIKE N'%bánh%'
   OR name LIKE N'%kẹo%'
   OR name LIKE N'%nước ngọt%'
   OR name LIKE N'%trà%'
   OR name LIKE N'%cà phê%'
   OR name LIKE N'%gia vị%'
   OR name LIKE N'%mì%'
   OR name LIKE N'%gạo%';

PRINT N'✅ Đã cập nhật Bách Hóa Online';

-- 20 = Nhà Sách Online (sách, vở, bút, văn phòng phẩm)
UPDATE dbo.products SET category_id = 20
WHERE name LIKE N'%sách%'
   OR name LIKE N'%Sách%'
   OR name LIKE N'%vở%'
   OR name LIKE N'%bút%'
   OR name LIKE N'%Bút%'
   OR name LIKE N'%văn phòng phẩm%'
   OR name LIKE N'%sticker%';

PRINT N'✅ Đã cập nhật Nhà Sách Online';

-- Kiểm tra kết quả
SELECT c.name AS category_name, COUNT(p.id) AS product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id AND p.is_deleted = 0
GROUP BY c.id, c.name
ORDER BY c.id;

PRINT N'✅ HOÀN TẤT cập nhật category_id cho tất cả sản phẩm!';
GO
