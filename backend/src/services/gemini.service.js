// src/services/gemini.service.js
const { GoogleGenerativeAI, SchemaType } = require("@google/generative-ai");

// Determine API key
const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
    console.warn("⚠️ GEMINI_API_KEY is not set in environment variables! AI features will fail.");
}

const genAI = new GoogleGenerativeAI(apiKey || 'placeholder');

const generateEfficiencyPlan = async (userData) => {
    const userGoal = userData.user?.goal || "reduce_bill";
    const userFocus = userData.user?.focusArea || "ai_decide";
    const userLocation = userData.user?.location || "India";
    const appliances = userData.appliances || [];
    const bill = userData.bill || {};

    // Fetch real-time weather data
    let weatherContext = "No live weather data provided.";
    const weatherApiKey = process.env.OPENWEATHER_API_KEY;

    if (weatherApiKey) {
        try {
            const wRes = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(userLocation)}&appid=${weatherApiKey}&units=metric`);
            if (wRes.ok) {
                const wData = await wRes.json();
                weatherContext = `Temperature: ${wData.main.temp}°C, Conditions: ${wData.weather[0].description}, Humidity: ${wData.main.humidity}%`;
            } else {
                console.warn(`[WeatherAPI] Fetch failed with status ${wRes.status}`);
            }
        } catch (error) {
            console.error("[WeatherAPI] Error fetching weather context:", error.message);
        }
    }

    // Build the prompt
    let prompt = `You are an expert energy efficiency advisor for Indian households.
Analyze the following electricity usage data and generate a personalized efficiency plan.

USER CONTEXT:
- Goal: ${userGoal}
- Focus Area: ${userFocus}
- Location: ${userLocation}
- Live Weather: ${weatherContext}
- WEATHER INSTRUCTION: Extensively adjust your device recommendations, baseline temperatures, and action items structurally around the live weather context so your advice is logically applicable right now.

APPLIANCES:
`;

    if (appliances.length === 0) {
        prompt += `- No specific appliances recorded.\n`;
    } else {
        appliances.forEach(app => {
            prompt += `- ${app.count}x ${app.name} (${app.wattage || 'unknown '}W, ${app.starRating || 'unknown star'}, ${app.usageHoursPerDay || 'unknown'} hrs/day, Level: ${app.usageLevel || 'unknown'})\n`;
        });
    }

    if (bill.month) {
        prompt += `
LAST BILL:
- Month: ${bill.month}
- Units Consumed: ${bill.unitsConsumed} kWh
- Total Amount: ₹${bill.totalAmount}
`;
    } else {
        prompt += `
LAST BILL:
- No previous bill data provided. Estimate averages based on standard appliances.
`;
    }

    prompt += `
TASK:
Respond ONLY with a valid JSON object matching the requested schema.
Be specific, practical, and quantify savings wherever possible.
Base calculations on standard Indian electricity rates and BEE star ratings.
`;

    const schema = {
        type: SchemaType.OBJECT,
        properties: {
            summary: {
                type: SchemaType.STRING,
                description: "2-3 sentence plain English summary"
            },
            estimatedCurrentMonthlyCost: {
                type: SchemaType.NUMBER
            },
            estimatedSavingsIfFollowed: {
                type: SchemaType.OBJECT,
                properties: {
                    units: { type: SchemaType.NUMBER },
                    rupees: { type: SchemaType.NUMBER },
                    percentage: { type: SchemaType.NUMBER }
                },
                required: ["units", "rupees", "percentage"]
            },
            efficiencyScore: {
                type: SchemaType.NUMBER,
                description: "0-100, current score"
            },
            keyActions: {
                type: SchemaType.ARRAY,
                items: {
                    type: SchemaType.OBJECT,
                    properties: {
                        priority: { type: SchemaType.STRING, description: "high|medium|low" },
                        appliance: { type: SchemaType.STRING },
                        action: { type: SchemaType.STRING, description: "what to do" },
                        impact: { type: SchemaType.STRING, description: "why it helps" },
                        estimatedSaving: { type: SchemaType.STRING, description: "e.g. ₹120/month" }
                    },
                    required: ["priority", "appliance", "action", "impact", "estimatedSaving"]
                }
            },
            slabAlert: {
                type: SchemaType.OBJECT,
                properties: {
                    isInDangerZone: { type: SchemaType.BOOLEAN },
                    currentSlab: { type: SchemaType.STRING },
                    nextSlabAt: { type: SchemaType.NUMBER, nullable: true },
                    unitsToNextSlab: { type: SchemaType.NUMBER, nullable: true },
                    warning: { type: SchemaType.STRING, nullable: true, description: "warning or null if safe" }
                },
                required: ["isInDangerZone", "currentSlab"]
            },
            quickWins: {
                type: SchemaType.ARRAY,
                items: { type: SchemaType.STRING }
            },
            monthlyTip: {
                type: SchemaType.STRING,
                description: "one seasonal/contextual tip"
            }
        },
        required: [
            "summary", "estimatedCurrentMonthlyCost", "estimatedSavingsIfFollowed",
            "efficiencyScore", "keyActions", "slabAlert", "quickWins", "monthlyTip"
        ]
    };

    const model = genAI.getGenerativeModel({
        model: "gemini-2.5-flash",
        generationConfig: {
            responseMimeType: "application/json",
            responseSchema: schema,
        }
    });

    try {
        const result = await model.generateContent(prompt);
        const jsonResponse = result.response.text();
        return JSON.parse(jsonResponse);
    } catch (err) {
        console.error("Gemini AI API Error:", err);
        throw new Error("Failed to generate Efficiency Plan from Gemini.");
    }
};

module.exports = {
    generateEfficiencyPlan
};
