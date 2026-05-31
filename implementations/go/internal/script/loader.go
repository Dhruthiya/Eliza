package script

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

func LoadScript(basePath string) (*Script, error) {
	resolvedPath, err := resolveDataPath(basePath)
	if err != nil {
		return nil, err
	}

	initials, err := loadStringSlice(filepath.Join(resolvedPath, "elizaInitials.json"))
	if err != nil {
		return nil, err
	}
	finals, err := loadStringSlice(filepath.Join(resolvedPath, "elizaFinals.json"))
	if err != nil {
		return nil, err
	}
	quits, err := loadStringSlice(filepath.Join(resolvedPath, "elizaQuits.json"))
	if err != nil {
		return nil, err
	}
	pres, err := loadPairsMap(filepath.Join(resolvedPath, "elizaPres.json"))
	if err != nil {
		return nil, err
	}
	posts, err := loadPairsMap(filepath.Join(resolvedPath, "elizaPosts.json"))
	if err != nil {
		return nil, err
	}
	synons, err := loadSynonyms(filepath.Join(resolvedPath, "elizaSynons.json"))
	if err != nil {
		return nil, err
	}
	keywords, err := loadKeywords(filepath.Join(resolvedPath, "elizaKeywords.json"), synons)
	if err != nil {
		return nil, err
	}
	postTransforms, err := loadPostTransforms(filepath.Join(resolvedPath, "elizaPostTransforms.json"))
	if err != nil {
		return nil, err
	}

	return &Script{
		Initials:       initials,
		Finals:         finals,
		Quits:          quits,
		Pres:           pres,
		Posts:          posts,
		Synons:         synons,
		Keywords:       keywords,
		PostTransforms: postTransforms,
	}, nil
}

func ResolveProjectRoot() (string, error) {
	candidates := []string{
		".",
		"..",
		"../Go",
		"../../Go",
	}
	for _, candidate := range candidates {
		abs, err := filepath.Abs(candidate)
		if err != nil {
			continue
		}
		if fileExists(filepath.Join(abs, "web", "index.html")) {
			return abs, nil
		}
	}
	return "", errors.New("could not resolve Go project root")
}

func resolveDataPath(basePath string) (string, error) {
	if basePath != "" {
		if dirExists(basePath) {
			return basePath, nil
		}
		return "", fmt.Errorf("data path does not exist: %s", basePath)
	}

	if envPath := os.Getenv("ELIZA_DATA_PATH"); envPath != "" && dirExists(envPath) {
		return envPath, nil
	}

	candidates := []string{
		"../../shared/data",
		"../shared/data",
		"./shared/data",
		"../../data",
		"../data",
		"./data",
	}
	for _, candidate := range candidates {
		if dirExists(candidate) {
			return candidate, nil
		}
	}

	return "", errors.New("could not locate ELIZA data directory")
}

func loadStringSlice(path string) ([]string, error) {
	var values []string
	if err := loadJSON(path, &values); err != nil {
		return nil, err
	}
	return values, nil
}

func loadPairsMap(path string) (map[string]string, error) {
	var rows [][]string
	if err := loadJSON(path, &rows); err != nil {
		return nil, err
	}

	result := make(map[string]string, len(rows))
	for _, row := range rows {
		if len(row) != 2 {
			return nil, fmt.Errorf("invalid pair row in %s", path)
		}
		result[row[0]] = row[1]
	}
	return result, nil
}

func loadSynonyms(path string) (map[string][]string, error) {
	var values map[string][]string
	if err := loadJSON(path, &values); err != nil {
		return nil, err
	}
	return values, nil
}

func loadKeywords(path string, synons map[string][]string) ([]Keyword, error) {
	var rows []json.RawMessage
	if err := loadJSON(path, &rows); err != nil {
		return nil, err
	}

	keywords := make([]Keyword, 0, len(rows))
	for _, row := range rows {
		var decoded []json.RawMessage
		if err := json.Unmarshal(row, &decoded); err != nil {
			return nil, err
		}
		if len(decoded) != 3 {
			return nil, fmt.Errorf("invalid keyword row in %s", path)
		}

		var name string
		var rank int
		var ruleRows []json.RawMessage
		if err := json.Unmarshal(decoded[0], &name); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(decoded[1], &rank); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(decoded[2], &ruleRows); err != nil {
			return nil, err
		}

		rules := make([]Rule, 0, len(ruleRows))
		for _, ruleRaw := range ruleRows {
			var ruleFields []json.RawMessage
			if err := json.Unmarshal(ruleRaw, &ruleFields); err != nil {
				return nil, err
			}
			if len(ruleFields) != 2 {
				return nil, fmt.Errorf("invalid rule row for keyword %s", name)
			}

			var pattern string
			var reassembly []string
			if err := json.Unmarshal(ruleFields[0], &pattern); err != nil {
				return nil, err
			}
			if err := json.Unmarshal(ruleFields[1], &reassembly); err != nil {
				return nil, err
			}

			isMemoryRule := false
			if strings.HasPrefix(pattern, "$") {
				isMemoryRule = true
				pattern = strings.TrimSpace(strings.TrimPrefix(pattern, "$"))
			}

			rules = append(rules, Rule{
				Pattern:      parsePattern(pattern, synons),
				Reassembly:   reassembly,
				IsMemoryRule: isMemoryRule,
			})
		}

		keywords = append(keywords, Keyword{
			Name:  strings.ToLower(name),
			Rank:  rank,
			Rules: rules,
		})
	}

	sort.SliceStable(keywords, func(i, j int) bool {
		return keywords[i].Rank > keywords[j].Rank
	})

	return keywords, nil
}

func loadPostTransforms(path string) ([]PostTransform, error) {
	var rows [][]string
	if err := loadJSON(path, &rows); err != nil {
		return nil, err
	}

	transforms := make([]PostTransform, 0, len(rows))
	for _, row := range rows {
		if len(row) != 2 {
			return nil, fmt.Errorf("invalid post transform row in %s", path)
		}
		transforms = append(transforms, PostTransform{
			Pattern:     row[0],
			Replacement: row[1],
		})
	}
	return transforms, nil
}

func parsePattern(pattern string, synons map[string][]string) []PatternToken {
	normalized := strings.ToLower(pattern)
	normalized = strings.ReplaceAll(normalized, "*", " * ")
	parts := strings.Fields(normalized)
	tokens := make([]PatternToken, 0, len(parts))
	for _, part := range parts {
		if part == "*" {
			tokens = append(tokens, PatternToken{Kind: TokenWildcard})
			continue
		}
		if strings.HasPrefix(part, "@") {
			name := strings.TrimPrefix(part, "@")
			tokens = append(tokens, PatternToken{
				Kind:         TokenSynonym,
				Value:        name,
				Alternatives: append([]string(nil), synons[name]...),
			})
			continue
		}
		tokens = append(tokens, PatternToken{
			Kind:  TokenLiteral,
			Value: part,
		})
	}
	return tokens
}

func loadJSON(path string, target any) error {
	bytes, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	return json.Unmarshal(bytes, target)
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}

func dirExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.IsDir()
}
