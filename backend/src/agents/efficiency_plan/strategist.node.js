/**
 * Strategist Node (Powered by Grok-2)
 * Purpose: Takes anomalies and weather context to generate practical saving strategies.
 */
const { ChatOpenAI } = require("@langchain/openai");
const { getStrategistPrompt } = require("./strategist.prompt");

function buildDefaultStrategies() {
    return [
        {
            id: "fallback_strategy_1",
            actionSummary: "Optimize AC + fan combination",
            fullDescription: "Set AC to 24-25C and use fan circulation to reduce compressor duty cycles.",
            projectedSavings: 450,
        },
        {
            id: "fallback_strategy_2",
            actionSummary: "Shift washer and heater usage",
            fullDescription: "Run washing machine and water heater during off-peak periods when possible.",
            projectedSavings: 300,
        },
        {
            id: "fallback_strategy_3",
            actionSummary: "Eliminate standby consumption",
            fullDescription: "Turn off idle entertainment devices, chargers, and kitchen plug loads nightly.",
            projectedSavings: 220,
        },
        {
            id: "fallback_strategy_4",
            actionSummary: "Cap daily high-load runtime",
            fullDescription: "Reduce one major appliance runtime by 15-20 minutes each day.",
            projectedSavings: 180,
        },
    ];
}

// Initialize LangChain OpenAI client specifically targeting x.ai API.
const llm = new ChatOpenAI({
    model: "x-ai/grok-4.1-fast",
    apiKey: process.env.OPENROUTER_API_KEY || "dummy",
    configuration: {
        baseURL: "https://openrouter.ai/api/v1"
    },
    temperature: 0.2, // Slight variance for creative strategy generation
});

async function runStrategist(state) {
    console.log("--> [Node] Strategist Executing");

    try {
        const systemMessage = getStrategistPrompt();

        // Construct the prompt context
        const contextString = `
Current Weather Context: ${state.weatherContext || "Unknown/Average Weather"}

User Appliances/Data: 
${JSON.stringify(state.userData?.appliances || state.userData, null, 2)}

Identified Anomalies from Analyst:
${state.anomalies && state.anomalies.length > 0 ? JSON.stringify(state.anomalies, null, 2) : "No severe physics anomalies detected. Generate proactive baseline savings strategies based on their appliances and weather context."}
`;
        const userMessage = {
            role: "user",
            content: contextString
        };

        if (process.env.OPENROUTER_API_KEY) {
            const response = await llm.invoke([systemMessage, userMessage]);

            // Basic JSON extraction and sanitization
            let rawJsonStr = response.content;
            if (rawJsonStr.startsWith("```json")) {
                rawJsonStr = rawJsonStr.replace(/```json\n?/g, "").replace(/```\n?/g, "");
            } else if (rawJsonStr.startsWith("```")) {
                rawJsonStr = rawJsonStr.replace(/```\n?/g, "");
            }

            const parsedStrategies = JSON.parse(rawJsonStr.trim());
            console.log(`--> [Node] Strategist completed. Generated ${parsedStrategies.length} strategies.`);

            return {
                strategies: parsedStrategies
            };
        } else {
            console.log("--> [Node] Strategist using mock fallback (no OPENROUTER_API_KEY found).");
            return {
                strategies: buildDefaultStrategies()
            };
        }

    } catch (error) {
        console.error("Strategist Node Error:", error.message);
        // Fail gracefully with mock data
        return {
            strategies: buildDefaultStrategies()
        };
    }
}

module.exports = { runStrategist };
