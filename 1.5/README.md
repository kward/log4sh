# log4sh
log4sh is an advanced logging framework for shell scripts (eg. sh, bash) that
works similar to the logging products available from the Apache Software
Foundataion (eg. log4j, log4perl).

The main source code is the single [src/log4sh](src/log4sh) file, which can be
copied to a destination of your choice, and used without any other files from
this source repository. The remaining files in `src/` are for unit testing.

Documentation for log4sh is available as [doc/log4sh.md](doc/log4sh.md). The
`doc/` folder holds additional supporting documentation.

## Testing the code

To test the, shUnit2 unit tests are included. Prepare the test environment, and
then you can run the tests. Hopefully all of the tests will pass with a 100%
success rate.

```
$ make test-prep
$ cd test
$ ./run-test-suite
```

## Related documentation

- Logging
  - [log4j](http://logging.apache.org)
- Syslog
  - [Introduction to the Syslog Protocol](http://www.monitorware.com/Common/en/Articles/syslog-described.php)
  - [The BSD syslog Protocol](http://www.ietf.org/rfc/rfc3164.txt)
- Unit testing
  - [JUnit](http://www.junit.org)
