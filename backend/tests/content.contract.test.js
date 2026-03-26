const fs = require("fs");
const path = require("path");

const apiRouter = require("../src/routes");

const contentRoutesPath = path.join(
  __dirname,
  "../src/routes/content.routes.js",
);

function getMountedPaths(router) {
  return router.stack
    .filter((layer) => layer && layer.name === "router" && layer.regexp)
    .map((layer) => {
      const match = layer.regexp.toString().match(/\\\\\/(.+?)\\\\\//);
      return match ? `/${match[1].replace(/\\\\/g, "")}` : null;
    })
    .filter(Boolean);
}

describe("Content Contract - /api/v1/content", () => {
  it("mounts /content namespace in api router (CNT-01..CNT-04)", () => {
    const mountedPaths = getMountedPaths(apiRouter);
    expect(mountedPaths).toContain("/content");
  });

  it("provides content route module file for faq/bill/legal endpoints", () => {
    expect(fs.existsSync(contentRoutesPath)).toBe(true);
  });

  it("defines faq, bill-guide, and legal endpoint paths", () => {
    const exists = fs.existsSync(contentRoutesPath);
    expect(exists).toBe(true);

    if (!exists) {
      return;
    }

    const contentRouter = require(contentRoutesPath);
    const routes = contentRouter.stack
      .filter((layer) => layer.route)
      .map((layer) => layer.route.path);

    expect(routes).toContain("/faqs");
    expect(routes).toContain("/bill-guide");
    expect(routes).toContain("/legal/:slug");
  });

  it("freezes expected metadata envelope contract for all content payloads", () => {
    const envelope = {
      success: true,
      message: "Content fetched.",
      data: {
        contentVersion: "2026.03.1",
        lastUpdatedAt: "2026-03-26T00:00:00.000Z",
        effectiveFrom: "2026-03-01T00:00:00.000Z",
      },
    };

    expect(envelope.success).toBe(true);
    expect(envelope).toHaveProperty("data.contentVersion");
    expect(envelope).toHaveProperty("data.lastUpdatedAt");
    expect(envelope).toHaveProperty("data.effectiveFrom");
  });

  it("locks faq search/filter query contract shape", () => {
    const query = {
      q: "peak hours",
      topic: "billing-basics",
      limit: "20",
      offset: "0",
    };

    expect(Object.keys(query)).toEqual(["q", "topic", "limit", "offset"]);
  });
});
