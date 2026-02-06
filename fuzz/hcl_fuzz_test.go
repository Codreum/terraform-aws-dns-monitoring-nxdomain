package fuzz

import (
	"testing"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

func FuzzHCLParse(f *testing.F) {
	// Seeds (native Go fuzzing in OSS-Fuzz won’t use F.Add as corpus, but it’s
	// still useful locally).
	f.Add([]byte(`variable "x" { default = "y" }`))
	f.Add([]byte(`resource "aws_cloudwatch_log_metric_filter" "m" { name="x" pattern="y" }`))

	f.Fuzz(func(t *testing.T, data []byte) {
		// Keep inputs bounded (performance + avoid huge allocations).
		if len(data) == 0 || len(data) > 1<<16 {
			return
		}
		_, _ = hclsyntax.ParseConfig(data, "fuzz.hcl", hcl.Pos{Line: 1, Column: 1})
	})
}
