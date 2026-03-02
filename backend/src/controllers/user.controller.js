// src/controllers/user.controller.js
// Handles requests about the currently authenticated user

const User = require('../models/User.model');
const { sendSuccess } = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');

// ─── GET /api/v1/users/me ─────────────────────────────────────────────────────
exports.getMe = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user) throw new ApiError(404, 'User not found.');
        return sendSuccess(res, 200, 'User profile fetched.', typeof user.toPublicJSON === 'function' ? user.toPublicJSON() : user.toJSON());
    } catch (error) {
        next(error);
    }
};

// ─── PUT /api/v1/users/me ─────────────────────────────────────────────────────
exports.updateMe = async (req, res, next) => {
    try {
        // Prevent updating email/password through this endpoint
        const { name, monthlyBudget, currency, avatarUrl, address, household, planPreferences, activePlan } = req.body;
        const updates = {};
        if (name !== undefined) updates.name = name;
        if (monthlyBudget !== undefined) updates.monthlyBudget = monthlyBudget;
        if (currency !== undefined) updates.currency = currency;
        if (avatarUrl !== undefined) updates.avatarUrl = avatarUrl;

        if (address !== undefined) {
            Object.keys(address).forEach(key => {
                updates[`address.${key}`] = address[key];
            });
        }

        if (household !== undefined) {
            Object.keys(household).forEach(key => {
                updates[`household.${key}`] = household[key];
            });
        }

        if (planPreferences !== undefined) updates.planPreferences = planPreferences;
        if (activePlan !== undefined) updates.activePlan = activePlan;

        const user = await User.findByIdAndUpdate(
            req.user.id,
            { $set: updates },
            { returnDocument: 'after', runValidators: true }
        );

        if (!user) throw new ApiError(404, 'User not found.');

        // If toPublicJSON is not defined, we'll fall back to toJSON or just the document
        return sendSuccess(res, 200, 'Profile updated.', typeof user.toPublicJSON === 'function' ? user.toPublicJSON() : user.toJSON());
    } catch (error) {
        next(error);
    }
};

// ─── PUT /api/v1/users/me/appliances ──────────────────────────────────────────
exports.updateAppliances = async (req, res, next) => {
    try {
        const { appliances } = req.body;

        if (!Array.isArray(appliances)) {
            throw new ApiError(400, 'Appliances must be an array.');
        }

        const user = await User.findByIdAndUpdate(
            req.user.id,
            { $set: { appliances, onboardingCompleted: true } },
            { returnDocument: 'after', runValidators: true }
        );

        if (!user) throw new ApiError(404, 'User not found.');

        return sendSuccess(res, 200, 'Appliances updated.', typeof user.toPublicJSON === 'function' ? user.toPublicJSON() : user.toJSON());
    } catch (error) {
        next(error);
    }
};
