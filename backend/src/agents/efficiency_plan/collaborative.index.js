/**
 * Additive collaborative entrypoint for Phase 2 dual-path routing.
 * This preserves invoke-compatibility without altering legacy graph exports.
 */
const ApiError = require("../../utils/ApiError");
const memoryService = require("./shared/memoryService");
const { composeAgentContext } = require("./shared/retrievalPlanner");
const loggingMiddleware = require("../../middleware/logging.middleware");

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

    const summary = "Collaborative path scaffold is active for phased rollout.";

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
      anomalies: [],
      strategies: [],
      finalPlan: {
        planType: "efficiency",
        title: "Collaborative Efficiency Plan (Phase 2 Scaffold)",
        status: "draft",
        summary,
        estimatedCurrentMonthlyCost: 0,
        estimatedSavingsIfFollowed: {
          units: 0,
          rupees: 0,
          percentage: 0,
        },
        efficiencyScore: null,
        keyActions: [],
        slabAlert: {
          isInDangerZone: false,
          currentSlab: "unknown",
          warning: "",
        },
        quickWins: [],
        monthlyTip: "",
      },
      qualityScore: null,
      debateRounds: 0,
      runId: memoryMeta.runId,
      threadId: identity.threadId,
    };
  },
};

module.exports = {
  collaborativePlanApp,
};
