import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function autoNameSession(pi: ExtensionAPI) {
	pi.registerTool({
		name: "set_session_name",
		label: "Name Session",
		description: "Set or update the concise display name for the current session",
		promptSnippet: "Name the current session once the user's actual task is clear, and rename it if the focus changes",
		promptGuidelines: [
			"Use set_session_name near the beginning of every unnamed session, after the user's actual task is clear. Do not call set_session_name for /setup or other bootstrap prompts; wait for a task-specific request. Choose a concise 3–7 word title. Rename the session when its current name no longer accurately describes the primary task.",
		],
		parameters: Type.Object({
			name: Type.String({
				minLength: 1,
				maxLength: 80,
				description: "A concise descriptive session title",
			}),
		}),
		async execute(_toolCallId, { name }) {
			const currentName = pi.getSessionName();
			const sessionName = name.trim();
			pi.setSessionName(sessionName);
			const message = currentName
				? `Session renamed from ${currentName} to ${sessionName}`
				: `Session named: ${sessionName}`;
			return {
				content: [{ type: "text", text: message }],
				details: {},
			};
		},
	});
}
