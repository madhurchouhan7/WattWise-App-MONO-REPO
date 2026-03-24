jest.mock("../src/middleware/errorHandler", () => ({
  asyncHandler: (fn) => fn,
}));

jest.mock("../src/models/Appliance.model", () => ({
  findOneAndUpdate: jest.fn(),
}));

const applianceController = require("../src/controllers/appliance.controller");
const Appliance = require("../src/models/Appliance.model");

describe("Appliance Concurrency Contract (APP-04)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("stale patch updates must fail with 412 precondition for safe retry", async () => {
    Appliance.findOneAndUpdate.mockResolvedValue(null);

    const req = {
      params: { id: "a-1" },
      user: { _id: "user-1" },
      headers: { "if-match": "\"7\"" },
      body: {
        title: "AC Main Hall",
        _expectedVersion: 7,
      },
    };

    // RED-first contract: current code returns 404, but stale writes must become 412 in hardening phase.
    await expect(
      applianceController.updateAppliance(req, {}, jest.fn()),
    ).rejects.toMatchObject({
      statusCode: 412,
      message: expect.stringMatching(/precondition|stale|conflict/i),
    });
  });
});
