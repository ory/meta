Unfortunately, for some reason, the CircleCI tests are not running. Do you maybe follow your/a fork of this repository on
CircleCI? If so, you need to unsubscribe / unwatch from that CircleCI project. Then, make another push to your branch using:

```
$ git commit --amend --allow-empty
$ git push --force
```

That should get the CI running! Thank you :)
