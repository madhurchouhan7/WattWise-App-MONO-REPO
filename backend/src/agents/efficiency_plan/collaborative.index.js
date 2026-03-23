/**
 * Additive collaborative entrypoint for Phase 2 dual-path routing.
 * This preserves invoke-compatibility without altering legacy graph exports.
 */
const collaborativePlanApp = {
  async invoke(initialState = {}) {
    const userData = initialState.userData || {};
    const summary = "Collaborative path scaffold is active for phased rollout.";

    return {
      userData,
      weatherContext: initialState.weatherContext || "",
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
    };
  },
};

module.exports = {
  collaborativePlanApp,
};
