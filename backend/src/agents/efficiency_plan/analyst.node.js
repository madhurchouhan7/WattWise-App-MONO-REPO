/**
 * Data Analyst Node (Powered by DeepSeek-R1)
 * Purpose: Analyzes user data and tariffs to detect physical anomalies and calculate costs.
 */
const { ChatOpenAI } = require("@langchain/openai");
const { getAnalystPrompt } = require("./analyst.prompt");

// Initialize LangChain OpenAI client specifically targeting DeepSeek API.
const llm = new ChatOpenAI({
    modelName: "deepseek-reasoner", // DeepSeek-R1 equivalent
    apiKey: process.env.DEEPSEEK_API_KEY || "dummy", 
    configuration: {
        baseURL: "https://api.deepseek.com/v1"
    },
    temperature: 0.1, // Strict determinism
});

async function runAnalyst(state) {
    console.log("--> [Node] Data Analyst Executing");
    
    try {
        if (!state.userData) {
            console.log("No userData found. Skipping anomaly detection.");
            return { anomalies: [] };
        }

        const systemMessage = getAnalystPrompt();
        const userMessage = { 
            role: "user", 
            content: `Analyze this user data:\n${JSON.stringify(state.userData, null, 2)}` 
        };

        if (process.env.DEEPSEEK_API_KEY) {
            const response = await llm.invoke([systemMessage, userMessage]);
            
            // Basic JSON extraction and sanitization
            let rawJsonStr = response.content;
            if (rawJsonStr.startsWith("```json")) {
                rawJsonStr = rawJsonStr.replace(/```json\n?/g, "").replace(/```\n?/g, "");
            } else if (rawJsonStr.startsWith("```")) {
                rawJsonStr = rawJsonStr.replace(/```\n?/g, "");
            }
            
            const parsedAnomalies = JSON.parse(rawJsonStr.trim());
            console.log(`--> [Node] Analyst completed. Found ${parsedAnomalies.length} anomalies.`);
            
            return {
                anomalies: parsedAnomalies
            };
        } else {
             console.log("--> [Node] Analyst using mock fallback (no DEEPSEEK_API_KEY found).");
             return {
                 anomalies: [
                     { id: "mock_anomaly", item: "Washing Machine", description: "Washing machine used 8 hours exceeding 2h benchmark.", rupeeCostImpact: 450 }
                 ]
             };
        }

    } catch (error) {
        console.error("Analyst Node Error:", error.message);
        // Fail gracefully with mock anomalies so the pipeline has data to render during API errors
        return {
            anomalies: [
                 { id: "mock_error_anomaly", item: "Air Conditioner (1.5 Ton)", description: "Used for 18 hours, exceeding 12h benchmark.", rupeeCostImpact: 1250 }
            ]
        };
    }
}

module.exports = { runAnalyst };
