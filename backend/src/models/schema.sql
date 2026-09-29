-- Sweezen Foundation PostgreSQL Schema

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(50) DEFAULT 'Volunteer', -- Volunteer, Donor, Researcher, Beneficiary, Staff, Partner, Admin
    profile_photo TEXT,
    skills TEXT[],
    interests TEXT[],
    location VARCHAR(255),
    availability VARCHAR(100),
    experience TEXT,
    documents JSONB DEFAULT '[]',
    impact_points INT DEFAULT 0,
    badges TEXT[] DEFAULT '{}',
    humanity_card_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS otps (
    id SERIAL PRIMARY KEY,
    target VARCHAR(255) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL, -- Healthcare, Education, Environment
    description TEXT NOT NULL,
    objectives TEXT[],
    location VARCHAR(255) NOT NULL,
    beneficiary_count INT DEFAULT 0,
    funding_goal NUMERIC(12, 2) DEFAULT 0,
    funding_raised NUMERIC(12, 2) DEFAULT 0,
    funding_utilized NUMERIC(12, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'Active',
    image_url TEXT,
    video_url TEXT,
    milestones JSONB DEFAULT '[]',
    documents JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS donations (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    donor_name VARCHAR(255),
    donor_email VARCHAR(255),
    donor_phone VARCHAR(50),
    project_id INT REFERENCES projects(id) ON DELETE SET NULL,
    amount NUMERIC(12, 2) NOT NULL,
    donation_type VARCHAR(50) DEFAULT 'One-Time', -- One-Time, Recurring, Corporate
    payment_method VARCHAR(50) DEFAULT 'Razorpay', -- UPI, Card, NetBanking, Razorpay
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_80g_requested BOOLEAN DEFAULT TRUE,
    pan_number VARCHAR(20),
    receipt_url TEXT,
    status VARCHAR(50) DEFAULT 'Success',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    required_skills TEXT[],
    date_time TIMESTAMP WITH TIME ZONE,
    assigned_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'Pending', -- Pending, In Progress, Completed
    remarks TEXT,
    photo_url TEXT,
    geo_lat NUMERIC(10, 7),
    geo_lng NUMERIC(10, 7),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    date_time TIMESTAMP WITH TIME ZONE,
    location VARCHAR(255),
    capacity INT DEFAULT 100,
    registered_count INT DEFAULT 0,
    banner_url TEXT,
    status VARCHAR(50) DEFAULT 'Upcoming'
);

CREATE TABLE IF NOT EXISTS event_registrations (
    id SERIAL PRIMARY KEY,
    event_id INT REFERENCES events(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    certificate_issued BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS humanity_cards (
    id SERIAL PRIMARY KEY,
    card_number VARCHAR(100) UNIQUE NOT NULL,
    beneficiary_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    village_camp VARCHAR(255),
    qr_code_data TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS humanity_card_logs (
    id SERIAL PRIMARY KEY,
    card_number VARCHAR(100) NOT NULL,
    service_type VARCHAR(100) NOT NULL, -- Health, Education, Lounge, Ration
    volunteer_id INT REFERENCES users(id) ON DELETE SET NULL,
    location VARCHAR(255),
    geo_lat NUMERIC(10, 7),
    geo_lng NUMERIC(10, 7),
    notes TEXT,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS announcements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_messages (
    id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    sender_id INT REFERENCES users(id) ON DELETE CASCADE,
    sender_name VARCHAR(255),
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
