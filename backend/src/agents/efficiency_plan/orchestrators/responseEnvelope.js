function buildPlanResponseEnvelope({
  finalPlan,
  requestedMode,
  executionPath,
  requestId,
  runId,
  threadId,
  qualityScore,
  debateRounds,
  revisionCount,
  validationIssueCount,
  challengeCount,
  roleRetryBudgets,
  qualityGate,
  consensusRoundCount,
  consensusRationale,
  safeFallbackActivated,
}) {
  const metadata = {
    executionPath,
    requestedMode,
    requestId,
    orchestrationVersion: "v2-phase2",
    qualityScore: qualityScore ?? null,
    debateRounds: Number.isFinite(debateRounds) ? debateRounds : 0,
  };

  if (requestId || runId || threadId) {
    metadata.memoryTrace = {
      requestId: requestId || null,
      runId: runId || null,
      threadId: threadId || null,
    };
  }

  if (
    Number.isFinite(revisionCount) ||
    Number.isFinite(validationIssueCount) ||
    Number.isFinite(challengeCount)
  ) {
    metadata.phase4 = {
      revisionCount: Number.isFinite(revisionCount) ? revisionCount : 0,
      validationIssueCount: Number.isFinite(validationIssueCount)
        ? validationIssueCount
        : 0,
      challengeCount: Number.isFinite(challengeCount) ? challengeCount : 0,
      roleRetryBudgets:
        roleRetryBudgets && typeof roleRetryBudgets === "object"
          ? roleRetryBudgets
          : {
              analyst: 0,
              strategist: 0,
              copywriter: 0,
              challengeRouting: 0,
            },
    };
  }

  if (qualityGate || Number.isFinite(consensusRoundCount)) {
    metadata.phase5 = {
      qualityGate:
        qualityGate && typeof qualityGate === "object"
          ? qualityGate
          : { minScore: 85, passed: false },
      consensusRoundCount: Number.isFinite(consensusRoundCount)
        ? consensusRoundCount
        : 0,
      consensusRationale: Array.isArray(consensusRationale)
        ? consensusRationale
        : [],
      safeFallbackActivated: Boolean(safeFallbackActivated),
    };
  }

  return {
    finalPlan,
    metadata,
  };
}

module.exports = {
  buildPlanResponseEnvelope,
};
