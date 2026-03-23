const { z } = require("zod");

const MAX_REVISION_ATTEMPTS = 2;

const AnomalySchema = z.object({
  id: z.string().min(1),
  item: z.string().min(1),
  description: z.string().min(1),
  rupeeCostImpact: z.number().finite().nonnegative(),
});

const StrategySchema = z.object({
  id: z.string().min(1),
  actionSummary: z.string().min(1),
  fullDescription: z.string().min(1),
  projectedSavings: z.number().finite().nonnegative(),
});

const KeyActionSchema = z.object({
  action: z.string().min(1),
  impact: z.string().min(1),
  estimatedSaving: z.union([z.string(), z.number()]).optional(),
});

const FinalPlanSchema = z.object({
  planType: z.string().min(1),
  title: z.string().min(1),
  status: z.string().min(1),
  summary: z.string().min(1),
  keyActions: z.array(KeyActionSchema).min(1),
  quickWins: z.array(z.string()).optional(),
  monthlyTip: z.string().optional(),
});

function parseEstimatedSaving(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string") {
    const normalized = value.replace(/[^0-9.-]/g, "");
    const parsed = Number(normalized);
    return Number.isFinite(parsed) ? parsed : 0;
  }

  return 0;
}

function normalizeAnomalies(input = []) {
  const list = Array.isArray(input) ? input : [];
  const normalized = list
    .map((item, index) => ({
      id: String(item?.id || `anomaly_${index + 1}`),
      item: String(item?.item || "General Usage"),
      description: String(
        item?.description || "Detected unusual consumption pattern.",
      ),
      rupeeCostImpact: Number.isFinite(Number(item?.rupeeCostImpact))
        ? Math.max(0, Number(item.rupeeCostImpact))
        : 0,
    }))
    .filter((item) => item.id && item.item && item.description);

  if (normalized.length > 0) {
    return normalized;
  }

  return [
    {
      id: "baseline_anomaly",
      item: "General Household Load",
      description: "Baseline anomaly generated due to missing analyst output.",
      rupeeCostImpact: 150,
    },
  ];
}

function normalizeStrategies(input = [], anomalies = []) {
  const anomalyBudget = Math.max(
    1,
    normalizeAnomalies(anomalies).reduce(
      (sum, item) => sum + item.rupeeCostImpact,
      0,
    ),
  );

  const list = Array.isArray(input) ? input : [];
  const normalized = list
    .map((item, index) => ({
      id: String(item?.id || `strategy_${index + 1}`),
      actionSummary: String(
        item?.actionSummary || "Reduce non-essential runtime",
      ),
      fullDescription: String(
        item?.fullDescription ||
          "Shift high-consumption usage to shorter windows and avoid idle loads.",
      ),
      projectedSavings: Number.isFinite(Number(item?.projectedSavings))
        ? Math.max(0, Number(item.projectedSavings))
        : 0,
    }))
    .filter((item) => item.actionSummary.length > 0);

  if (normalized.length === 0) {
    return [
      {
        id: "baseline_strategy",
        actionSummary: "Trim standby and idle consumption",
        fullDescription:
          "Switch off idle appliances and avoid extended standby behavior.",
        projectedSavings: Math.round(anomalyBudget * 0.25),
      },
    ];
  }

  return normalized.map((item) => ({
    ...item,
    projectedSavings: Math.min(item.projectedSavings, anomalyBudget * 1.2),
  }));
}

function buildFallbackFinalPlan(strategies = []) {
  const safeStrategies = normalizeStrategies(strategies, []);
  const rupees = safeStrategies.reduce(
    (sum, item) => sum + item.projectedSavings,
    0,
  );

  return {
    planType: "efficiency",
    title: "Collaborative Efficiency Plan",
    status: "draft",
    summary: "This plan was generated with validated specialist outputs.",
    estimatedCurrentMonthlyCost: 0,
    estimatedSavingsIfFollowed: {
      units: 0,
      rupees,
      percentage: 0,
    },
    efficiencyScore: null,
    keyActions: safeStrategies.map((item) => ({
      priority: "high",
      appliance: "General Household",
      action: item.actionSummary,
      impact: item.fullDescription,
      estimatedSaving: item.projectedSavings,
    })),
    slabAlert: {
      isInDangerZone: false,
      currentSlab: "unknown",
      warning: "",
    },
    quickWins: ["Use shorter appliance cycles", "Avoid idle standby loads"],
    monthlyTip: "Review your highest runtime appliance weekly.",
  };
}

function validateAnomalies(anomalies = []) {
  const parsed = z.array(AnomalySchema).safeParse(anomalies);
  if (parsed.success) {
    return { ok: true, issues: [] };
  }

  return {
    ok: false,
    issues: parsed.error.issues.map(
      (issue) => `analyst:${issue.path.join(".")}:${issue.message}`,
    ),
  };
}

function validateStrategies(strategies = []) {
  const parsed = z.array(StrategySchema).safeParse(strategies);
  if (parsed.success) {
    return { ok: true, issues: [] };
  }

  return {
    ok: false,
    issues: parsed.error.issues.map(
      (issue) => `strategist:${issue.path.join(".")}:${issue.message}`,
    ),
  };
}

function validateFinalPlan(finalPlan = {}) {
  const parsed = FinalPlanSchema.safeParse(finalPlan);
  if (!parsed.success) {
    return {
      ok: false,
      issues: parsed.error.issues.map(
        (issue) => `copywriter:${issue.path.join(".")}:${issue.message}`,
      ),
    };
  }

  return { ok: true, issues: [] };
}

function detectHallucinationRisks(
  anomalies = [],
  strategies = [],
  finalPlan = null,
) {
  const normalizedAnomalies = normalizeAnomalies(anomalies);
  const anomalyBudget = normalizedAnomalies.reduce(
    (sum, item) => sum + item.rupeeCostImpact,
    0,
  );
  const strategySavings = normalizeStrategies(
    strategies,
    normalizedAnomalies,
  ).reduce((sum, item) => sum + item.projectedSavings, 0);

  const risks = [];
  if (strategySavings > anomalyBudget * 1.8) {
    risks.push(
      `qa:projectedSavings_excess:${strategySavings} exceeds expected ceiling for anomaly budget ${anomalyBudget}`,
    );
  }

  if (finalPlan && Array.isArray(finalPlan.keyActions)) {
    const planSavings = finalPlan.keyActions.reduce(
      (sum, action) => sum + parseEstimatedSaving(action.estimatedSaving),
      0,
    );

    if (planSavings > Math.max(strategySavings * 1.8, 1)) {
      risks.push(
        `qa:keyActionSavings_excess:${planSavings} exceeds strategy savings envelope ${strategySavings}`,
      );
    }
  }

  return risks;
}

function buildCrossAgentChallenges(
  anomalies = [],
  strategies = [],
  finalPlan = null,
) {
  const challenges = [];

  if (
    Array.isArray(strategies) &&
    strategies.length > 0 &&
    (!Array.isArray(anomalies) || anomalies.length === 0)
  ) {
    challenges.push({
      source: "strategist",
      target: "analyst",
      type: "missing_evidence",
      reason: "Strategies were generated without anomaly evidence.",
    });
  }

  if (
    finalPlan &&
    Array.isArray(finalPlan.keyActions) &&
    finalPlan.keyActions.length < (strategies || []).length
  ) {
    challenges.push({
      source: "copywriter",
      target: "strategist",
      type: "coverage_gap",
      reason:
        "Some strategist outputs were not represented in final keyActions.",
    });
  }

  return challenges;
}

function buildReflection(role, issues = [], challenges = []) {
  const issuePenalty = Math.min(60, issues.length * 20);
  const challengePenalty = Math.min(25, challenges.length * 5);
  const score = Math.max(0, 100 - issuePenalty - challengePenalty);

  return {
    role,
    approved: issues.length === 0,
    score,
    issues,
    challengeCount: challenges.length,
    reviewedAt: new Date().toISOString(),
  };
}

module.exports = {
  MAX_REVISION_ATTEMPTS,
  buildCrossAgentChallenges,
  buildFallbackFinalPlan,
  buildReflection,
  detectHallucinationRisks,
  normalizeAnomalies,
  normalizeStrategies,
  validateAnomalies,
  validateStrategies,
  validateFinalPlan,
};
