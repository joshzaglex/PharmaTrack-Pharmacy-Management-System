package com.joshua.pharmatrack;

import com.joshua.pharmatrack.config.HibernateUtil;
import org.hibernate.Session;

public class App {
    public static void main(String[] args) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session
                    .createNativeQuery("SELECT COUNT(*) FROM products", Long.class)
                    .getSingleResult();
            System.out.println("Connected. Products in database: " + count);
        }
        HibernateUtil.shutdown();
    }
}