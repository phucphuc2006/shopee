package listener;

import dal.SystemSettingDAO;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.Map;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        SystemSettingDAO settingDAO = new SystemSettingDAO();
        try {
            // Nạp toàn bộ cấu hình vào RAM (application scope) ngay khi khởi động Web Server
            Map<String, String> globalSettings = settingDAO.getSettingsMap();
            context.setAttribute("globalSettings", globalSettings);
        } catch (Exception e) {
            System.err.println("Failed to load settings on startup: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if necessary
    }
}
