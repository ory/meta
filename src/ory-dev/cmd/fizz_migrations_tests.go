package cmd

import (
	"github.com/spf13/cobra"
)

var fizzMigrationsTestsCmd = &cobra.Command{
	Use:   "tests",
	Short: "Helpers for writing fizz migrations",
}

func init() {
	fizzMigrationsCmd.AddCommand(fizzMigrationsTestsCmd)
}
