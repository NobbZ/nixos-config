.PHONY: workflows fmt

workflows: .github/workflows/flake-update.yml .github/workflows/pull-check.yml

.github/workflows/flake-update.yml: cicd/*.cue cue.mod/module.cue
	CUE_DEBUG=sortfields cue export ./cicd/ -f -e workflows.updater -o .github/workflows/flake-update.yml

.github/workflows/pull-check.yml: cicd/*.cue cue.mod/module.cue
	CUE_DEBUG=sortfields cue export ./cicd/ -f -e workflows.pull_request -o .github/workflows/pull-check.yml

fmt:
	cue fmt cicd/*.cue
	alejandra .
