function buildPlanResponseEnvelope({
  finalPlan,
  requestedMode,
  executionPath,
  requestId,
  qualityScore,
  debateRounds,
}) {
  return {
    finalPlan,
    metadata: {
      executionPath,
      requestedMode,
      requestId,
      orchestrationVersion: "v2-phase2",
      qualityScore: qualityScore ?? null,
      debateRounds: Number.isFinite(debateRounds) ? debateRounds : 0,
    },
  };
}

module.exports = {
  buildPlanResponseEnvelope,
};
