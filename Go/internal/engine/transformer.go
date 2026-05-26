package engine

import (
	"regexp"
	"strconv"
	"strings"
)

var placeholderPattern = regexp.MustCompile(`\((\d+)\)`)

func TransformComponents(components []string, posts map[string]string) []string {
	transformed := make([]string, 0, len(components))
	for _, component := range components {
		words := strings.Fields(component)
		for i, word := range words {
			if replacement, ok := posts[word]; ok {
				words[i] = replacement
			}
		}
		transformed = append(transformed, strings.Join(words, " "))
	}
	return transformed
}

func Reassemble(template string, components []string) string {
	return placeholderPattern.ReplaceAllStringFunc(template, func(match string) string {
		submatches := placeholderPattern.FindStringSubmatch(match)
		if len(submatches) != 2 {
			return ""
		}

		index, err := strconv.Atoi(submatches[1])
		if err != nil || index <= 0 || index > len(components) {
			return ""
		}

		return components[index-1]
	})
}
