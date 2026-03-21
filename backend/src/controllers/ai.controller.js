// src/controllers/ai.controller.js
const { generateEfficiencyPlan } = require('../services/gemini.service');
const { sendSuccess } = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');

/**
 * @desc    Generate AI Efficiency Plan via Gemini
 * @route   POST /api/v1/ai/generate-plan
 * @access  Private
 */
const getEfficiencyPlan = async (req, res, next) => {
    try {
        const userData = req.body;

        if (!userData || Object.keys(userData).length === 0) {
            throw new ApiError(400, 'No user data provided. Send appliances, bill, and context.');
        }

        // Call Gemini Service
        const plan = await generateEfficiencyPlan(userData);

        return sendSuccess(res, 200, 'Plan generated.', plan);
    } catch (error) {
        console.error('AI Plan Generation Error:', error.message);
        next(error);
    }
};

module.exports = {
    getEfficiencyPlan,
};
