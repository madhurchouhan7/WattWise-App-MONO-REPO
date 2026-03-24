const { validate } = require("../src/middleware/validation.middleware");

const runApplianceValidation = async (body) => {
  const req = { id: "req-1", body };
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  };
  const next = jest.fn();

  await validate("updateAppliances")(req, res, next);

  return { req, res, next };
};

describe("Appliance Validation Contract", () => {
  it("returns details[] path for invalid usage hours", async () => {
    const { res, next } = await runApplianceValidation({
      appliances: [
        {
          applianceId: "ac-1",
          title: "Air Conditioner",
          category: "cooling",
          usageHours: 30,
          usageLevel: "High",
          count: 1,
          selectedDropdowns: {},
        },
      ],
    });

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);

    const payload = res.json.mock.calls[0][0];
    expect(payload.errorCode).toBe("VALIDATION_ERROR");
    expect(payload.details).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          path: "appliances.0.usageHours",
          message: expect.any(String),
        }),
      ]),
    );
  });

  it("returns deterministic validation envelope when appliances array is missing", async () => {
    const { res } = await runApplianceValidation({});
    const payload = res.json.mock.calls[0][0];

    expect(payload).toEqual(
      expect.objectContaining({
        success: false,
        message: "Validation failed",
        errorCode: "VALIDATION_ERROR",
        details: expect.any(Array),
      }),
    );
    expect(payload.details).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ path: "appliances" }),
      ]),
    );
  });
});
