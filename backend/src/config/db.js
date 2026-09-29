const { Pool } = require('pg');
require('dotenv').config();

// Postgres Pool connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || process.env.POSTGRES_URI,
  user: process.env.PGUSER || 'postgres',
  host: process.env.PGHOST || 'localhost',
  database: process.env.PGDATABASE || 'sweezen_db',
  password: process.env.PGPASSWORD || 'postgres',
  port: parseInt(process.env.PGPORT || '5432'),
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

pool.on('error', (err) => {
  console.error('Unexpected database error:', err);
});

// Memory Database Store fallback for zero-dependency execution
class MemoryStore {
  constructor() {
    this.users = [];
    this.otps = [];
    this.projects = [];
    this.donations = [];
    this.tasks = [];
    this.events = [];
    this.registrations = [];
    this.humanityCards = [];
    this.humanityLogs = [];
    this.announcements = [];
    this.groupMessages = [];
    this.reports = [];
  }
}

const memoryDb = new MemoryStore();

module.exports = {
  pool,
  memoryDb,
  query: async (text, params) => {
    try {
      return await pool.query(text, params);
    } catch (err) {
      console.warn('Postgres connection not available. Operating with fallback storage layer.', err.message);
      throw err;
    }
  }
};
