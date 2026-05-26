package engine

import (
	"regexp"
	"sort"
	"strings"
)

var punctuationPattern = regexp.MustCompile(`[^\w\s]`)

func NormalizeInput(input string, pres map[string]string) string {
	normalized := strings.ToLower(input)
	normalized = applyTransformations(normalized, pres)
	normalized = punctuationPattern.ReplaceAllString(normalized, " ")
	return strings.Join(strings.Fields(normalized), " ")
}

func applyTransformations(text string, transformations map[string]string) string {
	keys := make([]string, 0, len(transformations))
	for key := range transformations {
		keys = append(keys, key)
	}
	sort.SliceStable(keys, func(i, j int) bool {
		return len(keys[i]) > len(keys[j])
	})

	for _, key := range keys {
		text = strings.ReplaceAll(text, key, transformations[key])
	}
	return text
}
