import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function autoNameSession(pi: ExtensionAPI) {
	pi.registerTool({
		name: "set_session_name",
		label: "Name Session",
		description: "Set a concise display name for the current session",
		promptSnippet: "Name the current session once the user's actual task is clear",
		promptGuidelines: [
			"Use set_session_name once near the beginning of every unnamed session, after the user's actual task is clear. Do not call set_session_name for /setup or other bootstrap prompts; wait for a task-specific request. Choose a concise 3–7 word title. Never rename a session that already has a name.",
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
			if (currentName) {
				return {
					content: [{ type: "text", text: `Session is already named: ${currentName}` }],
					details: {},
				};
			}

			const sessionName = name.trim();
			pi.setSessionName(sessionName);
			return {
				content: [{ type: "text", text: `Session named: ${sessionName}` }],
				details: {},
			};
		},
	});
}
