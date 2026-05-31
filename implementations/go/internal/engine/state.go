package engine

import "sync"

type RuleKey struct {
	Keyword string
	Rule    int
}

type ConversationState struct {
	mu            sync.Mutex
	ResponseIndex map[RuleKey]int
	Memory        []string
}

func NewConversationState() *ConversationState {
	return &ConversationState{
		ResponseIndex: make(map[RuleKey]int),
	}
}

func (s *ConversationState) NextResponseIndex(keyword string, ruleIndex int, max int) int {
	s.mu.Lock()
	defer s.mu.Unlock()

	key := RuleKey{Keyword: keyword, Rule: ruleIndex}
	current := s.ResponseIndex[key]
	if max > 0 {
		s.ResponseIndex[key] = (current + 1) % max
	}
	return current
}

func (s *ConversationState) SaveMemory(response string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.Memory = append(s.Memory, response)
}

func (s *ConversationState) PopMemory() (string, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if len(s.Memory) == 0 {
		return "", false
	}
	value := s.Memory[0]
	s.Memory = s.Memory[1:]
	return value, true
}

func (s *ConversationState) Reset() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.ResponseIndex = make(map[RuleKey]int)
	s.Memory = nil
}
