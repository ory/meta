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

func makeFileIfNotExist(p string) error {
	if _, err := os.Stat(p); !os.IsNotExist(err) {
		return nil
	}
	f, err := os.Create(p)
	if err != nil {
		return err
	}
	return f.Close()
}

// fizzMigrationsTestsSyncCmd represents the sync command
var fizzMigrationsTestsSyncCmd = &cobra.Command{
	Use:   "sync <path/to/migrations> <path/to/testdata>",
	Short: "Creates testdata files and fixtures directories",
	Args:  cobra.ExactArgs(2),
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
			if err := makeFileIfNotExist(tdp); err != nil {
				return err
			}

			// Ignore fixture paths for now as we don't really use them.
			//
			// fix := filepath.Join(args[2], results[0][1])
			// gi := filepath.Join(fix, ".gitignore")
			// if _, err := os.Stat(fix); !os.IsNotExist(err) {
			// 	return makeFileIfNotExist(gi)
			// }
			//
			// if err := os.Mkdir(fix, 0777); err != nil {
			// 	return err
			// }
			//
			// return makeFileIfNotExist(gi)

			return nil
		})
	},
}

func init() {
	fizzMigrationsTestsCmd.AddCommand(fizzMigrationsTestsSyncCmd)
}
