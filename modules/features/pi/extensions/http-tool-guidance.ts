import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const browserFirstGuidance = [
	"Use agent_browser for real browser or live web content.",
	"Prefer agent_browser over bash, osascript, AppleScript, or generic browser-driving shell for sites, docs, clicking, filling, screenshots, eval, and batch workflows.",
];

const browserSystemPrompt =
	"Project rule: when browser automation is needed, prefer the native `agent_browser` tool. Do not run direct `agent-browser` bash commands unless the user explicitly asks for a bash-oriented workflow or browser-integration debugging.";

export default function httpToolGuidance(pi: ExtensionAPI) {
	pi.on("before_agent_start", (event) => {
		const systemPrompt = event.systemPrompt
			.split("\n")
			.filter((line) => !browserFirstGuidance.some((guideline) => line.trim() === `- ${guideline}`))
			.join("\n")
			.replace(`\n\n${browserSystemPrompt}`, "");

		return { systemPrompt };
	});
}
