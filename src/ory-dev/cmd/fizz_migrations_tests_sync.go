package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/spf13/cobra"
)

var fizzTestRegex = regexp.MustCompile("([0-9]+)_([a-zA-Z_0-9]+)(\\.(mysql|postgres|cockroach|sqlite)|)\\.up\\.(fizz|sql)")

// fizzMigrationsTestsSyncCmd represents the sync command
var fizzMigrationsTestsSyncCmd = &cobra.Command{
	Use:   "sync [migrations] [testdata] [fixtures]",
	Short: "Creates testdata files and fixtures directories",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {
		return filepath.Walk(args[0], func(path string, info os.FileInfo, err error) error {
			if info.IsDir() || (filepath.Ext(path) != ".sql" && filepath.Ext(path) != ".fizz") {
				return nil
			}

			if !(strings.HasSuffix(path, ".up.sql") || strings.HasSuffix(path, ".up.fizz")) {
				return nil
			}

			results := fizzTestRegex.FindAllStringSubmatch(path, -1)
			if len(results) != 1 || len(results[0]) != 6 {
				return fmt.Errorf("expected five parts but got: %d", len(results[0]))
			}

			tdp := filepath.Join(args[1], fmt.Sprintf("%s_testdata%s.sql", results[0][1], results[0][3]))
			if _, err := os.Stat(tdp); os.IsNotExist(err) {
				f, err := os.Create(tdp)
				if err != nil {
					return err
				}
				_ = f.Close()
			}

			fix := filepath.Join(args[2], results[0][1])
			if _, err := os.Stat(fix); os.IsNotExist(err) {
				if err := os.Mkdir(fix, 0777); err != nil {
					return err
				}
			}

			return nil
		})
	},
}

func init() {
	fizzMigrationsTestsCmd.AddCommand(fizzMigrationsTestsSyncCmd)
}
