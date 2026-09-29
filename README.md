# SWEEZEN FOUNDATION - MOBILE APPLICATION & BACKEND SUITE

An enterprise-grade, mobile-first solution for **Sweezen Foundation** built using **Flutter** (Android & iOS) and a **Node.js / Express** REST backend powered by **PostgreSQL**.

The design palette matches the official [Sweezen Foundation website](https://www.sweezenfoundation.org/) with luxury Deep Navy (`#0B132B`), Card Navy (`#152238`), Amber Gold (`#F5A623`), and Pure Gold (`#D4AF37`) branding.

---

## 🌟 Solution Architecture

```
                                 ┌─────────────────────────────────┐
                                 │    Sweezen Mobile App (Flutter) │
                                 │ (Android / iOS / Mobile First)  │
                                 └────────────────┬────────────────┘
                                                  │
                                                  ▼
                                 ┌─────────────────────────────────┐
                                 │   Secure Express REST Backend   │
                                 │          (Node.js / API)        │
                                 └────────┬──────────────┬─────────┘
                                          │              │
                    ┌─────────────────────┴──┐        ┌──┴──────────────────────┐
                    ▼                        ▼        ▼                         ▼
        ┌───────────────────────┐  ┌─────────────┐  ┌──────────┐  ┌───────────────────────────┐
        │ PostgreSQL Database   │  │ Gmail SMTP  │  │ Razorpay │  │ Firebase Cloud Messaging  │
        │ (Users, Tasks, Cards) │  │ (OTP Auth)  │  │ (Payment)│  │    (Push Notifications)   │
        └───────────────────────┘  └─────────────┘  └──────────┘  └───────────────────────────┘
```

---

## 📱 Mobile Application Modules (Flutter)

1. **Brand Aesthetic & Luxury Theme**
   - Matches official website color scheme: `#0B132B` Deep Navy, `#152238` Card Navy, `#D4AF37` / `#F5A623` Gold Accent.
   - Golden Eagle branding logo integrated across Splash, Header, Drawers, and Cards.

2. **User Authentication & Multi-Step Registration**
   - Mobile / Email login with **Gmail SMTP OTP verification**.
   - **4-Step Registration Workflow**:
     - Step 1: Personal Info (Name, Email, Mobile).
     - Step 2: User Role Selection Cards (*Volunteer*, *Donor*, *Researcher*, *Beneficiary*, *Foundation Staff*, *Partner Org*).
     - Step 3: Document Uploads (*Government ID Proof*, *Resume / CV*).
     - Step 4: Skills, Availability (*Weekends*, *Full-Time*, *On-Call*), and Location setup.

3. **Home Screen Dashboard**
   - Rotating hero campaign banners (*"Your ₹1000 can change a life today"*).
   - Real-time impact statistics counter grid (*Total Projects: 25+*, *Beneficiaries: 48,200+*, *Volunteers: 1,240+*, *Funds Raised: ₹4.82 Cr*).
   - Featured projects carousel with progress bars and "Donate Now" CTAs.
   - Quick statistics, social links, and direct WhatsApp Business API launcher.

4. **Projects / Programs Module**
   - Category filtering chips (*Healthcare*, *Education*, *Environment*).
   - Search bar across active programs.
   - Detailed project view with objectives, location, raised vs goal, beneficiary count, and financial utilization breakdown.

5. **Donation Module & 80G Tax Receipts**
   - One-Time vs Recurring donation toggle.
   - Program-specific vs General Foundation fund allocation.
   - Preset quick amount chips (₹500, ₹1000, ₹2500, ₹5000, Custom).
   - Razorpay payment gateway integration (UPI, Cards, NetBanking).
   - Instant digital **80G Tax Exemption Certificate generation** with interactive PDF preview, export, and print integration.
   - Anonymous donor privacy option.

6. **Volunteer & Field Task Management**
   - Volunteer profile card displaying skills, location, availability, **Impact Points Counter (340 pts)**, and **Achievement Badges** (*"Community Hero"*, *"100+ Hours"*).
   - Assigned tasks list (*Pending*, *In Progress*, *Completed*).
   - **GPS Geo-Tagged Reporting**: Auto-captures latitude/longitude coordinates and camera photograph attachments.
   - **Offline Synchronization**: Queues field reports locally when offline and syncs automatically with the Cloud database when connection is restored.

7. **Humanity Card / Smart ID Module**
   - Digital Smart ID Card with unique Card Number and dynamic QR Code.
   - Built-in **Service-Point QR Scanner**: Field volunteers scan beneficiary cards at mobile camps to instantly log Health consultations, Education kits, Ration packs, or Lounge access to the cloud.

8. **Events & Digital Certificates**
   - Search & discover upcoming conclaves and health camps.
   - 1-tap event registration with automatic digital participation certificate generation.

9. **"Ask Sweezen" AI Assistant Chatbot**
   - Floating AI assistant sheet providing 24/7 guidance on 80G tax exemptions, active healthcare programs, volunteer task submission, and Humanity Smart IDs in both **English** and **Hindi**.

10. **Multilingual Support (English & Hindi)**
    - Real-time language switcher (`EN` ↔ `HI`) integrated smoothly into top app header.

---

## 🛠 Backend APIs (Node.js + Express + PostgreSQL)

- **Base URL**: `http://localhost:5000/api`

### API Endpoints Overview:

| Module | Method | Endpoint | Description |
|---|---|---|---|
| **Health** | `GET` | `/api/health` | Backend status & DB connection check |
| **Auth** | `POST` | `/api/auth/request-otp` | Sends 6-digit OTP code via **Gmail SMTP** |
| **Auth** | `POST` | `/api/auth/verify-otp` | Verifies OTP code and returns JWT token |
| **Auth** | `POST` | `/api/auth/register` | Multi-step registration for all 6 user roles |
| **Projects** | `GET` | `/api/projects` | Fetch programs (Category filter: Healthcare, Education, Environment) |
| **Projects** | `GET` | `/api/projects/:id` | Detailed project metrics and milestones |
| **Donation** | `POST` | `/api/donations/create-order` | Initiates Razorpay payment order |
| **Donation** | `POST` | `/api/donations/verify-payment` | Verifies Razorpay payment & generates 80G receipt |
| **Donation** | `GET` | `/api/donations/receipt/:txnId` | Fetches 80G e-receipt JSON payload |
| **Volunteer**| `GET` | `/api/volunteer/tasks` | Assigned tasks list for field volunteers |
| **Volunteer**| `POST` | `/api/volunteer/submit-report` | Geo-tagged field report submission (Photos + GPS) |
| **Volunteer**| `POST` | `/api/volunteer/sync-offline` | Batch sync for offline field reports |
| **Smart ID** | `POST` | `/api/humanity-card/lookup` | Looks up beneficiary card by QR code |
| **Smart ID** | `POST` | `/api/humanity-card/log-service` | Logs service-point scan (Health/Education/Ration) |
| **Events** | `GET` | `/api/events` | Upcoming events and summits |
| **Events** | `POST` | `/api/events/register` | 1-tap event registration & certificate issuing |
| **Chatbot** | `POST` | `/api/chatbot/ask` | "Ask Sweezen" AI assistant answering engine |
| **Admin** | `GET` | `/api/admin/stats` | Live admin analytics (Projects, Funds, Beneficiaries) |
| **Admin** | `POST` | `/api/admin/send-push` | Firebase Cloud Messaging (FCM) push broadcast |

---

## 🚀 How to Run the Application

### 1. Run the Backend API Server:
```bash
cd backend
npm install
npm start
```
> Server will start on `http://localhost:5000`.

### 2. Run the Flutter Mobile Application:
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🎨 Assets & Branding
- **Logo Path**: `mobile/assets/images/logo.png`
- **Color Theme**:
  - Deep Navy: `#0B132B`
  - Card Navy: `#152238`
  - Accent Gold: `#F5A623` / `#D4AF37`
