import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

type Mode = "off" | "lite" | "full" | "ultra" | "review";
type PonytailGlobal = typeof globalThis & { __ompPonytailMode?: Mode };

const DEFAULT_MODE: Mode = "full";
const VALID_MODES: Record<Mode, true> = { off: true, lite: true, full: true, ultra: true, review: true };
const RUNTIME_MODES: Partial<Record<Mode, true>> = { off: true, lite: true, full: true, ultra: true };
const SKILL_PATH = path.resolve(import.meta.dir, "..", "skills", "ponytail", "SKILL.md");
const instructionCache = new Map<Mode, string>();

function normalizeMode(value: unknown): Mode | undefined {
	if (typeof value !== "string") return undefined;
	const mode = value.trim().toLowerCase() as Mode;
	return VALID_MODES[mode] ? mode : undefined;
}

function getConfigPath(): string {
	if (process.env.XDG_CONFIG_HOME) return path.join(process.env.XDG_CONFIG_HOME, "ponytail", "config.json");
	if (process.platform === "win32") {
		return path.join(process.env.APPDATA || path.join(os.homedir(), "AppData", "Roaming"), "ponytail", "config.json");
	}
	return path.join(os.homedir(), ".config", "ponytail", "config.json");
}

function getDefaultMode(): Mode {
	const envMode = normalizeMode(process.env.PONYTAIL_DEFAULT_MODE);
	if (envMode) return envMode;
	try {
		const config = JSON.parse(fs.readFileSync(getConfigPath(), "utf8")) as { defaultMode?: unknown };
		return normalizeMode(config.defaultMode) ?? DEFAULT_MODE;
	} catch {
		return DEFAULT_MODE;
	}
}

function getMode(): Mode {
	const state = globalThis as PonytailGlobal;
	state.__ompPonytailMode ??= getDefaultMode();
	return state.__ompPonytailMode;
}


function instructionsFor(mode: Mode): string {
	const cached = instructionCache.get(mode);
	if (cached) return cached;
	if (mode === "review") {
		return "PONYTAIL MODE ACTIVE — level: review. Behavior defined by the ponytail-review skill.";
	}

	const body = fs.readFileSync(SKILL_PATH, "utf8").replace(/^---[\s\S]*?---\s*/, "");
	const filtered = body
		.split(/\r?\n/)
		.filter(line => {
			const tableLabel = line.match(/^\|\s*\*\*(.+?)\*\*\s*\|/);
			if (tableLabel) {
				const label = normalizeMode(tableLabel[1]);
				if (label && RUNTIME_MODES[label]) return label === mode;
			}
			const exampleLabel = line.match(/^-\s*([^:]+):\s*"/);
			if (exampleLabel) {
				const label = normalizeMode(exampleLabel[1]);
				if (label && RUNTIME_MODES[label]) return label === mode;
			}
			return true;
		})
		.join("\n");
	const instructions = `PONYTAIL MODE ACTIVE — level: ${mode}\n\n${filtered}`;
	instructionCache.set(mode, instructions);
	return instructions;
}

function updateStatus(ctx: { ui: { setStatus(key: string, text: string | undefined): void } }): void {
	const mode = getMode();
	const label = mode === "full" ? "[PONYTAIL]" : `[PONYTAIL:${mode.toUpperCase()}]`;
	ctx.ui.setStatus("ponytail", mode === "off" ? undefined : label);
}

export default function ponytail(pi: ExtensionAPI): void {
	pi.setLabel("Ponytail");

	pi.on("session_start", async (_event, ctx) => {
		updateStatus(ctx);
	});

	pi.on("before_agent_start", async (event, ctx) => {
		const command = event.prompt.trim().toLowerCase().replace(/[.!?\s]+$/, "");
		if (command === "stop ponytail" || command === "normal mode") {
			(globalThis as PonytailGlobal).__ompPonytailMode = "off";
		}
		updateStatus(ctx);
		const mode = getMode();
		if (mode === "off") return;
		return { systemPrompt: [...event.systemPrompt, instructionsFor(mode)] };
	});

	pi.registerCommand("ponytail", {
		description: "Set Ponytail mode: lite, full, ultra, or off",
		async handler(args, ctx) {
			const requested = args.trim() ? normalizeMode(args.split(/\s+/)[0]) : getDefaultMode();
			if (!requested || requested === "review") {
				ctx.ui.notify("Usage: /ponytail [lite|full|ultra|off]", "error");
				return;
			}
			(globalThis as PonytailGlobal).__ompPonytailMode = requested;
			updateStatus(ctx);
			ctx.ui.notify(requested === "off" ? "Ponytail mode off" : `Ponytail mode: ${requested}`, "info");
		},
	});
}
