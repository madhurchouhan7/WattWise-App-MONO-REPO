// src/controllers/ai.controller.js
// const { generateEfficiencyPlan } = require('../services/gemini.service'); // DEPRECATED
const { efficiencyPlanApp } = require('../agents/efficiency_plan/index');
const { sendSuccess } = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');

/**
 * @desc    Generate AI Efficiency Plan via Multi-Agent LangGraph Workflow
 * @route   POST /api/v1/ai/generate-plan
 * @access  Private
 */
const getEfficiencyPlan = async (req, res, next) => {
    try {
        const userData = req.body;

        if (!userData || Object.keys(userData).length === 0) {
            throw new ApiError(400, 'No user data provided. Send appliances, bill, and context.');
        }

        // 1. Fetch real-time weather data
        let weatherContext = "No live weather data provided.";
        const weatherApiKey = process.env.OPENWEATHER_API_KEY;
        const userLocation = userData.user?.location || "India";

        if (weatherApiKey) {
            try {
                // We use dynamic import for fetch since Node > 18 or node-fetch might be required
                const wRes = await fetch(
                    `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(userLocation)}&appid=${weatherApiKey}&units=metric`,
                );
                if (wRes.ok) {
                    const wData = await wRes.json();
                    weatherContext = `Temperature: ${wData.main.temp}°C, Conditions: ${wData.weather[0].description}, Humidity: ${wData.main.humidity}%`;
                } else {
                    console.warn(`[WeatherAPI] Fetch failed with status ${wRes.status}`);
                }
            } catch (error) {
                console.error(
                    "[WeatherAPI] Error fetching weather context:",
                    error.message,
                );
            }
        }

        // 2. Invoke LangGraph Workflow
        const initialState = {
            userData: userData,
            weatherContext: weatherContext
        };

        const resultState = await efficiencyPlanApp.invoke(initialState);
        const plan = resultState.finalPlan;

        if (!plan) {
             throw new ApiError(500, "Failed to generate AI plan via multi-agent workflow");
        }

        return sendSuccess(res, 200, 'Plan generated successfully.', plan);
    } catch (error) {
        console.error('AI Plan Generation Error:', error.message);
        next(error);
    }
};

module.exports = {
    getEfficiencyPlan,
};
