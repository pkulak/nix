import type { Dirent } from "node:fs";
import { readdir, readFile, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const memoryRoot = join(homedir(), "notes", "memory");
const memoryFile = join(memoryRoot, "MEMORY.md");
const dailyDir = join(memoryRoot, "daily");
const dailyNoteCount = 7;

interface MemorySection {
  path: string;
  content: string;
}

interface MemoryLoadResult {
  context: string | null;
  sourceCount: number;
  errors: string[];
}

interface DailyNoteCandidate {
  path: string;
  name: string;
  sortTime: number;
}

function displayPath(path: string): string {
  const home = homedir();
  return path === home ? "~" : path.startsWith(`${home}/`) ? `~/${path.slice(home.length + 1)}` : path;
}

function escapeAttribute(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function dateFromDailyNoteName(name: string): number | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(name);
  if (!match) return null;

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const date = new Date(Date.UTC(year, month - 1, day));

  if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) {
    return null;
  }

  return date.getTime();
}

function getErrorCode(error: unknown): string | undefined {
  if (typeof error !== "object" || error === null || !("code" in error)) return undefined;
  const code = (error as { code?: unknown }).code;
  return typeof code === "string" ? code : undefined;
}

function formatError(action: string, path: string, error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  return `${action} ${displayPath(path)}: ${message}`;
}

async function readMemorySection(path: string, errors: string[]): Promise<MemorySection | null> {
  try {
    const content = await readFile(path, "utf8");
    if (content.trim().length === 0) return null;
    return { path, content: content.trimEnd() };
  } catch (error) {
    if (getErrorCode(error) !== "ENOENT") {
      errors.push(formatError("Could not read", path, error));
    }
    return null;
  }
}

async function getRecentDailyNotePaths(errors: string[]): Promise<string[]> {
  let entries: Dirent[];
  try {
    entries = await readdir(dailyDir, { withFileTypes: true });
  } catch (error) {
    if (getErrorCode(error) !== "ENOENT") {
      errors.push(formatError("Could not list", dailyDir, error));
    }
    return [];
  }

  const candidates = await Promise.all(
    entries
      .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
      .map(async (entry): Promise<DailyNoteCandidate | null> => {
        const path = join(dailyDir, entry.name);
        try {
          const metadata = await stat(path);
          return {
            path,
            name: entry.name,
            sortTime: dateFromDailyNoteName(entry.name) ?? metadata.mtimeMs,
          };
        } catch (error) {
          errors.push(formatError("Could not inspect", path, error));
          return null;
        }
      }),
  );

  return candidates
    .filter((candidate): candidate is DailyNoteCandidate => candidate !== null)
    .sort((a, b) => b.sortTime - a.sortTime || b.name.localeCompare(a.name))
    .slice(0, dailyNoteCount)
    .map((candidate) => candidate.path);
}

function buildMemoryContext(sections: MemorySection[]): string {
  const renderedSections = sections
    .map((section) => {
      const path = escapeAttribute(displayPath(section.path));
      return `<memory_file path="${path}">\n${section.content}\n</memory_file>`;
    })
    .join("\n\n");

  return `## Persistent Memory Context\n\nThe following user memory notes were loaded at Pi startup from ~/notes/memory. Treat them as background context. Current conversation instructions override these notes when they conflict.\n\n${renderedSections}`;
}

async function loadMemoryContext(): Promise<MemoryLoadResult> {
  const errors: string[] = [];
  const sections: MemorySection[] = [];

  const mainMemory = await readMemorySection(memoryFile, errors);
  if (mainMemory) sections.push(mainMemory);

  const dailyNotePaths = await getRecentDailyNotePaths(errors);
  for (const path of dailyNotePaths) {
    const section = await readMemorySection(path, errors);
    if (section) sections.push(section);
  }

  return {
    context: sections.length > 0 ? buildMemoryContext(sections) : null,
    sourceCount: sections.length,
    errors,
  };
}

export default function memoryContextExtension(pi: ExtensionAPI) {
  let memoryContext: string | null = null;

  pi.on("session_start", async (_event, ctx) => {
    const result = await loadMemoryContext();
    memoryContext = result.context;

    if (!ctx.hasUI) return;

    if (result.sourceCount > 0) {
      ctx.ui.notify(
        `Loaded memory context from ${result.sourceCount} note${result.sourceCount === 1 ? "" : "s"}.`,
        "info",
      );
    }

    for (const error of result.errors) {
      ctx.ui.notify(`Memory context: ${error}`, "warning");
    }
  });

  pi.on("before_agent_start", async (event) => {
    if (!memoryContext) return;

    return {
      systemPrompt: `${event.systemPrompt}\n\n${memoryContext}`,
    };
  });
}
