package script

// Script holds the entire parsed ELIZA script.
type Script struct {
	Initials       []string            `json:"initials"`
	Finals         []string            `json:"finals"`
	Quits          []string            `json:"quits"`
	Pres           map[string]string   `json:"pres"`
	Posts          map[string]string   `json:"posts"`
	Synons         map[string][]string `json:"synons"`
	Keywords       []Keyword           `json:"keywords"`
	PostTransforms [][2]string          `json:"postTransforms"`
}

// Keyword holds a keyword, its rank, and its rules.
type Keyword struct {
	Name  string `json:"name"`
	Rank  int    `json:"rank"`
	Rules []Rule `json:"rules"`
}

// Rule holds a single decomposition pattern and its reassembly templates.
type Rule struct {
	Pattern      string `json:"pattern"`
	Reassembly   []string `json:"reassembly"`
	IsMemoryRule bool     `json:"isMemoryRule"`
}
