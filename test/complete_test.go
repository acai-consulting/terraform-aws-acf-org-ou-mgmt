package test

import (
	"os/exec"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func listTerraformState(t *testing.T, dir string) []string {
	cmd := exec.Command("terraform", "state", "list")
	cmd.Dir = dir // Set the working directory to where your Terraform files are.

	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Failed to list Terraform state: %s\nOutput:\n%s", err, string(output))
	}
	t.Logf("State List Output:\n%s", string(output))

	// Convert output to a slice for easier handling
	// You might need to modify the parsing based on your specific output format or needs
	lines := strings.Split(string(output), "\n")
	return lines
}

func TestExampleComplete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")

	terraformDir := "../examples/complete"

	// Create IAM Role
	terraformPreparation := &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      false,
		Lock:         true,
		Targets: []string{
			"module.create_provisioner",
			"aws_organizations_policy.scp_example",
		},
	}
	terraform.InitAndApply(t, terraformPreparation)

	terraformModule := &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      false,
		Lock:         true,
	}
	terraform.InitAndApply(t, terraformModule)

	// Retrieve the 'test_success' outputs
	testSuccess1Output := terraform.Output(t, terraformModule, "test_success1")
	testSuccess2Output := terraform.Output(t, terraformModule, "test_success2")
	testSuccess3Output := terraform.Output(t, terraformModule, "test_success3")
	t.Logf("testSuccess1Output: %s", testSuccess1Output)
	t.Logf("testSuccess2Output: %s", testSuccess2Output)
	t.Logf("testSuccess3Output: %s", testSuccess3Output)

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccess1Output, "The test_success1 output is not true")
	assert.Equal(t, "true", testSuccess2Output, "The test_success2 output is not true")
	assert.Equal(t, "true", testSuccess3Output, "The test_success3 output is not true")

	terraform.Destroy(t, terraformModule)

	terraform.Destroy(t, terraformPreparation)
}
