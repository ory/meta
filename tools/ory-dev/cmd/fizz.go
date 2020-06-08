package cmd

import (
	"github.com/spf13/cobra"
)

// fizzCmd represents the fizz command
var fizzCmd = &cobra.Command{
	Use:   "fizz",
	Short: "Helpers for fizz migrations",
}

func init() {
	rootCmd.AddCommand(fizzCmd)
}
