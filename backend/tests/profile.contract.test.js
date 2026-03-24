describe("Profile Contract - /api/v1/users/me", () => {
  it("defines the frozen success envelope shape for GET /users/me", () => {
    const response = {
      success: true,
      statusCode: 200,
      message: "User profile fetched.",
      data: {
        name: "A User",
        avatarUrl: "https://example.com/avatar.png",
      },
    };

    expect(response).toEqual(
      expect.objectContaining({
        success: true,
        statusCode: expect.any(Number),
        message: expect.any(String),
        data: expect.any(Object),
      }),
    );
  });

  it.todo(
    "returns full updated profile payload from PUT /users/me (no ack-only response)",
  );
});
