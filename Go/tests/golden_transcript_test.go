package tests

import (
	"strings"
	"testing"

	"eliza-go/internal/engine"
	"eliza-go/internal/script"
)

func TestGoldenTranscriptPartial(t *testing.T) {
	loadedScript, err := script.LoadScript("")
	if err != nil {
		t.Fatalf("failed to load script: %v", err)
	}

	eliza := engine.New(loadedScript, true)

	conversation := []struct {
		Input         string
		ExpectedStart string
	}{
		{"Men are all alike.", "In what way"},
		{"They're always bugging us about something or other.", "Can you think of a specific example"},
		{"Well, my boyfriend made me come here.", "Your boyfriend made you come here"},
		{"He says I'm depressed much of the time.", "I am sorry to hear that you are depressed"},
		{"It's true. I am unhappy.", "Do you think coming here will help you not to be unhappy"},
	}

	for _, step := range conversation {
		response, quit, err := eliza.Transform(step.Input)
		if err != nil {
			t.Fatalf("transform failed for %q: %v", step.Input, err)
		}
		if quit {
			t.Fatalf("unexpected quit for %q", step.Input)
		}
		if !strings.HasPrefix(strings.ToLower(response), strings.ToLower(step.ExpectedStart)) {
			t.Fatalf("expected response starting with %q, got %q", step.ExpectedStart, response)
		}
	}
}
