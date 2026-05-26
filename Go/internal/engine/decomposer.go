package engine

import (
	"strings"

	"eliza-go/internal/script"
)

func Match(words []string, pattern []script.PatternToken) ([]string, bool) {
	return matchHelper(words, pattern, nil)
}

func matchHelper(words []string, pattern []script.PatternToken, acc []string) ([]string, bool) {
	if len(words) == 0 && len(pattern) == 0 {
		return append([]string(nil), acc...), true
	}
	if len(pattern) == 0 {
		return nil, false
	}
	if len(words) == 0 {
		if pattern[0].Kind == script.TokenWildcard {
			return matchHelper(words, pattern[1:], append(acc, ""))
		}
		return nil, false
	}

	current := pattern[0]
	if current.Kind == script.TokenWildcard {
		return greedyWildcard(words, pattern[1:], acc)
	}
	if tokenMatches(current, words[0]) {
		if current.Kind == script.TokenSynonym {
			return matchHelper(words[1:], pattern[1:], append(acc, words[0]))
		}
		return matchHelper(words[1:], pattern[1:], acc)
	}
	return nil, false
}

func greedyWildcard(words []string, rest []script.PatternToken, acc []string) ([]string, bool) {
	if len(rest) == 0 {
		return append(append([]string(nil), acc...), strings.Join(words, " ")), true
	}
	if rest[0].Kind == script.TokenWildcard {
		return matchHelper(words, rest, append(acc, ""))
	}

	nextToken := rest[0]
	for idx, word := range words {
		if !tokenMatches(nextToken, word) {
			continue
		}
		captured := strings.Join(words[:idx], " ")
		if components, ok := matchHelper(words[idx:], rest, append(acc, captured)); ok {
			return components, true
		}
	}

	return nil, false
}

func tokenMatches(token script.PatternToken, word string) bool {
	switch token.Kind {
	case script.TokenLiteral:
		return token.Value == word
	case script.TokenSynonym:
		if token.Value == word {
			return true
		}
		for _, synonym := range token.Alternatives {
			if synonym == word {
				return true
			}
		}
		return false
	default:
		return false
	}
}
