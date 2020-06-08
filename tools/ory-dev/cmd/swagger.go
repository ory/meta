package cmd

import (
	"github.com/spf13/cobra"
)

var swaggerCmd = &cobra.Command{
	Use:   "swagger",
	Short: "Helpers for Swagger 2.0 / OpenAPI Spec",
}

func init() {
	rootCmd.AddCommand(swaggerCmd)
}
