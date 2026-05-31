package tests

import (
	"reflect"
	"testing"

	"eliza-go/internal/engine"
	"eliza-go/internal/script"
)

func TestMatchSimplePattern(t *testing.T) {
	words := []string{"hello", "world"}
	pattern := []script.PatternToken{
		{Kind: script.TokenLiteral, Value: "hello"},
		{Kind: script.TokenLiteral, Value: "world"},
	}

	components, ok := engine.Match(words, pattern)
	if !ok {
		t.Fatal("expected match")
	}
	if len(components) != 0 {
		t.Fatalf("expected no captures, got %#v", components)
	}
}

func TestMatchSingleWildcard(t *testing.T) {
	words := []string{"i", "am", "happy"}
	pattern := []script.PatternToken{
		{Kind: script.TokenLiteral, Value: "i"},
		{Kind: script.TokenLiteral, Value: "am"},
		{Kind: script.TokenWildcard},
	}

	components, ok := engine.Match(words, pattern)
	if !ok {
		t.Fatal("expected match")
	}

	expected := []string{"happy"}
	if !reflect.DeepEqual(components, expected) {
		t.Fatalf("expected %#v, got %#v", expected, components)
	}
}

func TestMatchGreedyWildcard(t *testing.T) {
	words := []string{"i", "think", "i", "love", "you"}
	pattern := []script.PatternToken{
		{Kind: script.TokenWildcard},
		{Kind: script.TokenLiteral, Value: "i"},
		{Kind: script.TokenWildcard},
		{Kind: script.TokenLiteral, Value: "you"},
		{Kind: script.TokenWildcard},
	}

	components, ok := engine.Match(words, pattern)
	if !ok {
		t.Fatal("expected match")
	}

	expected := []string{"", "think i love", ""}
	if !reflect.DeepEqual(components, expected) {
		t.Fatalf("expected %#v, got %#v", expected, components)
	}
}

func TestMatchFails(t *testing.T) {
	words := []string{"hello", "world"}
	pattern := []script.PatternToken{
		{Kind: script.TokenLiteral, Value: "goodbye"},
		{Kind: script.TokenLiteral, Value: "world"},
	}

	if _, ok := engine.Match(words, pattern); ok {
		t.Fatal("expected no match")
	}
}
