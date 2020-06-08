package cmd

import (
	"github.com/spf13/cobra"
)

var fizzMigrationsCmd = &cobra.Command{
	Use:   "migrations",
	Short: "Helpers for writing migrations",
}

func init() {
	fizzCmd.AddCommand(fizzMigrationsCmd)
}
