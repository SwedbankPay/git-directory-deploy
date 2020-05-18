# Git Directory Deploy

This repository contains a `deploy.sh` script for deploying generated files to a
git branch, such as when building a single-page app using [Yeoman][yeoman] or
[Jekyll][jekyll] and deploying to [GitHub Pages][gh-pages]. Unlike the
[git-subtree approach][git-subtree], it does not require the generated files be
committed to the source branch. It keeps a linear history on the deploy branch
and does not make superfluous commits or deploys when the generated files do not
change.

![Test status][test-badge]

For an example of use, see [X1011/verge-mobile-bingo][verge-mobile-bingo]. For
development info, see [contributing.md][contributing].

## Configuration

Download the script and make it executable. It can be done with `wget` and
`chmod` as follows:

```shell
wget https://raw.githubusercontent.com/SwedbankPay/git-directory-deploy/1.0.0/deploy.sh
chmod +x deploy.sh
```

Replace `1.0.0` in the URL with whatever version number of `deploy.sh` you would
like. Pinning to a Git tag instead of `master` ensures that no breaking changes
are pulled down unintentionally.

Then and edit these variables within it as needed to fit your project:

- **`deploy_directory`**: root of the tree of files to deploy
- **`deploy_branch`**: branch to commit files to and push to origin
- **`default_username`**, **`default_email`**: identity to use for git commits
  if none is set already. Useful for CI servers.
- **`repo`**: repository to deploy to. Must be readable and writable. The
  default of "origin" will not work on Travis CI, since it uses the read-only
  git protocol. In that case, it is recommended to store a [GitHub
  token][gh-token] in a [secure environment variable][secure-env] and use it in
  an HTTPS URL like this:
  <code>repo=https://$GITHUB_TOKEN@github\.com/<i>user</i>/<i>repo</i>.git</code>
  **Warning: there is currently [an issue][issue-7] where the repo URL may be
  output if an operation fails.**

You can also define any of variables using environment variables and configuration files:

- `GIT_DEPLOY_DIR`
- `GIT_DEPLOY_BRANCH`
- `GIT_DEPLOY_REPO`

The script will set these variables in this order of preference:

1. Defaults set in the script itself.
2. Environment variables.
3. `.env` file in the path where you're running the script.
4. File specified on the command-line (see the `-c` option below).

Whatever values set later in this list will override those set earlier.

## Run

Do this every time you want to deploy, or have your CI server do it.

1. check out the branch or commit of the source you want to use. The script will
   use this commit to generate a message when it makes its own commit on the
   deploy branch.
2. generate the files in `deploy_directory`
3. make sure you have no uncommitted changes in git's index. The script will
   abort if you do. (It's ok to have uncommitted files in the work tree; the
   script does not touch the work tree.)
4. if `deploy_directory` is a relative path (the default is), make sure you are
   in the directory you want to resolve against. (For the default, this means
   you should be in the project's root.)
5. run `./deploy.sh`

### Options

`-h`, `--help`: show the program's help info.

`-c`, `--config-file`: specify a file that overrides the script's default
configuration, or those values set in `.env`. The syntax for this file should be
normal `var=value` declarations. __This option _must_ come first on the
command-line__.

`-m`, `--message <message>`: specify message to be used for the commit on
`deploy_branch`. By default, the message is the title of the source commit,
prepended with 'publish: '.

`-n`, `--no-hash`: don't append the hash of the source commit to the commit
message on `deploy_branch`. By default, the hash will be appended in a new
paragraph, regardless of whether a message was specified with `-m`.

`-v`, `--verbose`: echo expanded commands as they are executed, using the xtrace
option. This can be useful for debugging, as the output will include the values
of variables that are being used, such as $commit_title and $deploy_directory.
However, the script makes special effort to not output the value of $repo, as it
may contain a secret authentication token.

`-e`, `--allow-empty`: allow deployment of an empty directory. By default, the
script will abort if `deploy_directory` is empty.

[yeoman]: http://yeoman.io
[jekyll]: https://jekyllrb.com/
[gh-pages]: http://pages.github.com
[git-subtree]: https://github.com/yeoman/yeoman.io/blob/source/app/learning/deployment.md#git-subtree-command
[test-badge]: https://github.com/SwedbankPay/git-directory-deploy/workflows/Test/badge.svg
[verge-mobile-bingo]: https://github.com/X1011/verge-mobile-bingo
[contributing]: contributing.md
[gh-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use
[secure-env]: http://docs.travis-ci.com/user/environment-variables/#Secure-Variables
[issue-7]: https://github.com/X1011/git-directory-deploy/issues/7
