package dal;

import model.Shop;
import model.ProductDTO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShopDAO extends DBContext {

    /**
     * Lấy thông tin shop theo ID
     */
    public Shop getShopById(int shopId) {
        String sql = "SELECT s.*, u.full_name, u.email FROM shops s "
                + "LEFT JOIN users u ON s.owner_id = u.id WHERE s.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Shop shop = new Shop();
                shop.setId(rs.getInt("id"));
                shop.setOwnerId(rs.getInt("owner_id"));
                shop.setShopName(rs.getString("shop_name"));
                shop.setRating(rs.getDouble("rating"));
                shop.setCreatedAt(rs.getTimestamp("created_at"));
                shop.setOwnerAvatar(rs.getString("avatar"));
                
                // Computed fields
                shop.setProductCount(getProductCount(shopId));
                shop.setFollowerCount(getFollowerCount(shopId));
                String rr = rs.getString("response_rate");
                shop.setResponseRate(rr != null ? rr : "0%");
                String rt = rs.getString("response_time");
                shop.setResponseTime(rt != null ? rt : "chưa có");
                return shop;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Đếm số sản phẩm của shop
     */
    public int getProductCount(int shopId) {
        String sql = "SELECT COUNT(*) FROM products WHERE shop_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Đếm số người theo dõi shop
     */
    public int getFollowerCount(int shopId) {
        String sql = "SELECT COUNT(*) FROM shop_followers WHERE shop_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            // Bảng chưa tồn tại thì trả 0
        }
        return 0;
    }

    /**
     * Kiểm tra user đã follow shop chưa
     */
    public boolean isFollowing(int userId, int shopId) {
        String sql = "SELECT COUNT(*) FROM shop_followers WHERE user_id = ? AND shop_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, shopId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {}
        return false;
    }

    /**
     * Toggle follow shop
     */
    public boolean toggleFollow(int userId, int shopId) {
        if (isFollowing(userId, shopId)) {
            String sql = "DELETE FROM shop_followers WHERE user_id = ? AND shop_id = ?";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, shopId);
                ps.executeUpdate();
            } catch (Exception e) { e.printStackTrace(); }
            return false;
        } else {
            String sql = "INSERT INTO shop_followers (user_id, shop_id) VALUES (?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, shopId);
                ps.executeUpdate();
            } catch (Exception e) { e.printStackTrace(); }
            return true;
        }
    }

    /**
     * Lấy sản phẩm của shop (có phân trang + sắp xếp)
     */
    public List<ProductDTO> getShopProducts(int shopId, String sort, int page, int pageSize) {
        List<ProductDTO> list = new ArrayList<>();
        String orderBy;
        switch (sort != null ? sort : "popular") {
            case "newest": orderBy = "p.created_at DESC"; break;
            case "bestselling": orderBy = "sold DESC"; break;
            case "price_asc": orderBy = "p.price ASC"; break;
            case "price_desc": orderBy = "p.price DESC"; break;
            default: orderBy = "p.id DESC"; break;
        }

        String sql = "SELECT p.*, "
                + "(SELECT ISNULL(SUM(oi.quantity),0) FROM order_items oi "
                + "JOIN product_variants pv ON oi.variant_id = pv.id "
                + "WHERE pv.product_id = p.id) AS sold "
                + "FROM products p WHERE p.shop_id = ? AND (p.is_deleted = 0 OR p.is_deleted IS NULL) "
                + "ORDER BY " + orderBy + " "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductDTO dto = new ProductDTO();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                dto.setPrice(rs.getBigDecimal("price"));
                dto.setImageUrl(rs.getString("image_url"));
                dto.setSoldCount(rs.getInt("sold"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy sản phẩm bán chạy nhất của shop
     */
    public List<ProductDTO> getTopSellingProducts(int shopId, int limit) {
        return getShopProducts(shopId, "bestselling", 1, limit);
    }
}
