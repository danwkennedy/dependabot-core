package main

import (
	"context"
	"os"
	"os/exec"
	"rsc.io/script"
	"rsc.io/script/scripttest"
	"testing"
	"time"
)

func TestDependabot(t *testing.T) {
	out, err := exec.Command("../../script/build", "example").CombinedOutput()
	if err != nil {
		t.Fatal("failed to build example ecosystem:\n\n", string(out))
	}

	ctx := context.Background()
	engine := &script.Engine{
		Conds: scripttest.DefaultConds(),
		Cmds:  Commands(),
		Quiet: !testing.Verbose(),
	}
	env := []string{
		"PATH=" + os.Getenv("PATH"),
	}
	scripttest.Test(t, ctx, engine, env, "testdata/*.txt")
}

// Commands returns the commands that can be used in the scripts.
// Each line of the scripts are <command> <args...>
// When you use "echo" in the scripts it's actually running script.Echo
// not the echo binary on your system.
func Commands() map[string]script.Cmd {
	commands := scripttest.DefaultCmds()

	// additional Dependabot commands
	commands["dependabot"] = script.Program("dependabot", nil, 100*time.Millisecond)

	return commands
}
