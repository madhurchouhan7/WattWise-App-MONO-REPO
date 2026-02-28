// src/app.js
// Entry point for the WattWise Express API

require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { initFirebase } = require('../config/firebase');
const connectDB = require('../config/db');
const errorHandler = require('./middleware/errorHandler');
const apiRoutes = require('./routes/index');

// ─── Initialise Firebase Admin SDK ────────────────────────────────────────────
initFirebase();

// ─── Connect to Database ───────────────────────────────────────────────────────
connectDB();

const app = express();

// ─── Security Middleware ───────────────────────────────────────────────────────
app.use(helmet());

// ─── CORS ─────────────────────────────────────────────────────────────────────
const allowedOrigins = process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
    : [];

app.use(
    cors({
        origin: (origin, callback) => {
            // Allow requests with no origin (mobile apps, curl, Postman)
            if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
                return callback(null, true);
            }
            callback(new Error(`CORS policy: origin ${origin} not allowed`));
        },
        credentials: true,
    })
);

// ─── Rate Limiting ─────────────────────────────────────────────────────────────
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200,                  // limit each IP to 200 requests per window
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api', limiter);

// ─── Body Parsing ──────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true }));

// ─── Logging ──────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
    app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
}

// ─── Health Check ─────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
    res.status(200).json({
        success: true,
        message: 'WattWise API is running 🚀',
        environment: process.env.NODE_ENV,
        timestamp: new Date().toISOString(),
    });
});

// ─── API Routes ───────────────────────────────────────────────────────────────
app.use('/api/v1', apiRoutes);

// ─── 404 Handler ──────────────────────────────────────────────────────────────
app.use((_req, res) => {
    res.status(404).json({ success: false, message: 'Route not found.' });
});

// ─── Global Error Handler ─────────────────────────────────────────────────────
app.use(errorHandler);

// ─── Start Server ─────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀  WattWise API running on port ${PORT} [${process.env.NODE_ENV}]`);
});

module.exports = app; // for testing
