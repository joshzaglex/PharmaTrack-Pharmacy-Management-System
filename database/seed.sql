USE pharmatrack;

INSERT INTO categories (name, description) VALUES
('Analgesics', 'Pain relievers'),
('Antibiotics', 'Prescription antibacterials'),
('Antimalarials', 'Malaria treatment and prevention'),
('Vitamins & Supplements', 'Vitamins and minerals'),
('Antacids', 'Digestive relief'),
('First Aid', 'Dressings and antiseptics');

INSERT INTO suppliers (name, contact_person, phone) VALUES
('Alpha Pharma Distributors', 'Mr. Ade', '08000000001'),
('Greenlife Medical Supplies', 'Mrs. Bisi', '08000000002'),
('Unity Drug Wholesalers', 'Mr. Chidi', '08000000003');

INSERT INTO staff (full_name, job_title, date_employed, base_salary) VALUES
('Demo Admin', 'Superintendent Pharmacist', '2026-01-01', 250000.00),
('Demo Cashier', 'Sales Attendant', '2026-02-01', 80000.00);

-- Placeholder hash: replaced with a real BCrypt hash on Day 6
INSERT INTO users (username, password_hash, full_name, role, staff_id) VALUES
('admin', 'CHANGE_ME_ON_DAY_6', 'Demo Admin', 'ADMIN', 1),
('cashier1', 'CHANGE_ME_ON_DAY_6', 'Demo Cashier', 'CASHIER', 2);

INSERT INTO products
(sku_barcode, name, generic_name, category_id, dosage_form, strength, unit, selling_price, reorder_level, reorder_quantity, requires_prescription)
VALUES
('PARA500', 'Paracetamol 500mg', 'Paracetamol', (SELECT id FROM categories WHERE name='Analgesics'), 'Tablet', '500mg', 'strip', 300.00, 20, 100, FALSE),
('IBU400', 'Ibuprofen 400mg', 'Ibuprofen', (SELECT id FROM categories WHERE name='Analgesics'), 'Tablet', '400mg', 'strip', 500.00, 15, 60, FALSE),
('AMOX500', 'Amoxicillin 500mg', 'Amoxicillin', (SELECT id FROM categories WHERE name='Antibiotics'), 'Capsule', '500mg', 'strip', 1200.00, 15, 50, TRUE),
('CIPRO500', 'Ciprofloxacin 500mg', 'Ciprofloxacin', (SELECT id FROM categories WHERE name='Antibiotics'), 'Tablet', '500mg', 'strip', 1500.00, 10, 40, TRUE),
('ARTE80', 'Artemether/Lumefantrine 80/480mg', 'Artemether/Lumefantrine', (SELECT id FROM categories WHERE name='Antimalarials'), 'Tablet', '80/480mg', 'pack', 2500.00, 20, 60, FALSE),
('VITC1000', 'Vitamin C 1000mg', 'Ascorbic acid', (SELECT id FROM categories WHERE name='Vitamins & Supplements'), 'Tablet', '1000mg', 'bottle', 2000.00, 10, 30, FALSE),
('MULTIVIT', 'Multivitamin Tablets', 'Multivitamin', (SELECT id FROM categories WHERE name='Vitamins & Supplements'), 'Tablet', NULL, 'bottle', 3500.00, 8, 24, FALSE),
('GVISCON', 'Gaviscon Liquid 150ml', 'Alginate/Antacid', (SELECT id FROM categories WHERE name='Antacids'), 'Syrup', '150ml', 'bottle', 4500.00, 6, 12, FALSE),
('BANDAID', 'Adhesive Plasters', NULL, (SELECT id FROM categories WHERE name='First Aid'), 'Dressing', NULL, 'box', 800.00, 10, 30, FALSE),
('ANTISEP', 'Antiseptic Solution 100ml', 'Chloroxylenol', (SELECT id FROM categories WHERE name='First Aid'), 'Solution', '100ml', 'bottle', 1000.00, 10, 24, FALSE);