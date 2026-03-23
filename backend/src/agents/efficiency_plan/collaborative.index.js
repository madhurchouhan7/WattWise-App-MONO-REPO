/**
 * Additive collaborative entrypoint for Phase 2 dual-path routing.
 * This preserves invoke-compatibility without altering legacy graph exports.
 */
const ApiError = require("../../utils/ApiError");
const memoryService = require("./shared/memoryService");
const { composeAgentContext } = require("./shared/retrievalPlanner");
const loggingMiddleware = require("../../middleware/logging.middleware");
const { runAnalyst } = require("./analyst.node");
const { runStrategist } = require("./strategist.node");
const { runCopywriter } = require("./copywriter.node");
const {
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
} = require("./shared/phase4Contracts");

const collaborativePlanApp = {
  async invoke(initialState = {}) {
    const userData = initialState.userData || {};
    const memoryMeta = initialState.memoryMeta || {};
    const identity = {
      tenantId: memoryMeta.tenantId,
      userId: memoryMeta.userId,
      threadId: memoryMeta.threadId,
    };

    if (!identity.tenantId || !identity.userId || !identity.threadId) {
      throw new ApiError(
        400,
        "Missing required memory identity keys for collaborative mode: tenantId, userId, threadId",
      );
    }

    const recentEvents = await memoryService.getRecent(identity, { limit: 12 });
    const historicalEvents = await memoryService.getHistorical(
      identity,
      memoryMeta.query || "",
      {
        maxItems: 100,
      },
    );
    const composed = composeAgentContext({
      recentEvents,
      historicalEvents,
      query: memoryMeta.query || "",
      tokenBudget: memoryMeta.tokenBudget || 6000,
    });

    loggingMiddleware.logMemoryEvent({
      eventType: "memory_read",
      scope: `${identity.tenantId}:${identity.userId}:${identity.threadId}`,
      requestId: memoryMeta.requestId,
      runId: memoryMeta.runId,
      threadId: identity.threadId,
      tokenBudgetUsed: composed.tokenUsage,
      usedFallback: composed.usedFallback,
    });

    let revisionCount = 0;

    const analystOut = await runAnalyst({
      ...initialState,
      memoryContext: composed.contextEvents,
    });
    let anomalies = normalizeAnomalies(analystOut?.anomalies || []);
    let analystValidation = validateAnomalies(anomalies);

    while (!analystValidation.ok && revisionCount < MAX_REVISION_ATTEMPTS) {
      anomalies = normalizeAnomalies(anomalies);
      analystValidation = validateAnomalies(anomalies);
      revisionCount += 1;
    }

    const strategistOut = await runStrategist({
      ...initialState,
      anomalies,
      memoryContext: composed.contextEvents,
    });
    let strategies = normalizeStrategies(strategistOut?.strategies || [], anomalies);
    let strategistValidation = validateStrategies(strategies);

    while (!strategistValidation.ok && revisionCount < MAX_REVISION_ATTEMPTS) {
      strategies = normalizeStrategies(strategies, anomalies);
      strategistValidation = validateStrategies(strategies);
      revisionCount += 1;
    }

    const copywriterOut = await runCopywriter({
      ...initialState,
      anomalies,
      strategies,
      memoryContext: composed.contextEvents,
    });

    let finalPlan = copywriterOut?.finalPlan || buildFallbackFinalPlan(strategies);
    let copywriterValidation = validateFinalPlan(finalPlan);

    if (!copywriterValidation.ok && revisionCount < MAX_REVISION_ATTEMPTS) {
      finalPlan = buildFallbackFinalPlan(strategies);
      copywriterValidation = validateFinalPlan(finalPlan);
      revisionCount += 1;
    }

    const hallucinationRisks = detectHallucinationRisks(anomalies, strategies, finalPlan);
    const challenges = buildCrossAgentChallenges(anomalies, strategies, finalPlan);
    const validationIssues = [
      ...analystValidation.issues,
      ...strategistValidation.issues,
      ...copywriterValidation.issues,
      ...hallucinationRisks,
    ];

    const analystReflection = buildReflection("analyst", analystValidation.issues, challenges);
    const strategistReflection = buildReflection(
      "strategist",
      [...strategistValidation.issues, ...hallucinationRisks],
      challenges,
    );
    const copywriterReflection = buildReflection("copywriter", copywriterValidation.issues, challenges);
    const reflections = [analystReflection, strategistReflection, copywriterReflection];

    const qualityScore = Math.round(
      reflections.reduce((sum, item) => sum + item.score, 0) / Math.max(reflections.length, 1),
    );

    const summary = finalPlan?.summary || "Collaborative plan generated with reflection and validation gates.";

    const memoryEvent = await memoryService.writeEvent({
      ...identity,
      eventType: "agent_turn",
      agentId: "collaborative-orchestrator",
      timestamp: new Date().toISOString(),
      sourceType: "llm",
      evidenceRefs: [{ id: "context:collaborative", type: "context" }],
      revisionId: `rev-${Date.now()}`,
      confidenceScore: 0.8,
      requestId: memoryMeta.requestId,
      runId: memoryMeta.runId,
      payload: {
        summary,
        mode: "collaborative",
        userData,
        anomaliesCount: anomalies.length,
        strategiesCount: strategies.length,
        revisionCount,
        qualityScore,
        validationIssues,
      },
    });

    loggingMiddleware.logMemoryEvent({
      eventType: "memory_write",
      scope: `${identity.tenantId}:${identity.userId}:${identity.threadId}`,
      revisionId: memoryEvent.revisionId,
      requestId: memoryMeta.requestId,
      runId: memoryMeta.runId,
      threadId: identity.threadId,
      tokenBudgetUsed: composed.tokenUsage,
      usedFallback: composed.usedFallback,
    });

    return {
      userData,
      weatherContext: initialState.weatherContext || "",
      memoryContext: composed.contextEvents,
      memoryEventRefs: [memoryEvent.revisionId],
      anomalies,
      strategies,
      finalPlan,
      agentReflections: reflections,
      validationIssues,
      crossAgentChallenges: challenges,
      revisionCount,
      qualityScore,
      debateRounds: 0,
      runId: memoryMeta.runId,
      threadId: identity.threadId,
    };
  },
};

module.exports = {
  collaborativePlanApp,
};
