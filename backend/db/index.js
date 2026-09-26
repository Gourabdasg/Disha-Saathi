/**
 * db/index.js — PostgreSQL Database Pool & Query Interface
 * Disha Saathi · SIH 2026 · PS 26097
 */

const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  console.error('[PostgreSQL Error] DATABASE_URL environment variable is required in .env file.');
}

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: DATABASE_URL && DATABASE_URL.includes('render.com')
    ? { rejectUnauthorized: false }
    : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('error', (err) => {
  console.warn('[PostgreSQL Pool Error]:', err.message);
});

/**
 * Initializes database schema and tables automatically on startup.
 */
async function initDb() {
  if (!DATABASE_URL) {
    console.warn('PostgreSQL initialization skipped: DATABASE_URL environment variable is missing.');
    return;
  }
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE SCHEMA IF NOT EXISTS public;
      SET search_path TO public;

      -- Table 1: Beneficiaries
      CREATE TABLE IF NOT EXISTS beneficiaries (
        id SERIAL PRIMARY KEY,
        mobile VARCHAR(255) DEFAULT '',
        email VARCHAR(255) DEFAULT '',
        name VARCHAR(255) DEFAULT '',
        photo_url TEXT DEFAULT '',
        bio TEXT DEFAULT '',
        annual_income VARCHAR(100) DEFAULT '',
        category VARCHAR(100) DEFAULT 'Scheduled Caste (SC)',
        sc_category_no VARCHAR(100) DEFAULT '',
        sc_certificate_url TEXT DEFAULT '',
        sc_certificate_filename VARCHAR(255) DEFAULT '',
        district VARCHAR(100) DEFAULT '',
        state VARCHAR(100) DEFAULT '',
        location VARCHAR(255) DEFAULT '',
        highest_qualification VARCHAR(255) DEFAULT '',
        stream VARCHAR(255) DEFAULT '',
        year_of_qualification VARCHAR(50) DEFAULT '',
        years_of_study INTEGER DEFAULT 0,
        experience_name VARCHAR(255) DEFAULT '',
        experience_duration VARCHAR(100) DEFAULT '',
        work_experience_years INTEGER DEFAULT 0,
        livelihood VARCHAR(255) DEFAULT '',
        existing_skills TEXT[] DEFAULT '{}',
        career_interests TEXT[] DEFAULT '{}',
        preferred_language VARCHAR(20) DEFAULT 'en',
        profile_completion_percent INTEGER DEFAULT 65,
        journey_percent INTEGER DEFAULT 26,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS photo_url TEXT DEFAULT '';
      ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS bio TEXT DEFAULT '';

      -- Clean empty/null mobile strings to ensure UNIQUE constraint applicability
      UPDATE beneficiaries SET mobile = CONCAT('anon_', id) WHERE mobile IS NULL OR mobile = '';

      -- Ensure UNIQUE constraint on beneficiaries.mobile for ON CONFLICT (mobile)
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'beneficiaries_mobile_unique'
        ) THEN
          DELETE FROM beneficiaries b1
          USING beneficiaries b2
          WHERE b1.id < b2.id AND b1.mobile = b2.mobile;

          ALTER TABLE beneficiaries ADD CONSTRAINT beneficiaries_mobile_unique UNIQUE (mobile);
        END IF;
      END $$;

      -- Table 2: User Profiles (Conversational Onboarding State)
      CREATE TABLE IF NOT EXISTS user_profiles (
        id SERIAL PRIMARY KEY,
        mobile VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) DEFAULT '',
        name VARCHAR(255) DEFAULT '',
        photo_url TEXT DEFAULT '',
        bio TEXT DEFAULT '',
        age INTEGER DEFAULT NULL,
        state VARCHAR(100) DEFAULT '',
        district VARCHAR(100) DEFAULT '',
        location VARCHAR(255) DEFAULT '',
        education VARCHAR(255) DEFAULT '',
        current_occupation VARCHAR(255) DEFAULT '',
        family_occupation VARCHAR(255) DEFAULT '',
        skills TEXT DEFAULT '',
        experience TEXT DEFAULT '',
        interests TEXT DEFAULT '',
        employment_preference VARCHAR(255) DEFAULT '',
        mobility_constraints VARCHAR(255) DEFAULT '',
        career_goal VARCHAR(255) DEFAULT '',
        onboarding_complete BOOLEAN DEFAULT FALSE,
        current_step INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS photo_url TEXT DEFAULT '';
      ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS bio TEXT DEFAULT '';

      -- Table 3: Chat Messages (Multi-session support)
      CREATE TABLE IF NOT EXISTS chat_messages (
        id SERIAL PRIMARY KEY,
        mobile VARCHAR(255) NOT NULL,
        session_id VARCHAR(100) DEFAULT 'default',
        sender VARCHAR(20) NOT NULL CHECK (sender IN ('user', 'bot')),
        text TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      -- Ensure session_id column exists
      ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS session_id VARCHAR(100) DEFAULT 'default';

      -- Table 4: Recommendations
      CREATE TABLE IF NOT EXISTS recommendations (
        id SERIAL PRIMARY KEY,
        beneficiary_id INTEGER REFERENCES beneficiaries(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        match_percent INTEGER DEFAULT 80,
        nsqf_level INTEGER DEFAULT 3,
        duration VARCHAR(100) DEFAULT '3 months',
        sector_name VARCHAR(255) DEFAULT '',
        expected_salary VARCHAR(100) DEFAULT '',
        skills_to_learn TEXT[] DEFAULT '{}',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      -- Table 5: Trainings
      CREATE TABLE IF NOT EXISTS trainings (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        provider VARCHAR(255) NOT NULL,
        distance_km NUMERIC(5,2) DEFAULT 0.0,
        duration VARCHAR(100) DEFAULT '3 Months',
        nsqf_level INTEGER DEFAULT 3,
        free_gia_funded BOOLEAN DEFAULT TRUE,
        seats_left INTEGER DEFAULT 10,
        mode VARCHAR(50) DEFAULT 'Classroom',
        schedule VARCHAR(255) DEFAULT '',
        eligibility VARCHAR(255) DEFAULT '',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      -- Table 6: OTP Codes
      CREATE TABLE IF NOT EXISTS otp_codes (
        id SERIAL PRIMARY KEY,
        identifier VARCHAR(255) NOT NULL UNIQUE,
        otp VARCHAR(20) NOT NULL,
        expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      -- Indexes for performance
      CREATE INDEX IF NOT EXISTS idx_beneficiaries_mobile ON beneficiaries(mobile);
      CREATE INDEX IF NOT EXISTS idx_beneficiaries_email ON beneficiaries(email);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_mobile ON chat_messages(mobile);
      CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(mobile, session_id);
      CREATE INDEX IF NOT EXISTS idx_user_profiles_mobile ON user_profiles(mobile);
      CREATE INDEX IF NOT EXISTS idx_otp_codes_identifier ON otp_codes(identifier);
    `);
    console.log('PostgreSQL database tables initialized successfully');
  } catch (err) {
    console.warn('PostgreSQL table initialization warning (handling gracefully):', err.message);
  } finally {
    client.release();
  }
}

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  initDb,
};
