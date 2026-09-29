const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const { initSeedData } = require('./seed/seedData');
const apiRoutes = require('./routes/apiRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));

// Initialize memory DB seed data
initSeedData();

// API Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    app: 'Sweezen Foundation Mobile Backend API',
    timestamp: new Date(),
    smtp: process.env.SMTP_EMAIL ? 'Gmail SMTP Active' : 'Gmail SMTP Dev Fallback Mode',
    database: 'PostgreSQL Pool ready with memory store fallback'
  });
});

// Static Files Serving (Admin Panel Dashboard & Uploads)
app.use(express.static(path.join(__dirname, '../public')));

// Admin Panel Direct Route
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin/index.html'));
});

// API Routes
app.use('/api', apiRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]', err);
  res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
});

module.exports = app;
