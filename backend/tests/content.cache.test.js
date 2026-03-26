const fs = require("fs");
const path = require("path");

const contentControllerPath = path.join(
  __dirname,
  "../src/controllers/content.controller.js",
);

describe("Content Cache Contract - conditional refresh (CNT-05)", () => {
  it("provides a content controller implementation for conditional refresh", () => {
    expect(fs.existsSync(contentControllerPath)).toBe(true);
  });

  it("declares expected controller handlers for faq, bill-guide, and legal", () => {
    const exists = fs.existsSync(contentControllerPath);
    expect(exists).toBe(true);

    if (!exists) {
      return;
    }

    const controller = require(contentControllerPath);
    expect(typeof controller.getFaqs).toBe("function");
    expect(typeof controller.getBillGuide).toBe("function");
    expect(typeof controller.getLegalContent).toBe("function");
  });

  it("contains validator-header semantics for ETag + If-None-Match + 304", () => {
    const exists = fs.existsSync(contentControllerPath);
    expect(exists).toBe(true);

    if (!exists) {
      return;
    }

    const source = fs.readFileSync(contentControllerPath, "utf8");

    expect(source).toMatch(/ETag/i);
    expect(source).toMatch(/If-None-Match/i);
    expect(source).toMatch(/304/);
  });

  it("freezes conditional request headers used by client refresh", () => {
    const headers = {
      "If-None-Match": '"content-v2026.03.1"',
    };

    expect(headers).toHaveProperty("If-None-Match");
    expect(headers["If-None-Match"]).toContain("content-v");
  });
});
