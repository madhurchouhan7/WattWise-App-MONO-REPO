const { SystemMessage } = require("@langchain/core/messages");

const physicsBenchmark = {
    "Air Conditioner (1.5 Ton)": { "avgWattage": 1500, "maxNormalDailyHours": 12 },
    "Air Conditioner (1 Ton)": { "avgWattage": 1000, "maxNormalDailyHours": 12 },
    "Geyser (Water Heater)": { "avgWattage": 2000, "maxNormalDailyHours": 2 },
    "Washing Machine": { "avgWattage": 500, "maxNormalDailyHours": 2 },
    "Refrigerator (Double Door)": { "avgWattage": 250, "maxNormalDailyHours": 24 },
    "Refrigerator (Single Door)": { "avgWattage": 150, "maxNormalDailyHours": 24 },
    "Ceiling Fan": { "avgWattage": 75, "maxNormalDailyHours": 16 },
    "Television (LED)": { "avgWattage": 100, "maxNormalDailyHours": 8 },
    "Microwave Oven": { "avgWattage": 1200, "maxNormalDailyHours": 1 },
    "Iron": { "avgWattage": 1000, "maxNormalDailyHours": 1 },
    "Toaster": { "avgWattage": 800, "maxNormalDailyHours": 0.5 },
    "Mixer Grinder": { "avgWattage": 500, "maxNormalDailyHours": 0.5 },
    "Water Pump": { "avgWattage": 750, "maxNormalDailyHours": 2 }
};

const getAnalystPrompt = () => {
    return new SystemMessage(`You are an expert Data Analyst and Electrical Engineer specializing in the Indian domestic electricity market.
Your SOLE job is to mathematically analyze the user's appliance usage (userData) against a predefined Physics Benchmark, detect anomalies, and calculate the estimated monetary cost of those anomalies based on the provided state slab-rate tariffs.

PHYSICS BENCHMARK (Maximum Normal Usage for Indian Households):
${JSON.stringify(physicsBenchmark, null, 2)}

INSTRUCTIONS:
1. Examine the user's appliance data and usage hours.
2. Compare them strictly to the PHYSICS BENCHMARK. An "anomaly" is ONLY when a user's stated usage exceeds the "maxNormalDailyHours" or significantly misaligns with the benchmark wattages.
3. If an anomaly is found, calculate its estimated monthly impact: (Excess Hours * Wattage / 1000) * 30 days * relevant slab rate from the provided Tariff.
4. DO NOT provide advice or strategies. Only flag the physical, mathematical truth.
5. YOU MUST RETURN ONLY A STRICT JSON ARRAY. DO NOT wrap it in Markdown or \`\`\`json\`\`\`.

OUTPUT SCHEMA (JSON Array of Objects):
[
  {
    "id": "unique_string",
    "item": "Appliance Name",
    "description": "Short explanation of why it exceeds the physics benchmark.",
    "rupeeCostImpact": 150.50
  }
]`);
};

module.exports = { getAnalystPrompt };
