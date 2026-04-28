package cicd

import "cue.dev/x/githubactions"

workflows: updater: githubactions.#Workflow & {
	name: "Updater"
	"on": {
		schedule: [{cron: "0 2 * * *"}]
		workflow_dispatch: {}
	}
	jobs: {
		generate_matrix: {
			outputs: {
				packages:        "${{ steps.gen_packages.outputs.packages }}"
				checks:          "${{ steps.gen_checks.outputs.checks }}"
				packages_darwin: "${{ steps.gen_packages_darwin.outputs.packages_darwin }}"
				checks_darwin:   "${{ steps.gen_checks_darwin.outputs.checks_darwin }}"
			}
			steps: [
				_cloneRepo,
				_installNix,
				{
					name: "Generate flake.json"
					run:  "nix flake show --json > flake.json"
				},
				{
					id: "gen_packages"
					run: """
						packages=$(jq -c '.packages."x86_64-linux" | keys' < flake.json)
						printf "packages=%s" "$packages" >> "${GITHUB_OUTPUT}"
						"""
				},
				{
					id: "gen_checks"
					run: """
						checks=$(jq -c '.checks."x86_64-linux" | keys' < flake.json)
						printf "checks=%s" "$checks" >> "${GITHUB_OUTPUT}"
						"""
				},
				{
					id: "gen_packages_darwin"
					run: """
						packages_darwin=$(jq -c '.packages."aarch64-darwin" | keys' < flake.json)
						printf "packages_darwin=%s" "$packages_darwin" >> "${GITHUB_OUTPUT}"
						"""
				},
				{
					id: "gen_checks_darwin"
					run: """
						checks_darwin=$(jq -c '.checks."aarch64-darwin" | keys' < flake.json)
						printf "checks_darwin=%s" "$checks_darwin" >> "${GITHUB_OUTPUT}"
						"""
				},
			]
		}
		update_flake: steps: [
			_cloneRepo,
			_installNix,
			_setupGit,
			{
				name: "Update the flake"
				run:  "nix flake update"
			},
			{
				name: "Store flake.lock"
				uses: "actions/upload-artifact@v7"
				with: {
					name: "flake_lock"
					path: "flake.lock"
				}
			},
		]
		build_flake: _buildFlake & {_flakeLock: true}
		build_checks: _buildChecks & {_flakeLock: true}
		build_flake_darwin: _buildFlakeDarwin & {_flakeLock: true}
		build_checks_darwin: _buildChecksDarwin & {_flakeLock: true}
		check_flake: _checkFlake & {_flakeLock: true}

		push_update: {
			permissions: "write-all"
			needs: ["update_flake", "build_flake", "build_checks", "check_flake", "build_flake_darwin", "build_checks_darwin"]
			steps: [
				_cloneRepo,
				_restoreFlakeLock,
				_setupGit,
				{
					name: "Create and merge PR"
					run: """
						git switch -c updates-${{ github.run_id }}
						git commit -am "flake.lock: Update"
						git push -u origin updates-${{ github.run_id }}
						PR="$(gh pr create \\
						  --assignee NobbZ \\
						  --base main \\
						  --body "Automatic flake update on $(date -Idate)" \\
						  --fill \\
						  --label bot \\
						  --title "Auto update $(date -Idate)")"
						gh pr merge "$PR" --merge --delete-branch
						"""
					env: "GITHUB_TOKEN": "${{ secrets.TEST_TOKEN }}"
				},
			]
		}
	}
}
