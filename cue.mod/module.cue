module: "github.com/nobbz/nixos-config"
language: {
	version: "v0.14.2"
}
deps: {
	"cue.dev/x/githubactions@v0": {
		v:       "v0.2.0"
		default: true
	}
	"github.com/nobbz/coderabbit-cue@v0": {
		v: "v0.0.1"
	}
}
