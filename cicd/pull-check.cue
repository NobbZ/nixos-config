package cicd

import "cue.dev/x/githubactions"

workflows: pull_request: githubactions.#Workflow & {
	name: "Pull Request Checker"
	"on": pull_request: {}
	jobs: {
		generate_matrix: workflows.updater.jobs.generate_matrix
		build_flake: _buildFlake & {_flakeLock: false}
		build_checks: _buildChecks & {_flakeLock: false}
		check_flake: _checkFlake & {_flakeLock: false}
	}

}
