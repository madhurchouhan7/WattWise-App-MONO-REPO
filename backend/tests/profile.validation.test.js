describe("Profile Validation Contract - /api/v1/users/me", () => {
  it("defines normalized error envelope for invalid profile payloads", () => {
    const error = {
      success: false,
      statusCode: 400,
      message: "Validation failed",
      errors: [
        {
          field: "name",
          code: "INVALID_VALUE",
          message: "Name must be at least 2 characters",
        },
      ],
    };

    expect(error).toEqual(
      expect.objectContaining({
        success: false,
        statusCode: 400,
        message: expect.any(String),
        errors: expect.any(Array),
      }),
    );
    expect(error.errors[0]).toEqual(
      expect.objectContaining({
        field: expect.any(String),
        code: expect.any(String),
        message: expect.any(String),
      }),
    );
  });

  it.todo(
    "maps backend validation errors to inline field paths for profile save UI",
  );
});
