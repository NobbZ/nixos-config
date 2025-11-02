.PHONY: workflows check fmt

workflows: .github/workflows/flake-update.yml .github/workflows/pull-check.yml

check:
	cue vet -c ./cicd/ .github/workflows/flake-update.yml -d 'workflows.updater'
	cue vet -c ./cicd/ .github/workflows/pull-check.yml -d 'workflows.pull_request'

.github/workflows/flake-update.yml: cicd/*.cue cue.mod/module.cue
	CUE_DEBUG=sortfields cue export ./cicd/ -f -e workflows.updater -o .github/workflows/flake-update.yml

.github/workflows/pull-check.yml: cicd/*.cue cue.mod/module.cue
	CUE_DEBUG=sortfields cue export ./cicd/ -f -e workflows.pull_request -o .github/workflows/pull-check.yml

fmt:
	cue fmt cicd/*.cue
	alejandra .
