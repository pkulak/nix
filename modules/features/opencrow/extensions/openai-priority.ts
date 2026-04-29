import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event) => {
    const payload = event.payload;

    if (!isOpenAIResponsesPayload(payload)) {
      return;
    }

    return {
      ...payload,
      service_tier: "priority",
    };
  });
}

function isOpenAIResponsesPayload(payload: unknown): payload is Record<string, unknown> {
  return (
    typeof payload === "object" &&
    payload !== null &&
    "input" in payload &&
    "stream" in payload
  );
}
