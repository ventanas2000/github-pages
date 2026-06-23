# Clasificados Pro - Technical Specification Document

**Version:** 1.0  
**Author:** Lead Software Architect & CTO  
**Date:** 2024  
**Status:** Production Ready Blueprint  

---

## Executive Summary

"Clasificados Pro" is a hyper-local marketplace application designed to bridge the gap between traditional newspaper classifieds and modern mobile efficiency. The core value proposition rests on **Trust and Proximity**, enabled by a hybrid location engine, strict categorization, and an automated ad lifecycle management system.

This document outlines the complete technical architecture, database schema, API design, and scalability strategies required to build a production-ready platform capable of scaling city-by-city.

---

## 1. Technology Stack Recommendation

### 1.1 Mobile Application (Frontend)
**Recommendation:** **Flutter (Dart)**

*   **Rationale:** 
    *   **Single Codebase:** Delivers native performance on both iOS and Android from one codebase, reducing development time and cost by ~40%.
    *   **Geospatial Support:** Excellent plugins for Google Maps/Mapbox and background location services.
    *   **Camera/Media:** Robust handling of image capture, compression, and upload workflows critical for the "3-Step Wizard."
    *   **UI Consistency:** Ensures the strict 3-step flow looks identical across devices.

### 1.2 Backend Architecture
**Recommendation:** **Node.js (NestJS Framework) with RESTful API**

*   **Rationale:**
    *   **Performance:** Non-blocking I/O is ideal for high-concurrency read operations (browsing ads).
    *   **Ecosystem:** Mature libraries for geospatial calculations (`turf.js`), image processing (`sharp`), and payment gateways (Stripe/PayPal).
    *   **Structure:** NestJS provides an opinionated, modular architecture (Controllers, Services, Modules) that enforces clean code standards suitable for enterprise growth.
    *   **API Style:** REST is preferred over GraphQL for this use case due to simpler caching strategies at the CDN/Load Balancer level for public ad feeds.

### 1.3 Database Strategy (Hybrid Approach)
**Recommendation:** **PostgreSQL + PostGIS**

*   **Rationale:**
    *   **Relational Integrity:** ACID compliance for users, transactions, and subscriptions.
    *   **Geospatial Power:** PostGIS is the industry standard for location queries. It handles both **Hierarchical** (City/State IDs) and **Geospatial** (Lat/Long radius) queries in a single engine, eliminating the need for a separate NoSQL store.
    *   **JSONB Support:** Allows flexible storage for dynamic ad attributes (e.g., car mileage vs. house square footage) without schema migrations.

### 1.4 Infrastructure & Cloud (AWS)
*   **Compute:** **AWS ECS Fargate** (Serverless Containers) for the API. Scales automatically based on CPU/Memory usage.
*   **Database:** **Amazon RDS for PostgreSQL** with PostGIS extension enabled. Multi-AZ for high availability.
*   **Storage:** **Amazon S3** for raw image storage.
*   **Image Processing:** **AWS Lambda** triggered by S3 uploads to resize/compress images and generate thumbnails.
*   **CDN:** **Amazon CloudFront** to serve images globally with low latency.
*   **Caching:** **Amazon ElastiCache (Redis)** for session management and caching frequent "City Feed" queries.
*   **Background Jobs:** **AWS SQS** (Queue) + **Worker Services** for expiration checks and notification sending.

---

## 2. Database Schema Design

The following schema utilizes PostgreSQL syntax with PostGIS extensions. It supports the Hybrid Location Engine, Strict Taxonomy, and Ad Lifecycle.

```sql
-- Enable PostGIS extension for geospatial capabilities
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. USERS TABLE
-- Supports Auth, Roles (User, Pro, Admin), and Verification Status
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'pro', 'admin')),
    is_verified BOOLEAN DEFAULT FALSE, -- For "Verified Badge"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for fast login lookups
CREATE INDEX idx_users_email ON users(email);

-- 2. LOCATIONS TABLE (Hierarchical + Geospatial)
-- Stores Country, State, City hierarchy with a central point for City
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL CHECK (type IN ('country', 'state', 'city')),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES locations(id), -- Self-referential for hierarchy
    geog GEOGRAPHY(POINT, 4326), -- Central coordinate for the city/state
    
    -- Materialized path for fast hierarchical queries (e.g., /MX/JAL/GDL)
    path_string VARCHAR(255) 
);

-- Index for geospatial radius queries
CREATE INDEX idx_locations_geog ON locations USING GIST(geog);
-- Index for hierarchy lookup
CREATE INDEX idx_locations_parent ON locations(parent_id);

-- 3. CATEGORIES TABLE (Strict Taxonomy)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    parent_id INTEGER REFERENCES categories(id),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    default_expiration_days INTEGER NOT NULL, -- 60, 20, 15, etc.
    path_string VARCHAR(255) -- e.g., /services/plumbing
);

-- 4. ADS TABLE (Core Entity)
CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    location_city_id UUID NOT NULL REFERENCES locations(id), -- Hierarchical link
    
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Geospatial snapshot (denormalized for fast radius search without joins)
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location_point GEOGRAPHY(POINT, 4326) GENERATED ALWAYS AS (ST_MakePoint(longitude, latitude)) STORED,

    -- Lifecycle Management
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'expired', 'paused', 'banned')),
    posted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    renewed_count INTEGER DEFAULT 0,
    
    -- Monetization Flags
    is_bumped BOOLEAN DEFAULT FALSE,
    bump_expires_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Critical Indexes for Performance
CREATE INDEX idx_ads_location_point ON ads USING GIST(location_point); -- Radius search
CREATE INDEX idx_ads_city_status ON ads(location_city_id, status); -- City feed filtering
CREATE INDEX idx_ads_expires ON ads(expires_at); -- Background worker scanning
CREATE INDEX idx_ads_bumped ON ads(is_bumped, posted_at) WHERE is_bumped = TRUE; -- Premium feed

-- 5. AD_IMAGES TABLE
CREATE TABLE ad_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ad_id UUID NOT NULL REFERENCES ads(id) ON DELETE CASCADE,
    s3_key VARCHAR(255) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0
);

-- 6. SUBSCRIPTIONS & TRANSACTIONS
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    plan_type VARCHAR(20) CHECK (plan_type IN ('pro_monthly', 'pro_yearly')),
    status VARCHAR(20) DEFAULT 'active',
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    stripe_subscription_id VARCHAR(255)
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    ad_id UUID REFERENCES ads(id), -- Null if subscription renewal
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    type VARCHAR(20) CHECK (type IN ('bump_ad', 'subscription', 'listing_fee')),
    status VARCHAR(20) DEFAULT 'completed',
    payment_provider_id VARCHAR(255), -- Stripe PaymentIntent ID
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. NOTIFICATIONS QUEUE (For Expiration Alerts)
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    ad_id UUID REFERENCES ads(id),
    type VARCHAR(50), -- 'expiry_warning', 'renewal_success'
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 3. API & Logic Design

### 3.1 Core API Endpoints

The API follows RESTful conventions. All responses return JSON.

#### A. The 3-Step Wizard (Ad Creation)

**Step 1: Category Selection**
*   `GET /api/v1/categories`
    *   Returns the taxonomy tree.
    *   Response includes `default_expiration_days` for UI hints.

**Step 2: Details & Photo Upload**
*   `POST /api/v1/ads/draft`
    *   Body: `{ title, description, price, category_id, photos: [files] }`
    *   Logic: Creates an ad in `status: 'draft'`. Images are uploaded to S3 via Pre-Signed URLs.
*   `PUT /api/v1/ads/:id/media`
    *   Handles reordering or deleting images before publishing.

**Step 3: Location & Confirmation**
*   `POST /api/v1/ads/:id/publish`
    *   Body: `{ location_mode: 'gps'|'manual', lat, long, city_id, contact_phone }`
    *   Logic: 
        1. Validates location data.
        2. Calculates `expires_at` based on Category rules.
        3. Checks "First Ad Free" logic (Query `COUNT(ads)` for user).
        4. Sets status to `active`.
        5. Triggers async indexing.

#### B. Hybrid Search Engine

*   `GET /api/v1/ads/search`
    *   Query Parameters:
        *   `mode`: `geo` | `hierarchy`
        *   `lat`, `lng`, `radius_km`: (Required if mode=geo)
        *   `city_id`: (Required if mode=hierarchy)
        *   `category_id`: Optional filter
        *   `sort`: `newest` | `price_asc` | `bumped`
    
    *   **Logic Implementation:**
        *   *If Hierarchy:* `SELECT * FROM ads WHERE location_city_id = $1 AND status = 'active' AND expires_at > NOW()`
        *   *If Geo:* `SELECT * FROM ads WHERE ST_DWithin(location_point, ST_MakePoint($lng, $lat)::geography, $radius_meters) AND status = 'active'`
        *   *Boosting:* Always order by `is_bumped DESC, posted_at DESC`.

### 3.2 Expiration Background Worker

We will use a **Delayed Job Queue** pattern (e.g., BullMQ with Redis or AWS SQS with Delay).

**Workflow:**
1.  **Daily Cron (00:00 UTC):** A scheduled job scans the `ads` table.
    ```sql
    SELECT id, user_id, expires_at 
    FROM ads 
    WHERE status = 'active' 
    AND expires_at BETWEEN NOW() AND NOW() + INTERVAL '3 days'
    AND notified_3_days = FALSE;
    ```
2.  **Action:** For each result:
    *   Insert record into `notifications` table ("Your ad expires in 3 days!").
    *   Send Push Notification (via Firebase Cloud Messaging) and Email (via SES/SendGrid).
    *   Update flag `notified_3_days = TRUE`.
3.  **Expiration Cron (Every Hour):**
    ```sql
    UPDATE ads SET status = 'expired' 
    WHERE expires_at < NOW() AND status = 'active';
    ```
4.  **Renewal Endpoint:** `POST /api/v1/ads/:id/renew`
    *   Validates payment (if not free tier).
    *   Adds `default_expiration_days` to current `expires_at`.
    *   Resets `notified_3_days = FALSE`.

### 3.3 Geospatial Query Logic (Hybrid Combination)

To support users who want "Plumbers in Guadalajara" (Hierarchy) but also see results sorted by distance from their current GPS:

1.  **Filter Phase:** Use the Hierarchical `city_id` to narrow the dataset. This is highly indexed and fast.
2.  **Sort Phase:** Calculate distance using the user's provided GPS coordinates against the ad's stored `location_point`.
    ```sql
    SELECT *, 
           ST_Distance(location_point, ST_MakePoint($user_lng, $user_lat)::geography) as distance_meters
    FROM ads
    WHERE location_city_id = $city_id
      AND status = 'active'
    ORDER BY is_bumped DESC, distance_meters ASC
    LIMIT 20;
    ```
This provides the best of both worlds: Administrative boundary enforcement with precise proximity sorting.

---

## 4. Scalability & Security Strategy

### 4.1 Image Handling at Scale
Direct uploads to the API server will be blocked to prevent bottlenecks.
1.  **Client Request:** App requests a `Pre-Signed URL` from the API (`GET /api/v1/upload-url`).
2.  **Direct Upload:** App uploads the image directly to Amazon S3 using the URL.
3.  **Trigger:** S3 event notification triggers an **AWS Lambda** function.
4.  **Processing:** Lambda uses `sharp` to create:
    *   Thumbnail (150x150) for lists.
    *   Medium (800x600) for details.
    *   Original (preserved for zoom).
5.  **Delivery:** Images are served via **CloudFront CDN**, ensuring low latency regardless of user location.

### 4.2 Security Measures
*   **Authentication:** JWT (JSON Web Tokens) with short-lived access tokens (15 min) and rotating refresh tokens.
*   **Data Privacy:** PII (Phone numbers, exact addresses) is obfuscated in the API response until a specific "Reveal" action is taken (optional feature to prevent scraping).
*   **Payment Security:** Strict adherence to PCI-DSS by using **Stripe Elements**. No credit card data touches our servers; only token IDs are stored.
*   **Rate Limiting:** Implement Redis-based rate limiting on all write endpoints (`POST`, `PUT`) to prevent spam bots from flooding the ad creation flow.
*   **Content Moderation:** Integrate AWS Rekognition or a similar AI service in the image upload pipeline to automatically flag inappropriate content (nudity, violence) before the ad goes live.

### 4.3 Horizontal Scaling Strategy
As we expand city-by-city:
1.  **Database Read Replicas:** Configure RDS with Read Replicas. All `GET /search` traffic goes to replicas; `POST/PUT` goes to the primary writer.
2.  **Sharding (Future Proofing):** If a single city generates >1M ads, shard the `ads` table by `location_city_id`. Since queries are almost always scoped to a city, this allows linear scaling.
3.  **Microservices Split:** Initially a Modular Monolith (NestJS). As complexity grows, extract:
    *   `Notification Service` (Handles emails/push).
    *   `Search Service` (Could move to Elasticsearch/Algolia if PostGIS becomes a bottleneck for text search).
    *   `Billing Service` (Isolates financial logic).
4.  **Infrastructure as Code:** All AWS resources defined in **Terraform**. This allows replicating the entire stack in a new region (e.g., expanding from Mexico to Colombia) with a single command.

---

## 5. Implementation Roadmap (Phased)

1.  **Phase 1 (MVP):** Core Schema, Manual Location Mode, Basic Ad Posting, Free Tier only.
2.  **Phase 2 (Growth):** Geospatial Mode, Image Optimization Pipeline, Expiration Worker.
3.  **Phase 3 (Monetization):** Stripe Integration, Bump Ads, Pro Subscriptions, Verified Badges.
4.  **Phase 4 (Scale):** Analytics Dashboard, Advanced Filtering, Multi-language support.

---

*End of Technical Specification Document*
