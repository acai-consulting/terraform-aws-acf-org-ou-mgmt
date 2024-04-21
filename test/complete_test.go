package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExampleComplete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/complete",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Retrieve the 'test_success' outputs
	testSuccess1Output := terraform.Output(t, terraformOptions, "test_success1")
	testSuccess2Output := terraform.Output(t, terraformOptions, "test_success2")
	t.Logf("Lambda testSuccess1Output: %s", testSuccess1Output)
	t.Logf("Lambda testSuccess2Output: %s", testSuccess2Output)

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success1 output is not true")
	assert.Equal(t, "true", testSuccess2Output, "The test_success2 output is not true")
}
