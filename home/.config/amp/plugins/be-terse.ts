// Port of https://github.com/bigskysoftware/be-terse: asks for terse replies on every prompt.
import type { PluginAPI } from '@ampcode/plugin'

export const description = 'Appends "respond tersely in Simplified Technical English" to every prompt. End a prompt with "noterse" to skip.'

export default function (amp: PluginAPI) {
	amp.on('agent.start', (event) => {
		if (event.message.trimEnd().endsWith('noterse')) return {}
		return { message: { content: 'respond tersely in Simplified Technical English' } }
	})
}
