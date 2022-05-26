Thank you, this looks great! It looks like the CLA bot is not properly detecting your signature. To fix this, try the following:

```
$ git commit  --amend --author="Author Name <email@address.com>"
```

Ensure that `Author Name` is replaced with your GitHub username (e.g. `aeneasr`) and that the email address is replaced with the
email address you have set up in GitHub (e.g. `3372410+aeneasr@users.noreply.github.com`):

```
$ git commit  --amend --author="aeneasr <3372410+aeneasr@users.noreply.github.com>"
```

Once that is done, you can force-push your changes (make sure to push to the correct remote and branch!):

```
$ git push --force <remote> HEAD:<branch>
```
