const core = require("@actions/core");

const { revdeps } = JSON.parse(core.getInput("collected_revdeps"));

const resultHash = Object.keys(revdeps).reduce(
  (result, key) =>
    revdeps[key].reduce((result, key) => ({ ...result, [key]: true }), result),
  {},
);
const result = Object.keys(resultHash);

console.log(`Collected ${result.length} revdeps: ${result}`);

core.setOutput("revdeps", JSON.stringify(result));
core.setOutput("has_revdeps", result.length !== 0 ? "true" : "false");
