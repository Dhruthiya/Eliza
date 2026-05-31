package script

type TokenKind int

const (
	TokenLiteral TokenKind = iota
	TokenWildcard
	TokenSynonym
)

type PatternToken struct {
	Kind         TokenKind
	Value        string
	Alternatives []string
}

type Rule struct {
	Pattern      []PatternToken
	Reassembly   []string
	IsMemoryRule bool
}

type Keyword struct {
	Name  string
	Rank  int
	Rules []Rule
}

type PostTransform struct {
	Pattern     string
	Replacement string
}

type Script struct {
	Initials       []string
	Finals         []string
	Quits          []string
	Pres           map[string]string
	Posts          map[string]string
	Synons         map[string][]string
	Keywords       []Keyword
	PostTransforms []PostTransform
}
