package cicd

import "cue.dev/x/githubactions"

workflows: checker: githubactions.#Workflow & {
	name: "Check generated files"
	"on": pull_request: {}
	jobs: check_generated: {
		steps: [
			_cloneRepo,
			_installCue,
			{run: "make check"},
		]
	}
}
