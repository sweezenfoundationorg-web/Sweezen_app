const express = require('express');
const cors = require('cors');
const path = require('path');
const axios = require('axios');
require('dotenv').config();

const { connectDb, getDb } = require('./config/db');
const { initSeedData } = require('./seed/seedData');
const apiRoutes = require('./routes/apiRoutes');

const app = express();

// Initialize Database connection
connectDb();

// Middleware
app.use(cors());
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));

// Initialize fallback memory DB seed data
initSeedData();

// API Health Check
app.get('/api/health', (req, res) => {
  const dbConnected = !!getDb();
  res.json({
    status: 'OK',
    app: 'Sweezen Foundation Full-Stack Integrated Backend API',
    timestamp: new Date(),
    smtp: process.env.SMTP_EMAIL ? `Gmail SMTP Active (${process.env.SMTP_EMAIL})` : 'Gmail SMTP Dev Fallback Mode',
    database: dbConnected ? 'MongoDB Atlas (sweezen) Connected' : 'Memory Store Fallback Active',
    payment_gateway: process.env.RAZORPAY_KEY_ID ? `Razorpay Active (${process.env.RAZORPAY_KEY_ID})` : 'Razorpay Simulated Mode',
    remote_backend: process.env.PUBLIC_BASE_URL || 'https://sweezen-backend-deploy-main.onrender.com'
  });
});

// Static Files Serving (Admin Panel Dashboard & Uploads)
app.use(express.static(path.join(__dirname, '../public')));

// Admin Panel Direct Route
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin/index.html'));
});

// Primary API Routes (Auth, Projects, Donations, Volunteers, Events, etc.)
app.use('/api', apiRoutes);

// Fallback Proxy to Remote Website Backend (sweezen-backend-deploy-main.onrender.com) for extra endpoints
app.use(async (req, res, next) => {
  if (!req.path.startsWith('/api')) return next();
  try {
    const targetUrl = `${process.env.PUBLIC_BASE_URL || 'https://sweezen-backend-deploy-main.onrender.com'}${req.originalUrl}`;
    const response = await axios({
      method: req.method,
      url: targetUrl,
      headers: { ...req.headers, host: undefined },
      data: req.body,
      validateStatus: () => true
    });
    return res.status(response.status).send(response.data);
  } catch (err) {
    return res.status(502).json({ success: false, message: 'Upstream website backend unavailable', error: err.message });
  }
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]', err);
  res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
});

module.exports = app;
