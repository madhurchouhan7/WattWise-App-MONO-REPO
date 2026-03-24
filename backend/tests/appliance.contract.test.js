jest.mock("../src/middleware/errorHandler", () => ({
  asyncHandler: (fn) => fn,
}));

jest.mock("../src/utils/ApiResponse", () => ({
  sendSuccess: jest.fn(),
}));

jest.mock("../src/models/Appliance.model", () => ({
  create: jest.fn(),
  findOneAndUpdate: jest.fn(),
}));

const applianceController = require("../src/controllers/appliance.controller");
const Appliance = require("../src/models/Appliance.model");
const { sendSuccess } = require("../src/utils/ApiResponse");
const ApiError = require("../src/utils/ApiError");

describe("Appliance Contract - create/update/delete envelopes", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("returns deterministic success envelope for create", async () => {
    const created = {
      _id: "a-1",
      applianceId: "ac-1",
      title: "Air Conditioner",
      category: "cooling",
      usageLevel: "Medium",
      userId: "user-1",
    };

    Appliance.create.mockResolvedValue(created);

    const req = {
      body: {
        applianceId: "ac-1",
        title: "Air Conditioner",
        category: "cooling",
        usageLevel: "Medium",
      },
      user: { _id: "user-1" },
    };
    const res = {};

    await applianceController.createAppliance(req, res, jest.fn());

    expect(Appliance.create).toHaveBeenCalledWith(
      expect.objectContaining({
        applianceId: "ac-1",
        userId: "user-1",
      }),
    );
    expect(sendSuccess).toHaveBeenCalledWith(
      res,
      201,
      "Appliance created successfully.",
      created,
    );
  });

  it("returns deterministic success envelope for update", async () => {
    const updated = {
      _id: "a-1",
      applianceId: "ac-1",
      title: "AC Bedroom",
      userId: "user-1",
      isActive: true,
    };

    Appliance.findOneAndUpdate.mockResolvedValue(updated);

    const req = {
      params: { id: "a-1" },
      user: { _id: "user-1" },
      body: { title: "AC Bedroom" },
    };
    const res = {};

    await applianceController.updateAppliance(req, res, jest.fn());

    expect(Appliance.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: "a-1", userId: "user-1", isActive: true },
      expect.objectContaining({ title: "AC Bedroom", lastUpdated: expect.any(Date) }),
      { returnDocument: "after", runValidators: true },
    );
    expect(sendSuccess).toHaveBeenCalledWith(
      res,
      200,
      "Appliance updated successfully.",
      updated,
    );
  });

  it("returns deterministic success envelope for delete", async () => {
    Appliance.findOneAndUpdate.mockResolvedValue({ _id: "a-1" });

    const req = {
      params: { id: "a-1" },
      user: { _id: "user-1" },
    };
    const res = {};

    await applianceController.deleteAppliance(req, res, jest.fn());

    expect(sendSuccess).toHaveBeenCalledWith(
      res,
      200,
      "Appliance deleted successfully.",
    );
  });

  it("returns 404 ApiError when patch target appliance does not exist", async () => {
    Appliance.findOneAndUpdate.mockResolvedValue(null);

    const req = {
      params: { id: "missing-appliance" },
      user: { _id: "user-1" },
      body: { title: "Missing" },
    };

    await expect(
      applianceController.updateAppliance(req, {}, jest.fn()),
    ).rejects.toMatchObject({
      statusCode: 404,
      message: "Appliance not found.",
    });

    await expect(
      applianceController.updateAppliance(req, {}, jest.fn()),
    ).rejects.toBeInstanceOf(ApiError);
  });
});
