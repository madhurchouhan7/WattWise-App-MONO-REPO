// src/routes/user.routes.js
// User profile routes (protected)

const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');
const userController = require('../controllers/user.controller');

// All routes below require a valid JWT
router.use(authMiddleware);

// GET  /api/v1/users/me  — get current user profile
router.get('/me', userController.getMe);

// PUT  /api/v1/users/me  — update current user profile
router.put('/me', userController.updateMe);

// PUT  /api/v1/users/me/appliances — update user's selected appliances
router.put('/me/appliances', userController.updateAppliances);

module.exports = router;
