const ApiError = require("../../../utils/ApiError");

const ALLOWED_MODES = ["legacy", "collaborative"];

function hasDisallowedModeInputs(req) {
  const body = req && req.body ? req.body : {};
  const query = req && req.query ? req.query : {};

  return (
    body.aiMode !== undefined ||
    body.mode !== undefined ||
    query.aiMode !== undefined ||
    query.mode !== undefined
  );
}

function readHeaderMode(req) {
  if (!req || typeof req.get !== "function") {
    return undefined;
  }

  const mode = req.get("x-ai-mode");
  if (mode === undefined || mode === null || mode === "") {
    return undefined;
  }

  return String(mode).trim().toLowerCase();
}

function resolveOrchestrationMode(req, options = {}) {
  if (hasDisallowedModeInputs(req)) {
    throw new ApiError(
      400,
      "Mode must be provided only via x-ai-mode header. Body/query mode fields are not allowed in this phase."
    );
  }

  const headerMode = readHeaderMode(req);

  if (headerMode !== undefined && !ALLOWED_MODES.includes(headerMode)) {
    throw new ApiError(400, "Invalid x-ai-mode. Allowed values: legacy, collaborative");
  }

  const nodeEnv = (options.nodeEnv || process.env.NODE_ENV || "development").toLowerCase();
  const defaultMode = nodeEnv === "production" ? "legacy" : "collaborative";
  const selectedMode = headerMode || defaultMode;

  return {
    requestedMode: selectedMode,
    executionPath: selectedMode,
  };
}

module.exports = {
  resolveOrchestrationMode,
};
