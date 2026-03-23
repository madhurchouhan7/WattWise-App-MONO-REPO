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
