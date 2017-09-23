# log4sh

log4sh is an advanced logging framework for shell scripts (eg. sh, bash) that
works similar to the logging products available from the Apache Software
Foundataion (eg. log4j, log4perl).

log4sh provides different releases so that users can depend on functionality
within a release series. It uses a variant of the X.Y.Z
[Semantic Versioning](http://semver.org/) system.

- X -- major release. Significant functionality has changed, and users of the
  code will definitely require changes to continue using it. These are
  extremely rare.
- Y -- minor release. New functionality was added. To maintain stability for
  users, stable releases are numbered with even numbers (e.g. 1.4), with
  development releases numbered with odd numbers (e.g. 1.5). Development
  releases possibly include functionality that breaks backwards compatibility.
- Z -- patch release. Bug fixes, and minor new functionality that remains 100%
  backwards compatible.

log4sh was originally hosted on Source Forge as
https://sourceforge.net/p/log4sh/. It moved here in Sep 2017 to be hosted
alongside the other projects by @kward (https://github.com/kward).
