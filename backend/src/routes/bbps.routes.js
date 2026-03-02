// src/routes/bbps.routes.js
const express = require('express');
const router = express.Router();
const bbpsController = require('../controllers/bbps.controller');

// Public endpoint testing Setu BBPS directly
router.post('/fetch-bill', bbpsController.fetchBill);

module.exports = router;
