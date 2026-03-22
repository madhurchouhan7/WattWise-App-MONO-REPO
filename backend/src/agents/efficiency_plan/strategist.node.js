/**
 * Strategist Node (Powered by Grok-2)
 * Purpose: Takes anomalies and weather context to generate practical saving strategies.
 */
const { ChatOpenAI } = require("@langchain/openai");
const { getStrategistPrompt } = require("./strategist.prompt");

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

        if (process.env.XAI_API_KEY) {
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
            console.log("--> [Node] Strategist using mock fallback (no XAI_API_KEY found).");
            return {
                strategies: [
                    {
                        id: "mock_strategy_1",
                        actionSummary: "Delay Washing Machine to Off-Peak",
                        fullDescription: "Since it is sunny and dry, run your 8-hour load during mid-day solar peak hours or late night.",
                        projectedSavings: 450
                    }
                ]
            };
        }

    } catch (error) {
        console.error("Strategist Node Error:", error.message);
        // Fail gracefully with mock data
        return {
            strategies: [
                {
                    id: "mock_error_strategy",
                    actionSummary: "Optimize AC & Fan Usage",
                    fullDescription: "Raise AC temp to 25°C and use ceiling fan instead of running AC at 18°C.",
                    projectedSavings: 1250
                }
            ]
        };
    }
}

module.exports = { runStrategist };
