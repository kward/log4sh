# Making a release

The log4sh project is hosted on GitHub as https://github.com/kward/log4sh. (The project was previously hosted on SourceForge as http://sf.net/projects/log4sh).

For these steps, it is assumed we are working with release 1.3.6.

Steps:

* Run the unit tests.
* Write release notes.
* Update version.
* Flesh out the changelog.
* Insure all the code is checked in.
* Create the release
* Update website.
* Post release to GitHub.

## Run the unit tests

Run make with the 'test-prep' option to create the `test/` directory. Change
there and run the tests. Record the output into the
`website/testresults/<version>/` directory so that they can be posted to the
website. Repeat this for each of the supported OSes.

```
$ make test-prep
...
$ cd test
$ ./run-test-suite 2>&1 |tee .../testresults/1.3.7/Linux-Ubuntu_Edgy-6.10.txt
...
```

## Write release notes

Use one of the release notes from a previous release as a template.

To get the versions of the various shells, run the `lib/versions` tool. Those below still require manual effort.

- Cygwin
  - bash:  `$ bash --version`
  - ksh:   actually `pdksh`
  - pdksh: look in the downloaded Cygwin directory
- Solaris 10
  - sh:    not possible
  - bash:  `bash --version`
  - ksh:   `strings /usr/bin/ksh |grep 'Version'`

## Update version

Edit the `src/log4sh` source code, and change the version number in the comment, as well as in the `__LOG4SH_VERSION` variable. Next, edit the version number at the top of the `doc/log4sh.md` file.

## Finish documentation

Make sure that any remaining changes get put into the `CHANGES.md` file.

Finish writing the `RELEASE_NOTES-X.Y.Z.md`.

We want to have an up-to-date version of the documentation in the release, so
we'd better build it.

**TODO(kward):** Update all commands below here when making the next release. These are still focused on DocBook and SourceForge, not Markdown and GitHub.

```
$ pwd
.../log4sh/source/1.3
$ make docs
...
$ cp -p build/log4sh.html doc
$ svn ci -m "" doc/log4sh.html
```

## Check in all the code

This step is pretty self-explanatory

## Create release

Tag the release.

```
$ pwd
.../log4sh/source
$ ls
1.2  1.3
$ svn cp -m "Release 1.3.6" \
1.3 https://log4sh.svn.sourceforge.net/svnroot/log4sh/tags/source/1.3.6
```

Export a clean version of the code.

```
$ pwd
.../log4sh/builds
$ svn export \
https://svn.sourceforge.net/svnroot/log4sh/tags/source/1.3.6 log4sh-1.3.6
```

Create a tarball.

```
$ tar cfz ../releases/log4sh-1.3.6.tgz log4sh-1.3.6
```

Run `md5sum` on the tarball, and sign with `gpg`.

```
$ cd ../releases
$ md5sum log4sh-1.3.6.tgz >log4sh-1.3.6.tgz.md5
$ gpg --default-key kate.ward@forestent.com --detach-sign log4sh-1.3.6.tgz
```

## Update the root README.md

Reflect the most recent release made with a link to the release page.
