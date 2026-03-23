function buildPlanResponseEnvelope({
  finalPlan,
  requestedMode,
  executionPath,
  requestId,
  runId,
  threadId,
  qualityScore,
  debateRounds,
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

  return {
    finalPlan,
    metadata,
  };
}

module.exports = {
  buildPlanResponseEnvelope,
};
