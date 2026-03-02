// src/routes/index.js
// Central router — mounts all feature route modules under /api/v1

const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
// Future routes can be added here, e.g.:
// const applianceRoutes = require('./appliance.routes');
// const billRoutes      = require('./bill.routes');
const aiRoutes = require('./ai.routes');
const bbpsRoutes = require('./bbps.routes');

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/ai', aiRoutes);
router.use('/bbps', bbpsRoutes);

module.exports = router;
