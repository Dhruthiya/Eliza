package engine

import (
	"errors"
	"math/rand"
	"strings"
	"sync"
	"time"

	"eliza-go/internal/script"
)

type Engine struct {
	Script        *script.Script
	State         *ConversationState
	Deterministic bool

	mu  sync.Mutex
	rng *rand.Rand
}

func New(loadedScript *script.Script, deterministic bool) *Engine {
	return &Engine{
		Script:        loadedScript,
		State:         NewConversationState(),
		Deterministic: deterministic,
		rng:           rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (e *Engine) Transform(input string) (string, bool, error) {
	e.mu.Lock()
	defer e.mu.Unlock()

	if e.Script == nil {
		return "", false, errors.New("script is nil")
	}

	normalized := NormalizeInput(input, e.Script.Pres)
	words := strings.Fields(normalized)

	for _, quit := range e.Script.Quits {
		if contains(words, quit) {
			return e.pickString(e.Script.Finals, "Goodbye."), true, nil
		}
	}

	if response, ok := e.findResponse(words); ok {
		return response, false, nil
	}

	return e.fallback(), false, nil
}

func (e *Engine) InitialGreeting() string {
	return e.pickString(e.Script.Initials, "How do you do. Please tell me your problem.")
}

func (e *Engine) Reset() {
	e.State.Reset()
}

func (e *Engine) findResponse(words []string) (string, bool) {
	for _, keyword := range e.Script.Keywords {
		if keyword.Name == "xnone" {
			continue
		}
		if !contains(words, keyword.Name) {
			continue
		}
		if response, ok := e.tryKeywordRules(words, keyword); ok {
			return response, true
		}
	}
	return "", false
}

func (e *Engine) tryKeywordRules(words []string, keyword script.Keyword) (string, bool) {
	for ruleIndex, rule := range keyword.Rules {
		components, matched := Match(words, rule.Pattern)
		if !matched {
			continue
		}

		transformed := TransformComponents(components, e.Script.Posts)
		template := e.selectTemplate(keyword.Name, ruleIndex, rule.Reassembly)

		if strings.HasPrefix(template, "goto ") {
			target := strings.TrimSpace(strings.TrimPrefix(template, "goto "))
			if response, ok := e.handleGoto(words, target); ok {
				if rule.IsMemoryRule {
					e.State.SaveMemory(response)
					return "", false
				}
				return response, true
			}
			continue
		}

		response := Reassemble(template, transformed)
		if rule.IsMemoryRule {
			e.State.SaveMemory(response)
			continue
		}
		return response, true
	}
	return "", false
}

func (e *Engine) handleGoto(words []string, target string) (string, bool) {
	for _, keyword := range e.Script.Keywords {
		if keyword.Name == target {
			return e.tryKeywordRules(words, keyword)
		}
	}
	return "", false
}

func (e *Engine) fallback() string {
	if response, ok := e.State.PopMemory(); ok {
		return response
	}

	for _, keyword := range e.Script.Keywords {
		if keyword.Name == "xnone" && len(keyword.Rules) > 0 {
			return e.pickString(keyword.Rules[0].Reassembly, "I'm not sure I understand.")
		}
	}

	return "I'm not sure I understand."
}

func (e *Engine) selectTemplate(keyword string, ruleIndex int, options []string) string {
	if len(options) == 0 {
		return ""
	}
	index := e.State.NextResponseIndex(keyword, ruleIndex, len(options))
	return options[index]
}

func (e *Engine) pickString(options []string, fallback string) string {
	if len(options) == 0 {
		return fallback
	}
	if e.Deterministic {
		return options[0]
	}
	return options[e.rng.Intn(len(options))]
}

func contains(words []string, target string) bool {
	for _, word := range words {
		if word == target {
			return true
		}
	}
	return false
}
