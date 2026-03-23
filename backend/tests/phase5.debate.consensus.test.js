const {
  runDebateAndConsensus,
} = require("../src/agents/efficiency_plan/shared/debateConsensus");

describe("phase5 debate consensus", () => {
  it("passes gate when weighted consensus quality is high", () => {
    const out = runDebateAndConsensus({
      reflections: [
        { role: "analyst", score: 92, approved: true, issues: [] },
        { role: "strategist", score: 90, approved: true, issues: [] },
        { role: "copywriter", score: 88, approved: true, issues: [] },
      ],
      validationIssues: [],
      challenges: [],
      maxRounds: 2,
      minQualityScore: 85,
    });

    expect(out.gatePassed).toBe(true);
    expect(out.finalQualityScore).toBeGreaterThanOrEqual(85);
    expect(out.consensusLog.length).toBeGreaterThan(0);
  });

  it("runs bounded rounds and fails gate when quality remains low", () => {
    const out = runDebateAndConsensus({
      reflections: [
        { role: "analyst", score: 40, approved: false, issues: ["a"] },
        { role: "strategist", score: 45, approved: false, issues: ["b"] },
        { role: "copywriter", score: 42, approved: false, issues: ["c"] },
      ],
      validationIssues: ["a", "b", "c", "d"],
      challenges: [{ type: "missing_evidence" }, { type: "coverage_gap" }],
      maxRounds: 2,
      minQualityScore: 85,
    });

    expect(out.gatePassed).toBe(false);
    expect(out.debateRounds).toBe(2);
    expect(out.consensusLog).toHaveLength(2);
  });
});