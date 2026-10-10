# PharmaTrack — Pharmacy Inventory & Sales Management System
### System Documentation / Developer Blueprint — v1.0

**Author:** Joshua | **Stack:** Java · Hibernate/JPA · MySQL · HTML/CSS/JS
**Purpose:** Hands-on portfolio project for Core Java, JDBC, Hibernate/JPA and MySQL training.

---

# 1. PROJECT OVERVIEW

## 1.1 Problem Statement

Small pharmacies in Nigeria and similar markets commonly run on paper ledgers, exercise books or scattered spreadsheets. This causes:

| Problem | Business impact |
|---|---|
| Stock is counted by hand and rarely reconciled | Theft and "shrinkage" go unnoticed |
| No alert when a drug runs low | Stock-outs → lost sales, lost customers |
| Expiry dates are not tracked | Expired drugs sold (health risk) or written off at a loss |
| Sales are recorded inconsistently | Owner cannot trust daily totals |
| Expenses, salaries and purchases are not tied to sales | Owner cannot tell if the pharmacy is actually profitable |
| No record of who did what | No accountability among staff |

**PharmaTrack** replaces this with a single system that records every purchase, sale, adjustment, expense and salary, and turns that data into reports the owner can act on.

## 1.2 Project Objectives

| ID | Objective | Measure of success |
|---|---|---|
| O-1 | Automate stock tracking | Every stock change (purchase, sale, adjustment, return) is logged automatically; quantity on hand is always derivable from the ledger |
| O-2 | Automate sales | A sale can be completed in under 30 seconds; stock reduces automatically; a receipt is produced |
| O-3 | Prevent stock-outs | System flags every product at or below its reorder level and suggests a reorder quantity |
| O-4 | Prevent theft / leakage | Variance, void, discount and adjustment reports expose suspicious activity; every action is tied to a user |
| O-5 | Prevent expiry losses | Expiry alerts at 90/60/30 days; expired batches are blocked from sale |
| O-6 | Calculate business expenditure | All expenses (rent, utilities, transport, etc.) and purchases are recorded and categorised |
| O-7 | Calculate profit and loss | Monthly P&L = Revenue − Cost of Goods Sold − Expenses − Salaries |
| O-8 | Manage staff salaries | Monthly payroll records with bonuses and deductions, fed into the P&L |

## 1.3 Scope of the System

**In scope (v1.0)**
- User login with role-based access (Admin/Owner, Pharmacist, Cashier/Sales Attendant, Store Keeper)
- Product (drug) catalogue, categories, suppliers
- Batch-level stock with expiry dates and purchase (restocking) records
- Point-of-sale (POS) screen, receipts, voids and returns
- Stock adjustments (damage, expiry write-off, theft, count correction) with approval
- Expense and payroll recording
- Reports: stock, sales, expiry, variance/theft, expenses, profit & loss
- Audit trail of sensitive actions
- Web frontend (HTML/CSS/JS) talking to a Java backend

**Out of scope (v1.0 — future enhancements)**
- Online ordering / e-commerce, delivery tracking
- Payment gateway integration (Paystack/Flutterwave) — *excellent v2 extension for fintech-targeted portfolios*
- Multi-branch / multi-pharmacy support
- Barcode hardware integration (v1 uses manual SKU/barcode entry; scanners that type like a keyboard will work automatically)
- Insurance/HMO claims processing
- Mobile app

**Assumptions:** one pharmacy branch, one currency (₦ Naira), 2–10 staff, 500–5,000 product lines, a single server (the owner's PC or a small cloud VM).

---

# 2. REQUIREMENTS ANALYSIS

## 2.1 Functional Requirements

### Authentication & User Management (FR-01 – FR-07)
| ID | Requirement |
|---|---|
| FR-01 | The system shall allow users to log in with username and password |
| FR-02 | The system shall store passwords hashed (BCrypt), never in plain text |
| FR-03 | The system shall restrict features by role (RBAC): Admin, Pharmacist, Cashier, Store Keeper |
| FR-04 | The Admin shall create, edit, deactivate and reset passwords for users |
| FR-05 | The system shall lock an account after 5 consecutive failed logins |
| FR-06 | The system shall log users out after a period of inactivity (e.g. 20 minutes) |
| FR-07 | Users shall be able to change their own password |

### Product & Catalogue Management (FR-08 – FR-14)
| ID | Requirement |
|---|---|
| FR-08 | Authorised users shall add, edit, and deactivate products (no hard delete if sales history exists) |
| FR-09 | Each product shall have: name, generic name, brand, category, dosage form, strength, unit of measure, barcode/SKU, NAFDAC reg. number, selling price, reorder level, prescription-required flag |
| FR-10 | The system shall manage product categories (e.g. Antibiotics, Analgesics, Antimalarials, Vitamins, Cosmetics) |
| FR-11 | The system shall support searching products by name, generic name, barcode or category |
| FR-12 | The system shall manage suppliers (name, contact, address, status) |
| FR-13 | The system shall reject duplicate barcodes/SKUs |
| FR-14 | Price changes shall be recorded with who changed it and when (price history) |

### Stock & Purchasing (FR-15 – FR-24)
| ID | Requirement |
|---|---|
| FR-15 | The system shall record stock received from suppliers (purchase/restock) as batches with batch number, expiry date, quantity, unit cost price |
| FR-16 | Stock on hand per product shall be the sum of its active batches |
| FR-17 | The system shall deduct stock using **FEFO** (First-Expiry-First-Out) automatically at sale |
| FR-18 | The system shall block sale of expired batches |
| FR-19 | The system shall record every stock change in a **stock movement ledger** (type, quantity, before/after, user, time, reference) |
| FR-20 | The system shall support stock adjustments with a mandatory reason (Damaged, Expired, Theft/Loss, Count Correction, Sample/Donation) |
| FR-21 | Adjustments above a configurable value/quantity shall require Admin approval |
| FR-22 | The system shall support periodic **physical stock counts** and compute variance (system qty vs counted qty) |
| FR-23 | The system shall support purchase orders to suppliers (create, send/print, receive, partial receive, cancel) |
| FR-24 | The system shall record supplier returns (returning damaged/near-expiry goods) |

### Sales / Point of Sale (FR-25 – FR-34)
| ID | Requirement |
|---|---|
| FR-25 | The cashier shall build a sale by searching/scanning products and entering quantities |
| FR-26 | The system shall show live line totals, discounts, and grand total |
| FR-27 | The system shall prevent selling more than the available stock |
| FR-28 | The system shall support payment methods: Cash, POS/Card, Bank Transfer, (Credit — optional) |
| FR-29 | The system shall support split payment (e.g. part cash, part transfer) *(optional)* |
| FR-30 | The system shall generate a unique receipt number and a printable receipt |
| FR-31 | Prescription-required items shall require the pharmacist's confirmation (and optional prescriber/patient note) |
| FR-32 | Discounts above a configurable percentage shall require Pharmacist/Admin authorisation |
| FR-33 | Completed sales shall not be edited; mistakes are handled by **void** (same day, authorised) or **return/refund** (with reason) |
| FR-34 | Voids, returns and discounts shall be recorded with user, reason and time |

### Customers (FR-35 – FR-36) — *optional*
| ID | Requirement |
|---|---|
| FR-35 | The system shall optionally record customer name/phone on a sale |
| FR-36 | The system shall show a customer's purchase history |

### Expenses & Payroll (FR-37 – FR-46)
| ID | Requirement |
|---|---|
| FR-37 | The system shall record business expenses: category, amount, date, description, payment method, recorded by |
| FR-38 | The system shall manage expense categories (Rent, Electricity, Generator Fuel, Transport, Licenses/Renewals, Marketing, Maintenance, Other) |
| FR-39 | The system shall manage staff records (name, role, phone, date employed, base salary, status) |
| FR-40 | The system shall record monthly salary payments: base, bonus, deductions, net pay, date paid |
| FR-41 | The system shall prevent paying the same staff member twice for the same month |
| FR-42 | The Admin shall be able to generate a payslip view/printout per staff |
| FR-43 | Only the Admin shall access expense and payroll data |
| FR-44 | Expenses and salaries shall feed automatically into the Profit & Loss report |
| FR-45 | Expenses shall support editing only by Admin, with audit logging |
| FR-46 | The system shall record owner withdrawals/drawings separately from expenses *(optional)* |

### Reports & Dashboard (FR-47 – FR-58)
| ID | Requirement |
|---|---|
| FR-47 | **Dashboard**: today's sales, number of transactions, low-stock count, near-expiry count, top sellers, month-to-date profit |
| FR-48 | **Daily/Weekly/Monthly Sales Report** (by date range, by cashier, by payment method, by product) |
| FR-49 | **Current Stock Report** (qty, cost value, retail value per product/category) |
| FR-50 | **Low Stock / Reorder Report** with suggested order quantity |
| FR-51 | **Out-of-Stock Report** and **Stock-out history** (days a product was unavailable) |
| FR-52 | **Expiry Report**: expiring in 30/60/90 days and already expired |
| FR-53 | **Stock Movement Report** per product (full ledger) |
| FR-54 | **Variance Report**: system vs physical count; shrinkage value |
| FR-55 | **Suspicious Activity Report**: voids, returns, discounts, adjustments and price changes grouped by user, with outlier highlighting |
| FR-56 | **Expense Report** by category and period |
| FR-57 | **Profit & Loss Statement** by month/range (see formula in §5.8) |
| FR-58 | All reports shall be exportable to **CSV** and printable (PDF is an optional extension) |

### Audit & Administration (FR-59 – FR-62)
| ID | Requirement |
|---|---|
| FR-59 | The system shall write an audit log for logins, price changes, adjustments, voids, returns, expense edits, payroll and user changes |
| FR-60 | Audit logs shall be read-only (no edit/delete from the UI) |
| FR-61 | The Admin shall configure settings: pharmacy name/address, receipt footer, low-stock default, discount limit, expiry alert windows |
| FR-62 | The system shall support database backup instructions/script (documented in README) |

## 2.2 Non-Functional Requirements

### Performance
| ID | Requirement |
|---|---|
| NFR-P1 | Product search shall return results in < 1 second for up to 5,000 products |
| NFR-P2 | Completing a sale (save + stock deduction) shall take < 2 seconds |
| NFR-P3 | Standard reports for one month of data shall load in < 5 seconds |
| NFR-P4 | Use database indexes on barcode, product name, sale date, batch expiry |

### Security
| ID | Requirement |
|---|---|
| NFR-S1 | Passwords hashed with BCrypt (cost ≥ 10) |
| NFR-S2 | Role-based authorisation enforced **on the backend** for every endpoint (never rely on hiding buttons in the UI) |
| NFR-S3 | Use JPA parameterised queries/JPQL only — no string-concatenated SQL (prevents SQL injection) |
| NFR-S4 | Validate all input server-side; escape output in the UI (prevents XSS) |
| NFR-S5 | Sessions use HttpOnly cookies; inactivity timeout |
| NFR-S6 | DB credentials kept in a config file outside source control (use `config.example.properties` in GitHub) |
| NFR-S7 | Sensitive actions require reason and are audit-logged |
| NFR-S8 | HTTPS recommended when deployed beyond localhost |

### Scalability & Maintainability
| ID | Requirement |
|---|---|
| NFR-M1 | Strict layering (Controller → Service → Repository → Entity) so layers can be swapped/tested independently |
| NFR-M2 | Design the schema so a `branch_id` can be added later for multi-branch support |
| NFR-M3 | Stateless services except for the session; backend can run behind a load balancer later |
| NFR-M4 | Pagination on all list endpoints |
| NFR-M5 | Unit tests (JUnit 5) for core business rules: FEFO deduction, P&L calc, reorder logic |

### Data Integrity & Reliability
| ID | Requirement |
|---|---|
| NFR-D1 | A sale and its stock deduction occur in **one database transaction** (all or nothing) |
| NFR-D2 | Use `BigDecimal` / `DECIMAL(12,2)` for money — never `double` |
| NFR-D3 | Optimistic locking (`@Version`) on stock batches to prevent two cashiers selling the last unit simultaneously |
| NFR-D4 | Soft-delete (status flags) for master data; financial records are never physically deleted |
| NFR-D5 | Timestamps stored in UTC or consistently in Africa/Lagos; document the choice |

### Usability
- Responsive layout usable on a desktop and tablet; POS screen optimised for speed (keyboard-friendly, focus on search box)
- Clear error messages; confirmation dialogs for destructive actions

## 2.3 Target Users / Actors

| Actor | Description | Key permissions |
|---|---|---|
| **Admin / Owner** | Pharmacy owner or superintendent | Everything: users, prices, expenses, payroll, P&L, approvals, audit log |
| **Pharmacist** | Licensed pharmacist | Products, stock receiving, prescription sales, discount approvals, adjustments (within limits), stock counts, stock/expiry reports |
| **Cashier / Sales Attendant** | Front-desk seller | Create sales, print receipts, view product price & availability, request voids/returns. **Cannot** see cost price, profit, expenses or payroll |
| **Store Keeper** | Handles receiving/shelving | Receive stock, record adjustments for approval, run stock counts. **Cannot** make sales or see financials |
| **System (Scheduler)** | Background jobs | Compute daily alerts (low stock, expiry), optional nightly backup |

### Permission Matrix (summary)

| Feature | Admin | Pharmacist | Cashier | Store Keeper |
|---|:-:|:-:|:-:|:-:|
| Manage users | ✔ | | | |
| Manage products / prices | ✔ | ✔ (no price) | | |
| Change selling price | ✔ | | | |
| View cost price | ✔ | ✔ | | ✔ |
| Receive stock / PO | ✔ | ✔ | | ✔ |
| Make sale | ✔ | ✔ | ✔ | |
| Void / return | ✔ approve | ✔ approve | request | |
| Stock adjustment | ✔ approve | ✔ | | request |
| Stock count | ✔ | ✔ | | ✔ |
| Expenses / Payroll | ✔ | | | |
| Profit & Loss | ✔ | | | |
| Sales reports | ✔ | ✔ | own only | |
| Audit log | ✔ | | | |

---

# 3. SYSTEM ARCHITECTURE

## 3.1 Proposed Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Language | **Java 17 or 21 (LTS)** | Matches your training |
| ORM | **Hibernate 6 via JPA (jakarta.persistence)** | Entity mapping, JPQL, transactions |
| Database | **MySQL 8** | Relational, ACID, widely used in industry |
| Connection pool | **HikariCP** | Fast pooled DB connections |
| Build tool | **Maven** | Standard dependency & build management |
| Web layer (backend) | **Jakarta Servlets on Apache Tomcat 10** *(recommended for you)* — alternative: **Javalin** (lighter, easier to start) | Teaches you the HTTP fundamentals that frameworks hide. Spring Boot is *not* required for this project |
| JSON | **Gson** or **Jackson** | Convert Java objects ⇄ JSON for the frontend |
| Frontend | **HTML5, CSS3, vanilla JavaScript** (Fetch API); optional Chart.js for charts | As requested |
| Password hashing | **BCrypt** (jBCrypt or `at.favre.lib:bcrypt`) | Industry-standard hashing |
| Validation | **Jakarta Bean Validation (Hibernate Validator)** | Annotation-based validation on DTOs/entities |
| Logging | **SLF4J + Logback** | Proper logs instead of `System.out` |
| Testing | **JUnit 5 + Mockito** (+ H2 or Testcontainers for repository tests) | Proves quality to employers |
| Version control | **Git + GitHub** | Portfolio |
| DB tools | **MySQL Workbench / DBeaver** | ER diagrams, SQL inspection |
| API testing | **Postman / Thunder Client** | Test endpoints before the UI exists |

> **Learning tip:** Since your course covers JDBC *before* heavy ORM work, consider writing the Product DAO once with plain JDBC (Phase 1), then replace it with a Hibernate repository. It demonstrates you understand what the ORM is doing for you — a strong interview talking point.

## 3.2 Architecture Pattern: Layered MVC

```
┌──────────────────────────────────────────────────────────────────┐
│                       PRESENTATION (Browser)                      │
│   HTML pages  +  CSS  +  JavaScript (Fetch API calls, DOM render) │
│   Login | Dashboard | POS | Products | Stock | Reports | Admin    │
└───────────────▲──────────────────────────────────┬───────────────┘
                │  JSON response                   │  HTTP request (JSON)
                │                                  ▼
┌───────────────┴──────────────────────────────────────────────────┐
│                  CONTROLLER LAYER  (Servlets / Routes)            │
│  AuthController, ProductController, SaleController, StockController│
│  ExpenseController, PayrollController, ReportController            │
│  • parse request  • validate input  • call service  • return JSON  │
│  • Filters: AuthenticationFilter, RoleAuthorizationFilter          │
└───────────────▲──────────────────────────────────┬───────────────┘
                │ DTOs                             │ DTOs
                │                                  ▼
┌───────────────┴──────────────────────────────────────────────────┐
│                      SERVICE LAYER  (Business logic)              │
│  AuthService, ProductService, StockService, SaleService,           │
│  PurchaseService, ExpenseService, PayrollService, ReportService,   │
│  AuditService                                                      │
│  • business rules (FEFO, discount limits, reorder logic, P&L)      │
│  • transaction boundaries (@begin / commit / rollback)             │
└───────────────▲──────────────────────────────────┬───────────────┘
                │ Entities                         │ Entities
                │                                  ▼
┌───────────────┴──────────────────────────────────────────────────┐
│               REPOSITORY / DAO LAYER  (Data access)               │
│  ProductRepository, BatchRepository, SaleRepository, ...           │
│  • JPQL / Criteria queries via EntityManager                       │
└───────────────▲──────────────────────────────────┬───────────────┘
                │                                  ▼
┌───────────────┴──────────────────────────────────────────────────┐
│          ENTITY / DOMAIN LAYER  (JPA-annotated classes)           │
│  Product, StockBatch, Sale, SaleItem, Expense, Staff, User ...     │
└───────────────────────────────┬──────────────────────────────────┘
                                │ Hibernate (ORM) + HikariCP pool
                                ▼
                  ┌───────────────────────────┐
                  │        MySQL 8 DB          │
                  └───────────────────────────┘
```

**Rules of the layers (memorise these — they're interview gold):**
1. Controllers never talk to repositories directly.
2. Services never touch HTTP objects (`HttpServletRequest`).
3. Repositories contain **no** business rules, only data access.
4. Entities are never exposed directly in JSON; use **DTOs** so you control what leaves the server (e.g. never leak `costPrice` to a cashier).
5. Transactions are managed in the **service** layer.

## 3.3 Proposed Package Structure

```
com.joshua.pharmatrack
├── config         (HibernateUtil / JPA setup, AppConfig, constants)
├── controller     (servlets or route handlers)
├── filter         (AuthenticationFilter, RoleFilter, CorsFilter)
├── dto            (request/response objects)
├── entity         (JPA entities)
│   └── enums      (Role, PaymentMethod, MovementType, ...)
├── repository     (interfaces + implementations)
├── service        (business logic)
├── exception      (custom exceptions, global error mapper)
├── util           (PasswordUtil, DateUtil, MoneyUtil, ReceiptNumberGenerator)
└── scheduler      (nightly alert/backup jobs)

src/main/webapp (frontend)
├── index.html / login.html
├── pages/         (dashboard.html, pos.html, products.html, stock.html, reports.html, ...)
├── css/           (main.css, pos.css)
└── js/            (api.js, auth.js, pos.js, products.js, reports.js, ...)
```

## 3.4 Typical Request Flow (Make a Sale)

```
Cashier clicks "Complete Sale" in pos.html
 → pos.js: fetch('POST /api/sales', {items, payments, discount})
 → AuthenticationFilter: valid session? → RoleFilter: CASHIER allowed?
 → SaleController: validate JSON → build SaleRequestDTO
 → SaleService.createSale()  [BEGIN TRANSACTION]
      for each item: StockService.deductFEFO(product, qty)  → updates batches + writes StockMovement
      compute totals, create Sale + SaleItems + Payments
      AuditService.log(...)
   [COMMIT]  (any exception → ROLLBACK, nothing saved)
 → SaleController: return receipt JSON
 → pos.js: show/print receipt, reset screen
```

## 3.5 Suggested REST Endpoints (examples)

| Method | Endpoint | Purpose | Roles |
|---|---|---|---|
| POST | `/api/auth/login` | Login | Public |
| POST | `/api/auth/logout` | Logout | Any |
| GET | `/api/products?search=&page=` | Search products | Any authenticated |
| POST | `/api/products` | Create product | Admin, Pharmacist |
| PUT | `/api/products/{id}` | Update product | Admin, Pharmacist |
| POST | `/api/stock/receive` | Receive stock (batches) | Admin, Pharmacist, StoreKeeper |
| POST | `/api/stock/adjustments` | Request adjustment | Admin, Pharmacist, StoreKeeper |
| PUT | `/api/stock/adjustments/{id}/approve` | Approve adjustment | Admin, Pharmacist |
| POST | `/api/sales` | Create sale | Admin, Pharmacist, Cashier |
| POST | `/api/sales/{id}/void` | Void sale | Admin, Pharmacist |
| POST | `/api/sales/{id}/return` | Return items | Admin, Pharmacist |
| GET | `/api/reports/sales?from=&to=` | Sales report | Admin, Pharmacist |
| GET | `/api/reports/profit-loss?month=2026-09` | P&L | Admin |
| POST | `/api/expenses` | Record expense | Admin |
| POST | `/api/payroll` | Record salary payment | Admin |
| GET | `/api/dashboard` | Dashboard summary | Admin, Pharmacist |

---

# 4. DATABASE DESIGN

## 4.1 Entity / Table List

| # | Table | Purpose |
|---|---|---|
| 1 | `users` | System login accounts |
| 2 | `staff` | HR record of employees (a staff member *may* have a user account) |
| 3 | `categories` | Product categories |
| 4 | `suppliers` | Suppliers/distributors |
| 5 | `products` | Drug/product master data |
| 6 | `price_history` | Selling-price changes over time |
| 7 | `purchase_orders` | Orders placed with suppliers |
| 8 | `purchase_order_items` | Lines on a purchase order |
| 9 | `stock_batches` | Received stock with batch no., expiry, cost, remaining qty |
| 10 | `stock_movements` | **Ledger** of every stock change |
| 11 | `stock_adjustments` | Damage/theft/expiry/count-correction requests and approvals |
| 12 | `stock_counts` | Physical count sessions (header) |
| 13 | `stock_count_items` | Counted vs system qty per product |
| 14 | `sales` | Sale header |
| 15 | `sale_items` | Sale lines (linked to the batch(es) used) |
| 16 | `payments` | Payments on a sale (supports split payment) |
| 17 | `sale_returns` | Returns/refunds (header + lines, may be two tables) |
| 18 | `customers` | Optional customer records |
| 19 | `expense_categories` | Expense types |
| 20 | `expenses` | Business expense records |
| 21 | `salary_payments` | Monthly salary payments |
| 22 | `audit_logs` | Security/accountability trail |
| 23 | `app_settings` | Key-value configuration |

## 4.2 Attributes per Table

> Conventions: `PK` primary key, `FK` foreign key, `UQ` unique, `NN` not null. All tables also have `created_at` and (where useful) `updated_at`. Money = `DECIMAL(12,2)`. IDs = `BIGINT AUTO_INCREMENT`.

**users**
`id PK`, `username UQ NN`, `password_hash NN`, `full_name NN`, `email UQ`, `phone`, `role NN` (ENUM: ADMIN, PHARMACIST, CASHIER, STORE_KEEPER), `active NN`, `failed_login_count`, `locked_until`, `last_login_at`, `staff_id FK→staff (nullable, UQ)`

**staff**
`id PK`, `full_name NN`, `phone`, `address`, `job_title`, `date_employed`, `base_salary DECIMAL NN`, `status` (ACTIVE/LEFT)

**categories**
`id PK`, `name UQ NN`, `description`, `active`

**suppliers**
`id PK`, `name NN`, `contact_person`, `phone`, `email`, `address`, `active`

**products**
`id PK`, `sku_barcode UQ NN`, `name NN`, `generic_name`, `brand`, `category_id FK NN`, `dosage_form` (Tablet, Syrup, Injection, Cream…), `strength` (e.g. 500mg), `unit` (strip, bottle, sachet…), `nafdac_number`, `selling_price NN`, `reorder_level NN`, `reorder_quantity`, `requires_prescription NN`, `active NN`
*(Note: `cost_price` lives on the batch, because cost differs per purchase.)*

**price_history**
`id PK`, `product_id FK`, `old_price`, `new_price`, `changed_by FK→users`, `changed_at`

**purchase_orders**
`id PK`, `po_number UQ`, `supplier_id FK`, `status` (DRAFT, ORDERED, PARTIAL, RECEIVED, CANCELLED), `order_date`, `expected_date`, `total_cost`, `created_by FK→users`, `notes`

**purchase_order_items**
`id PK`, `purchase_order_id FK`, `product_id FK`, `quantity_ordered`, `quantity_received`, `unit_cost`

**stock_batches**
`id PK`, `product_id FK NN`, `supplier_id FK`, `purchase_order_id FK (nullable)`, `batch_number NN`, `expiry_date NN`, `quantity_received NN`, `quantity_remaining NN`, `unit_cost NN`, `received_date NN`, `received_by FK→users`, `status` (ACTIVE, DEPLETED, EXPIRED, QUARANTINED), `version` *(for optimistic locking)*
UQ: (`product_id`, `batch_number`, `supplier_id`)

**stock_movements** *(append-only ledger)*
`id PK`, `product_id FK`, `batch_id FK`, `movement_type` (PURCHASE, SALE, SALE_VOID, RETURN_IN, ADJUSTMENT_IN, ADJUSTMENT_OUT, SUPPLIER_RETURN, EXPIRY_WRITEOFF, COUNT_CORRECTION), `quantity_change` (+/−), `quantity_before`, `quantity_after`, `reference_type`, `reference_id`, `user_id FK`, `created_at`, `note`

**stock_adjustments**
`id PK`, `product_id FK`, `batch_id FK`, `adjustment_type` (DAMAGED, EXPIRED, THEFT_LOSS, COUNT_CORRECTION, SAMPLE), `quantity NN`, `reason NN`, `value_at_cost`, `status` (PENDING, APPROVED, REJECTED), `requested_by FK`, `approved_by FK`, `requested_at`, `decided_at`

**stock_counts**
`id PK`, `count_date`, `status` (OPEN, SUBMITTED, APPROVED), `started_by FK`, `approved_by FK`, `notes`

**stock_count_items**
`id PK`, `stock_count_id FK`, `product_id FK`, `system_quantity`, `counted_quantity`, `variance` (counted − system), `variance_value_at_cost`

**customers**
`id PK`, `name`, `phone UQ`, `address`, `notes`

**sales**
`id PK`, `receipt_number UQ NN`, `sale_datetime NN`, `cashier_id FK→users NN`, `customer_id FK (nullable)`, `subtotal`, `discount_amount`, `discount_reason`, `discount_approved_by FK`, `total_amount NN`, `status` (COMPLETED, VOIDED, PARTIALLY_RETURNED, RETURNED), `voided_by FK`, `void_reason`, `voided_at`, `prescription_note`

**sale_items**
`id PK`, `sale_id FK NN`, `product_id FK NN`, `batch_id FK NN`, `quantity NN`, `unit_price NN` *(snapshot at time of sale)*, `unit_cost NN` *(snapshot — needed for accurate COGS)*, `line_discount`, `line_total`
*(If one item draws from two batches under FEFO, create two `sale_items` rows.)*

**payments**
`id PK`, `sale_id FK`, `method` (CASH, POS, TRANSFER, CREDIT), `amount`, `reference`

**sale_returns** / **sale_return_items**
`id PK`, `sale_id FK`, `return_datetime`, `reason NN`, `refund_amount`, `processed_by FK`, `approved_by FK` — and lines: `sale_item_id FK`, `quantity`, `restock` (boolean: back to shelf or write off)

**expense_categories**
`id PK`, `name UQ`, `active`

**expenses**
`id PK`, `expense_category_id FK NN`, `amount NN`, `expense_date NN`, `description`, `payment_method`, `receipt_reference`, `recorded_by FK NN`, `created_at`

**salary_payments**
`id PK`, `staff_id FK NN`, `pay_month NN` (store as first day of month, e.g. 2026-09-01), `base_salary`, `bonus`, `deductions`, `net_pay NN`, `paid_date`, `payment_method`, `paid_by FK→users`, `notes`
UQ: (`staff_id`, `pay_month`)

**audit_logs**
`id PK`, `user_id FK`, `action` (LOGIN, LOGIN_FAILED, PRICE_CHANGE, VOID_SALE, ADJUSTMENT_APPROVED, EXPENSE_EDITED, …), `entity_type`, `entity_id`, `old_value (TEXT/JSON)`, `new_value (TEXT/JSON)`, `ip_address`, `created_at`

**app_settings**
`setting_key PK`, `setting_value`, `description`

## 4.3 Relationships & JPA Mapping

### Relationship Summary

| Relationship | Type | Owning side (has FK) |
|---|---|---|
| Category → Product | One-to-Many | `Product.category` |
| Supplier → StockBatch | One-to-Many | `StockBatch.supplier` |
| Product → StockBatch | One-to-Many | `StockBatch.product` |
| Product → StockMovement | One-to-Many | `StockMovement.product` |
| Supplier → PurchaseOrder | One-to-Many | `PurchaseOrder.supplier` |
| PurchaseOrder → PurchaseOrderItem | One-to-Many | `PurchaseOrderItem.purchaseOrder` |
| Sale → SaleItem | One-to-Many | `SaleItem.sale` |
| Sale → Payment | One-to-Many | `Payment.sale` |
| User (cashier) → Sale | One-to-Many | `Sale.cashier` |
| Customer → Sale | One-to-Many | `Sale.customer` |
| StockBatch → SaleItem | One-to-Many | `SaleItem.batch` |
| Product → SaleItem | One-to-Many | `SaleItem.product` |
| Staff → SalaryPayment | One-to-Many | `SalaryPayment.staff` |
| Staff ↔ User | **One-to-One** | `User.staff` |
| ExpenseCategory → Expense | One-to-Many | `Expense.category` |
| StockCount → StockCountItem | One-to-Many | `StockCountItem.stockCount` |
| **Product ↔ Supplier** | **Many-to-Many** (a supplier supplies many products; a product can come from many suppliers) | join table `product_suppliers` *(optional; or derive from batches)* |

### How each maps in JPA/Hibernate (concepts, no code)

**One-to-Many / Many-to-One** (the workhorse)
- The **"many" side** (e.g. `Product`) holds the foreign key and declares `@ManyToOne` with `@JoinColumn(name="category_id")`.
- The **"one" side** (e.g. `Category`) *optionally* declares `@OneToMany(mappedBy="category")`. `mappedBy` says "the other class owns the FK."
- **Always use `fetch = FetchType.LAZY`** on `@ManyToOne` (default is EAGER, which causes performance problems).
- Only add the `@OneToMany` side when you genuinely need to navigate from parent to children.

**Parent–child "owned" collections (Sale → SaleItem, PurchaseOrder → PurchaseOrderItem, StockCount → StockCountItem)**
- Use `@OneToMany(mappedBy="sale", cascade = CascadeType.ALL, orphanRemoval = true)`.
- Cascade means saving a `Sale` saves its `SaleItem`s automatically — the items cannot exist without the sale.
- Do **not** cascade from `SaleItem → Product` (a product outlives a sale).

**One-to-One (User ↔ Staff)**
- `User` owns the FK: `@OneToOne` + `@JoinColumn(name="staff_id")`, unique constraint on that column.

**Many-to-Many (Product ↔ Supplier)**
- Mapped with `@ManyToMany` and `@JoinTable(name="product_suppliers", joinColumns=..., inverseJoinColumns=...)`.
- **Design advice:** if the join needs extra data (last supply price, lead time), replace with an **association entity** (`ProductSupplier`) using two `@ManyToOne`s. It's a classic interview question — try it.

**Enums** — use `@Enumerated(EnumType.STRING)`, never `ORDINAL` (reordering the enum would corrupt data).

**Money & dates** — `BigDecimal` for money; `LocalDate` / `LocalDateTime` (Java Time API) for dates.

**Optimistic locking** — `@Version` on `StockBatch`; if two transactions update the same batch, the second gets `OptimisticLockException` and the sale is retried/rejected with a friendly message.

**Inheritance** — Not required. Keep it simple; resist the urge to use `@Inheritance` where it isn't needed.

**Auditing** — Use `@PrePersist` / `@PreUpdate` lifecycle callbacks (or a `@MappedSuperclass BaseEntity`) to fill `created_at` / `updated_at` once, rather than repeating per entity.

**N+1 problem warning** — When listing sales with their items, use `JOIN FETCH` in JPQL or DTO projections; check Hibernate's SQL log (`show_sql`) so you can *prove* you avoided N+1. Great LinkedIn/interview material.

### Key Indexes
- `products(sku_barcode)` unique, `products(name)`, `products(generic_name)`
- `stock_batches(product_id, expiry_date)` — supports FEFO and expiry reports
- `sales(sale_datetime)`, `sales(cashier_id, sale_datetime)`
- `stock_movements(product_id, created_at)`
- `audit_logs(user_id, created_at)`, `audit_logs(action, created_at)`

## 4.4 ER Diagram (Text Format)

```
┌────────────┐ 1       N ┌────────────┐ 1        N ┌──────────────┐
│ CATEGORIES │───────────│  PRODUCTS  │────────────│ PRICE_HISTORY│
└────────────┘           └─────┬──────┘            └──────────────┘
                               │ 1
        ┌──────────────────────┼───────────────────────┐
        │ N                    │ N                     │ N
 ┌──────┴───────┐       ┌──────┴───────┐        ┌──────┴────────┐
 │ STOCK_BATCHES│       │ SALE_ITEMS   │        │STOCK_MOVEMENTS│
 └──┬────────┬──┘       └──┬────────┬──┘        └───────────────┘
    │ N      │ N           │ N      │ N                 ▲ N
    │1       │ 1           │        │ 1                 │ written by
┌───┴────┐ ┌─┴─────────────┘     ┌──┴───┐        ┌──────┴────┐
│SUPPLIER│ │ (batch used)        │ SALES│───────>│   USERS   │
└───┬────┘ │                     └──┬───┘ N    1 └─────┬─────┘
    │ 1    │                        │ 1                │ 1
    │ N    │                        │ N                │ 0..1
┌───┴──────────┐              ┌─────┴────┐        ┌────┴────┐
│PURCHASE_ORDERS│             │ PAYMENTS │        │  STAFF  │
└───┬──────────┘              └──────────┘        └────┬────┘
    │ 1                                                │ 1
    │ N                                                │ N
┌───┴───────────────┐                         ┌────────┴───────┐
│PURCHASE_ORDER_ITEMS│                        │SALARY_PAYMENTS │
└───────────────────┘                         └────────────────┘

┌────────────────────┐ 1   N ┌──────────┐      ┌───────────┐ 1  N ┌───────────────┐
│ EXPENSE_CATEGORIES │───────│ EXPENSES │      │ CUSTOMERS │──────│ SALES (opt.)  │
└────────────────────┘       └──────────┘      └───────────┘      └───────────────┘

┌────────────────┐ 1   N ┌────────────────────┐     ┌───────────────────┐
│  STOCK_COUNTS  │───────│ STOCK_COUNT_ITEMS  │     │ STOCK_ADJUSTMENTS │ (product, batch, users)
└────────────────┘       └────────────────────┘     └───────────────────┘

┌─────────────┐ (user_id → USERS)      ┌──────────────┐
│ AUDIT_LOGS  │                        │ APP_SETTINGS │ (standalone)
└─────────────┘                        └──────────────┘
```

**Why a ledger (`stock_movements`) matters:** `quantity_remaining` on a batch is a *cached* number; the ledger is the *proof*. If someone edits a number to hide theft, the ledger won't add up — and the variance report catches it. This is the heart of your anti-theft feature.

---

# 5. DETAILED MODULE BREAKDOWN

## 5.1 Authentication & User Module
**Does:** login/logout, password hashing, session management, account lockout, role checks, user CRUD, change password.
**Key classes:** `AuthController`, `AuthService`, `UserRepository`, `AuthenticationFilter`, `RoleAuthorizationFilter`, `PasswordUtil`.
**Rules:** 5 failed logins → 15-minute lock; every login/failure audit-logged; inactive users cannot log in.

## 5.2 Product & Catalogue Module
**Does:** CRUD for products, categories, suppliers; search/filter/pagination; price change with history; activate/deactivate.
**Key classes:** `ProductService`, `CategoryService`, `SupplierService`, repositories.
**Rules:** unique barcode; selling price must be > 0; price below latest batch cost triggers a warning (selling at a loss); products with history are deactivated, never deleted.

## 5.3 Inventory / Stock Module *(the core module)*
**Does:**
- Receive stock into batches (with batch no., expiry, cost)
- Maintain quantity on hand = Σ active batch `quantity_remaining`
- FEFO deduction; write ledger entries
- Stock adjustments (request → approve)
- Physical stock count and variance calculation
- Expiry detection (mark batches EXPIRED, block from sale)
- Low-stock detection against `reorder_level`
**Key classes:** `StockService`, `BatchRepository`, `StockMovementRepository`, `StockCountService`.
**Rules:**
- Quantity can never go negative.
- Every change → one ledger row.
- Receiving requires expiry date > today (+ configurable minimum shelf life warning, e.g. < 3 months).
- Adjustment value above threshold → Admin approval.

## 5.4 Purchasing / Supplier Module
**Does:** create purchase orders, receive goods (full/partial), convert received PO lines into stock batches, record supplier returns, supplier purchase history, total spend per supplier.
**Key classes:** `PurchaseService`, `PurchaseOrderRepository`.
**Rules:** received quantity ≤ ordered (or require override); PO status auto-updates (ORDERED → PARTIAL → RECEIVED).

## 5.5 Sales (POS) Module
**Does:** product lookup, cart building, FEFO batch allocation, discounts, payments, receipt generation, voids, returns/refunds, prescription flag handling, daily cashier summary (till close-out).
**Key classes:** `SaleController`, `SaleService`, `ReceiptService`, `SaleRepository`.
**Rules:**
- All-or-nothing transaction.
- `unit_price` and `unit_cost` copied into `sale_items` (so later price changes don't rewrite history).
- Sum of payments = total (or equals total + change for cash).
- Void allowed only same day and with authoriser + reason; returns require reason and optionally restock decision.
- Receipt numbers are sequential and unique (e.g. `RCP-20260915-0042`).

## 5.6 Expense Module
**Does:** record/edit/list expenses, manage categories, filter by period/category, monthly expense summary.
**Rules:** Admin only; edits are audit-logged with old/new values; future-dated expenses rejected.

## 5.7 Staff & Payroll Module
**Does:** staff records; monthly salary payment (base + bonus − deductions = net); payslip view; prevent duplicate monthly payment; payroll history; total payroll cost per month.
**Rules:** Admin only; one payment per staff per month; salary changes keep history (record the base salary used on each payment row).

## 5.8 Reporting & Analytics Module
**Does:** all reports from FR-47 to FR-58; CSV export; dashboard.
**Key classes:** `ReportService`, `DashboardService`, report DTOs; JPQL aggregate queries (`SUM`, `GROUP BY`).

**Core formulas**

```
Revenue (Net Sales)   = Σ completed sale totals − returns/refunds − voided sales
COGS                  = Σ (sale_item.quantity × sale_item.unit_cost)      ← uses cost snapshot
Gross Profit          = Revenue − COGS
Operating Expenses    = Σ expenses in period
Salaries              = Σ salary_payments.net_pay in period
Other write-offs      = Σ value at cost of EXPIRED + DAMAGED + THEFT adjustments (shown as "Inventory Loss")
NET PROFIT / (LOSS)   = Gross Profit − Operating Expenses − Salaries − Inventory Loss

Stock Value (cost)    = Σ batch.quantity_remaining × batch.unit_cost
Reorder suggestion    = max(reorder_quantity, (reorder_level × 2) − current_qty)   [define & document your rule]
Shrinkage             = counted_quantity − system_quantity (negative = missing stock)
```

**Theft/leakage indicators on the Suspicious Activity Report**
- Voids/returns per cashier vs. their share of sales (e.g. flag if > 2× the average)
- Discount percentage given per cashier
- Adjustments marked THEFT/DAMAGED per user and per product
- Products with repeated negative count variance
- Sales/voids outside opening hours
- Price changes followed by sales shortly after (and reversed)

## 5.9 Audit & Settings Module
**Does:** write and display the audit trail; manage settings (pharmacy details, thresholds, alert windows).
**Rules:** audit entries immutable; admin-only viewing.

## 5.10 Dashboard & Alerts (supporting module)
**Does:** summary tiles, charts (sales trend, top 10 products, category share), alert list (low stock, expiring, pending approvals). Optional scheduled job computes alerts nightly.

## 5.11 Module Dependency Overview
```
Auth ──► (all modules)
Product ◄── Stock ◄── Purchasing
              ▲
Sales ────────┘ (deducts stock)
Sales + Stock + Expense + Payroll ──► Reports (P&L)
Everything sensitive ──► Audit
```

---

# 6. USE CASES & USER STORIES

## 6.1 Use Case List

| ID | Use Case | Primary Actor |
|---|---|---|
| UC-01 | Log in | All users |
| UC-02 | Add / update product | Pharmacist, Admin |
| UC-03 | Receive stock | Store Keeper, Pharmacist |
| UC-04 | Make a sale | Cashier |
| UC-05 | Void a sale / process return | Cashier (request), Pharmacist/Admin (approve) |
| UC-06 | Adjust stock | Store Keeper, Pharmacist |
| UC-07 | Perform physical stock count | Store Keeper, Pharmacist |
| UC-08 | Handle low-stock alert / create purchase order | Pharmacist |
| UC-09 | Record expense | Admin |
| UC-10 | Pay staff salary | Admin |
| UC-11 | View Profit & Loss | Admin |
| UC-12 | Investigate suspicious activity | Admin |

## 6.2 Detailed Flows

### UC-04: Make a Sale
**Actor:** Cashier | **Precondition:** logged in; products in stock
**Main flow:**
1. Cashier opens the POS screen; cursor is in the search box.
2. Cashier types a name or scans a barcode; matching products appear with price and available quantity.
3. Cashier selects a product and enters quantity; item is added to the cart.
4. System displays live total. Cashier repeats steps 2–3.
5. (Optional) Cashier applies a discount; if above limit, system requests Pharmacist authorisation.
6. If any item requires prescription, system prompts Pharmacist confirmation.
7. Cashier selects payment method(s) and enters amount tendered; system shows change.
8. Cashier clicks **Complete Sale**.
9. System, in one transaction: validates stock → allocates batches (FEFO) → saves sale, items, payments → reduces stock → writes ledger.
10. System generates receipt; cashier prints/shows it. Cart resets.

**Alternate flows**
- *3a.* Requested quantity > available → error with available quantity; cashier adjusts.
- *3b.* Only batch available is expired → system blocks and flags to Pharmacist.
- *7a.* Payment total ≠ sale total → system blocks completion.
- *9a.* Concurrent update (optimistic lock) → system retries once, else asks the cashier to re-confirm.
- *9b.* Any failure → rollback; nothing is saved; error shown.

**Postcondition:** sale saved, stock reduced, ledger updated, receipt available.

### UC-03: Receive Stock
1. Store Keeper opens **Receive Stock**, selects supplier (and optionally a purchase order).
2. For each product: enters batch number, expiry date, quantity, unit cost.
3. System validates (expiry in future, quantity > 0, cost > 0); warns if near-expiry (< 3 months) or if the cost is much higher than last purchase.
4. Store Keeper submits; system creates batches, writes `PURCHASE` ledger entries, updates PO status.
5. System shows a goods-received note for printing.

### UC-05: Void a Sale (anti-theft control)
1. Cashier requests void on a completed same-day sale and enters a reason.
2. Pharmacist/Admin reviews and approves with their own credentials.
3. System marks sale VOIDED, restores stock to the original batches (`SALE_VOID` ledger rows), reverses revenue in reports.
4. Audit log records cashier, approver, reason, time.

### UC-07: Physical Stock Count
1. Pharmacist starts a count (all products or one category).
2. Store Keeper enters counted quantities (system quantity hidden for "blind count" — recommended anti-theft practice).
3. System computes variance per product and its cost value.
4. Pharmacist reviews and submits; Admin approves.
5. On approval, system posts `COUNT_CORRECTION` ledger entries and updates batches; variance report generated.

### UC-11: View Profit & Loss
1. Admin selects a month or date range.
2. System aggregates revenue, COGS, expenses, salaries, inventory losses.
3. System displays statement with Gross Profit and Net Profit/Loss, plus comparison with the previous period; export to CSV/print.

## 6.3 User Stories

| ID | As a… | I want to… | So that… | Acceptance criteria |
|---|---|---|---|---|
| US-01 | Cashier | search a drug by name or barcode quickly | I can serve customers fast | Results < 1s; shows price and qty |
| US-02 | Cashier | have the system deduct stock automatically | I don't maintain a manual book | Stock reduces on completion; ledger entry exists |
| US-03 | Cashier | print a receipt | the customer has proof | Unique receipt no., items, total, cashier, date |
| US-04 | Pharmacist | see products expiring in 90 days | I can sell or return them early | Report lists batch, qty, days left, cost value |
| US-05 | Pharmacist | get low-stock alerts | I reorder before running out | Dashboard badge + report with suggested qty |
| US-06 | Store Keeper | record received stock with batch & expiry | stock is traceable | Batch saved; ledger shows PURCHASE |
| US-07 | Admin | approve or reject stock adjustments | losses are controlled | Pending list; approver and reason logged |
| US-08 | Admin | see which cashier has unusual voids or discounts | I can detect theft | Suspicious Activity Report ranks users with flags |
| US-09 | Admin | record expenses by category | I know where money goes | Expense saved; appears in expense report & P&L |
| US-10 | Admin | pay salaries monthly and avoid duplicates | payroll is accurate | Second payment for same month is rejected |
| US-11 | Admin | see monthly profit or loss | I know if the business is profitable | P&L matches manual calculation on test data |
| US-12 | Admin | see who changed a price or edited an expense | people are accountable | Audit log shows old/new value, user, time |
| US-13 | Admin | add and deactivate users with roles | access is controlled | Cashier cannot open Expense or P&L pages (HTTP 403) |

---

# 7. PROJECT IMPLEMENTATION ROADMAP

## 7.1 Phases Overview

| Phase | Focus | Outcome |
|---|---|---|
| **Phase 1** | Setup & Database | Project skeleton, MySQL schema, Hibernate connected, entities mapped, seed data |
| **Phase 2** | Core Modules | Auth, Products, Stock/Batches, Sales (POS) working end-to-end with frontend |
| **Phase 3** | Advanced Features | Expenses, Payroll, Reports, P&L, anti-theft analytics, audit, polish & deploy |

## 7.2 Phase 1 — Setup & Database
- Install JDK 17/21, Maven, MySQL 8, Tomcat 10 (or Javalin), IntelliJ/Eclipse, Git, Postman, DBeaver
- Create the Git repo and `.gitignore` (exclude config with passwords, `target/`, IDE files)
- Maven project with the package structure from §3.3; add dependencies (Hibernate, MySQL driver, HikariCP, Gson/Jackson, BCrypt, Logback, JUnit 5)
- Write `schema.sql` (tables, constraints, indexes) and `seed.sql` (admin user, categories, 30–50 realistic products, suppliers, expense categories)
- Configure Hibernate (`persistence.xml` or `hibernate.cfg.xml`) — start with `hbm2ddl=validate` once your SQL is the source of truth (use `update` only briefly while learning)
- Map entities and enums; write a throwaway `main()` to persist and read a Product to prove the connection
- Build `BaseEntity`, `HibernateUtil`/`EntityManagerFactory` provider, `ApiResponse` and exception classes

## 7.3 Phase 2 — Core Modules
- Authentication + filters + role enforcement; login page
- Product, category, supplier CRUD with search and pagination
- Receive stock → batches → ledger
- FEFO logic with unit tests
- Sales/POS backend + POS page; receipt page
- Void/return (basic version)
- Dashboard with basic tiles

## 7.4 Phase 3 — Advanced Features
- Stock adjustments + approval workflow, stock count & variance
- Expense and payroll modules
- All reports, CSV export, **Profit & Loss**
- Suspicious Activity Report (voids, discounts, adjustments, variances)
- Audit log viewer, settings
- Charts (Chart.js), form polish, error handling
- README, screenshots, demo data, Postman collection, deployment/run instructions

## 7.5 Three-Week Learning & Building Plan

> Assumes about 6 working days per week. Adjust daily hours to your schedule — what matters is that **each day ends with working, committed code.**

### WEEK 1 — Foundation, Database & Product/Stock Basics
| Day | Tasks | Learn / practise |
|---|---|---|
| 1 | Install tools; create repo; Maven project; folder structure; commit README skeleton | Maven, project layout, Git workflow |
| 2 | Finalise ER diagram in MySQL Workbench/DBeaver; write `schema.sql`; run it; seed data | SQL DDL, keys, constraints, indexes |
| 3 | Hibernate/JPA config; map `Category`, `Supplier`, `Product`; test insert/select | Entity annotations, `EntityManager`, transactions |
| 4 | Map `StockBatch`, `StockMovement`, `User`, `Staff`; relationships (`@ManyToOne`, `@OneToMany`) | Lazy vs eager fetching, `mappedBy` |
| 5 | Repository layer + `ProductService` (CRUD, search, validation, price history) | JPQL, pagination, DTOs |
| 6 | Auth: BCrypt, `AuthService`, login endpoint, session, `AuthenticationFilter` | Servlet filters, sessions, security basics |
| **Milestone** | Login works; products CRUD through Postman; tag release `v0.1` | |

### WEEK 2 — Stock Engine & Sales (the heart of the system)
| Day | Tasks | Learn / practise |
|---|---|---|
| 7 | Frontend: login page, layout/navigation, product list/add page using Fetch API | HTML/CSS layout, `fetch`, DOM rendering |
| 8 | Receive stock (batches + ledger); low-stock and expiry queries | Transactions, date queries |
| 9 | FEFO deduction algorithm + **JUnit tests** (multi-batch, insufficient stock, expired batch) | Unit testing, edge cases |
| 10 | `SaleService.createSale()` in a single transaction; payments; receipt numbers | Transaction boundaries, rollback, optimistic locking |
| 11 | POS page: search, cart, totals, payment, receipt print view | JS state handling, CSS print styles |
| 12 | Void & return flow with approval; ledger reversal; audit service | Business rules, audit design |
| **Milestone** | Full sale → stock reduced → ledger written → receipt printed; tag `v0.5`; record a 60-second screen demo | |

### WEEK 3 — Money, Reports, Anti-Theft & Polish
| Day | Tasks | Learn / practise |
|---|---|---|
| 13 | Expense module + payroll module (with duplicate-month rule) | Unique constraints, BigDecimal arithmetic |
| 14 | Stock adjustments (approval) + physical count + variance | Workflow/state design |
| 15 | Reports: sales, stock valuation, low stock, expiry; CSV export | JPQL aggregates, `GROUP BY`, DTO projections |
| 16 | **Profit & Loss** + dashboard tiles/charts; unit-test P&L with known numbers | Financial logic, Chart.js |
| 17 | Suspicious Activity Report; audit log viewer; role-permission checks on every endpoint (try to break it as a Cashier) | Security testing |
| 18 | Polish UI, validate inputs, fix bugs, N+1 check, indexes; write README, take screenshots, publish post; tag `v1.0` | Documentation & presentation |

**If you fall behind:** protect the core. The must-haves are *Auth → Products → Batches → FEFO → Sales → Low-stock/Expiry reports → Expenses/Payroll → P&L.* Treat customers, purchase orders, split payments, and charts as stretch goals.

## 7.6 Testing Checklist
- [ ] FEFO picks the earliest-expiring batch first and spans multiple batches
- [ ] Cannot sell more than stock / cannot sell expired stock
- [ ] Rollback leaves stock unchanged after a mid-sale failure
- [ ] Two simultaneous sales of the last unit → only one succeeds
- [ ] Cashier gets 403 on expenses, payroll, P&L
- [ ] P&L equals a hand-calculated example
- [ ] Duplicate salary for same month rejected
- [ ] Void restores stock correctly and audit row exists
- [ ] SQL-injection and XSS attempts in search fields are harmless

## 7.7 Suggested Test Dataset for Demos
- 40–60 products across 6–8 categories (mix of OTC and prescription-only)
- 3–5 suppliers; multiple batches for the same product with different expiry dates
- 2–3 near-expiry batches and 3–4 low-stock products
- ~100 sales across 30 days from 2–3 cashiers, including one cashier with a deliberately high void/discount rate so the Suspicious Activity Report has something to catch
- 10–15 expenses, 3–4 staff, 1–2 months of payroll

---

# 8. DELIVERABLES FOR YOUR PORTFOLIO

## 8.1 GitHub Repository

**Name suggestion:** `PharmaTrack-Pharmacy-Management-System`

**Structure**
```
PharmaTrack/
├── README.md                  ← the most important file
├── docs/
│   ├── System_Documentation.md   (this document)
│   ├── er-diagram.png
│   ├── architecture-diagram.png
│   ├── use-case-diagram.png
│   └── screenshots/
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   └── backup-instructions.md
├── src/main/java/...
├── src/main/webapp/...
├── src/test/java/...
├── postman/PharmaTrack.postman_collection.json
├── config.example.properties   ← NO real passwords
├── pom.xml
├── .gitignore
└── LICENSE
```

**README must include:** one-paragraph pitch · problem it solves · feature list · screenshots/GIF · tech stack · architecture diagram · ER diagram · how to run (prerequisites, create DB, run `schema.sql` + `seed.sql`, configure properties, build, start server) · default demo login credentials · roles table · API summary · testing instructions · design decisions (FEFO, ledger, snapshots) · roadmap/future work · author + LinkedIn link.

**Git habits that impress:** small, meaningful commits (`feat: implement FEFO stock deduction`); milestone tags (`v0.1`, `v0.5`, `v1.0`); a `develop`/feature-branch flow; no secrets in history.

## 8.2 Screenshots to Take (use realistic seed data)
1. Login page
2. Dashboard (sales today, low-stock count, expiring soon, chart)
3. **POS screen mid-sale** (cart with 3–4 items)
4. Printed receipt
5. Product list with search
6. Receive-stock form (batch & expiry fields)
7. Low-stock / reorder report
8. Expiry report (30/60/90-day colour coding)
9. Stock movement ledger for one product
10. Stock count variance report
11. **Suspicious Activity Report** (your anti-theft hero shot)
12. Expense list / expense-by-category chart
13. Payroll screen / payslip
14. **Profit & Loss statement**
15. Audit log
16. ER diagram and architecture diagram
17. Test run results (JUnit green) and a Postman 403 response for a cashier hitting an admin endpoint

Also record a **60–90 second screen-capture GIF/video**: login → make a sale → stock drops → open P&L.

## 8.3 CV Entries

**Project line (CV)**
> **PharmaTrack — Pharmacy Inventory & Sales Management System** | Java 17, Hibernate/JPA, MySQL, Servlets, HTML/CSS/JavaScript, JUnit | *GitHub link*

**Bullet points (pick 4–5; replace numbers with your real ones)**
- Designed and built a full-stack pharmacy management system using a layered architecture (Controller–Service–Repository–Entity) with Hibernate/JPA and MySQL across 20+ normalised tables.
- Implemented batch-level inventory with **FEFO** stock deduction, expiry blocking, and an append-only stock-movement ledger, giving full traceability of every unit.
- Engineered transactional sales processing with optimistic locking to prevent overselling and ensure atomic stock updates.
- Built role-based access control (Admin, Pharmacist, Cashier, Store Keeper), BCrypt password hashing, and an audit trail for sensitive actions.
- Developed analytics for stock-outs, expiring stock, inventory variance and suspicious activity (voids/discounts/adjustments) plus automated **Profit & Loss** reporting that incorporates COGS, expenses and payroll.
- Wrote JUnit tests for core business rules (FEFO allocation, P&L calculation).

**Skills section additions:** Java, JPA/Hibernate, JPQL, MySQL, REST API design, Maven, JUnit 5, Git, Servlets, Role-Based Access Control, Database Design/Normalisation, Transaction Management.

## 8.4 LinkedIn

**Featured section:** pin the GitHub repo, demo video, and your launch post.

**Launch post (template — edit with your real figures)**
```
Stock-outs, expired drugs, and "missing" inventory quietly drain small pharmacies every month. 💊

I built PharmaTrack to fix that — a Java system that tracks every tablet from supplier to customer.

What's inside:
• FEFO stock deduction, so the earliest-expiring batch is always sold first
• An append-only stock ledger, so every missing unit leaves a trail
• Suspicious-activity reports on voids, discounts and adjustments
• Automatic Profit & Loss from sales, COGS, expenses and payroll
• Transactional sales with optimistic locking, so two cashiers can't sell the last unit

Stack: Java · Hibernate/JPA · MySQL · HTML/CSS/JS · JUnit

The hardest part? Making a sale and its stock deduction succeed or fail together.

How would you design theft detection in a small retail business?

GitHub: <link>

#Java #Hibernate #MySQL #SoftwareEngineering #Fintech #Nigeria #LagosTech #BuildInPublic
```

**Follow-up post ideas (one per week, builds consistent visibility)**
1. "Why I store `unit_cost` on every sale line" (data snapshots & accurate COGS)
2. "How FEFO works — and how I tested it" (with a screenshot of the JUnit run)
3. "I found an N+1 query bug in my own report — here's the fix" (before/after SQL log)
4. "Designing a Profit & Loss statement from raw transactions"
5. "Preventing double payroll with a database unique constraint"

**Fintech angle:** since the project handles money, frame it around *data integrity, auditability, and fraud/leakage detection* — the same concerns payment companies care about. A natural v2 is adding a Paystack/Flutterwave payment integration for card/transfer sales (sandbox mode), which strongly signals fintech readiness.

## 8.5 Interview Talking Points
- Why a ledger plus cached batch quantity? (auditability vs speed)
- Why snapshot price and cost into `sale_items`?
- Why `BigDecimal`, not `double`?
- How optimistic locking prevents overselling; when you'd choose pessimistic locking instead
- Lazy vs eager loading and how you diagnosed N+1
- Why DTOs instead of exposing entities
- Why enforce authorisation in the backend and not just the UI
- What you would change to scale to multiple branches (add `branch_id`, per-branch stock, central reporting)

## 8.6 Final "Definition of Done" Checklist
- [ ] All must-have FRs implemented and demoed
- [ ] Unit tests pass; core business rules covered
- [ ] README with screenshots, run instructions, demo credentials
- [ ] No secrets or real data in the repo
- [ ] `schema.sql` + `seed.sql` run cleanly on a fresh MySQL
- [ ] 60–90 second demo video recorded
- [ ] CV and LinkedIn updated; launch post published
- [ ] Release tag `v1.0` created

---

## Appendix A — Glossary
| Term | Meaning |
|---|---|
| FEFO | First-Expiry-First-Out: sell the batch that expires soonest |
| COGS | Cost of Goods Sold: purchase cost of the items actually sold |
| SKU | Stock Keeping Unit: unique product code |
| Shrinkage | Stock loss from theft, damage, or errors |
| Ledger | Append-only history of all stock changes |
| NAFDAC | Nigeria's National Agency for Food and Drug Administration and Control (registration number printed on drugs) |
| DTO | Data Transfer Object: a plain class used to move data between layers |
| RBAC | Role-Based Access Control |

## Appendix B — Future Enhancements (v2+)
Payment gateway integration (Paystack/Flutterwave sandbox) · SMS/email alerts for low stock and expiry · barcode label printing · multi-branch support · customer loyalty points · controlled-drug register · PDF report export · Docker deployment · Spring Boot migration of the same domain as a comparison project.

*End of document.*
