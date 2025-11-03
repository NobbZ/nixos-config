package cicd

import "github.com/nobbz/coderabbit-cue@v0:coderabbit"

coderabbit_yml: coderabbit.#Config & {
	reviews: tools: "github-checks": {
		enabled:    true
		timeout_ms: 15 * 60 * 1000 // 15 minutes
	}
}
