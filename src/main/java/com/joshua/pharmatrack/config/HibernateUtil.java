package com.joshua.pharmatrack.config;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class HibernateUtil {

    private static final SessionFactory SESSION_FACTORY = buildSessionFactory();

    private HibernateUtil() { }

    private static SessionFactory buildSessionFactory() {
        try {
            Properties props = loadConfig();

            Configuration cfg = new Configuration();
            cfg.setProperty("hibernate.connection.url", props.getProperty("db.url"));
            cfg.setProperty("hibernate.connection.username", props.getProperty("db.username"));
            cfg.setProperty("hibernate.connection.password", props.getProperty("db.password"));
            cfg.setProperty("hibernate.connection.provider_class",
                    "org.hibernate.hikaricp.internal.HikariCPConnectionProvider");
            cfg.setProperty("hibernate.hikari.maximumPoolSize", "10");
            cfg.setProperty("hibernate.hbm2ddl.auto", "validate");
            cfg.setProperty("hibernate.show_sql", "true");
            cfg.setProperty("hibernate.format_sql", "true");

            // Entity classes will be registered here as we map them:
            // cfg.addAnnotatedClass(Category.class);

            return cfg.buildSessionFactory();
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private static Properties loadConfig() throws IOException {
        try (InputStream in = HibernateUtil.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (in == null) {
                throw new IllegalStateException(
                        "config.properties not found in src/main/resources");
            }
            Properties props = new Properties();
            props.load(in);
            return props;
        }
    }

    public static SessionFactory getSessionFactory() {
        return SESSION_FACTORY;
    }

    public static void shutdown() {
        SESSION_FACTORY.close();
    }
}
