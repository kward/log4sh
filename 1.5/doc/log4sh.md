# log4sh 1.5.x

**Author:** Kate Ward<br/>
**Email:** kate.ward@forestent.com

log4sh is a logging framework for shell scripts that works similar to the other wonderful [logging products](http://logging.apache.org/) available from the [Apache Software Foundation](http://www.apache.org/) (e.g. log4j, log4perl). Although not as powerful as the others, it can make the task of adding advanced logging to shell scripts easier, and has much more power than basic "echo" commands. In addition, it can be configured from a `.properties` file so that scripts in a production environment do not need to be altered to change the amount of logging they produce.

## Introduction

log4sh has been developed under the Bourne Again Shell (`bash`) on macOS, but great care has been taken to make sure it works under various Unix shells across multiple platforms.

**Tested Operating Systems**

- [Cygwin](http://www.cygwin.com/) (under Windows 7)
- [FreeBSD](http://www.freebsd.org/) ([FreeNAS 11](freenas.org))
- Linux ([Gentoo](http://www.gentoo.org/), [Ubuntu](http://www.ubuntu.com))
- [macOS](http://www.apple.com/macosx/) (and Mac OS X)
- [Solaris](http://www.sun.com/software/solaris/) 8, 9, 10

**Tested Shells**

- Bourne Shell (`sh`)
- [BASH](http://www.gnu.org/software/bash/) - GNU Bourne Again SHell (`bash`)
- [DASH](http://gondor.apana.org.au/~herbert/dash/) (`dash`)
- [Korn Shell](http://www.kornshell.com/) (`ksh`)
- [pdksh](https://directory.fsf.org/wiki/Pdksh) - Public Domain Korn Shell (`pdksh`)

### Credits / Contributors

A list of contributors to log4sh can be found in the source archive as `doc/contributors.txt`. I want to personally thank all those who have contributed to make this a better tool.

### Feedback

Feedback is most certainly welcome for this document. Send your additions, comments and criticisms to kate.ward@forestent.com.

## Quickstart

First things first. Go to the directory from which you extracted the log4sh software. In there, you should find a `Makefile`. If you find one, you are in the right place. We need to setup the environment for running tests, so from this directory, execute the `make test-prep` command as shown below. Once this is done, a `test` directory will be created and prepared with everything needed to run the log4sh tests.

Prepare your environment.

```
$ make test-prep
$ cd test
```

#### Hello, World!

OK. What kind of a quickstart would this be if the first example wasn't a "Hello, World!" example?  Who knows, but this isn't one of those kind of quickstarts.

Run the Hello World test.

```
$ ./hello_world
1 [main] INFO shell  - Hello, world!
```

You should have seen output similar to that above. If not, make sure you are in the right location and such. If you really had problems, please send a letter to the log4sh maintainers. Who knows, maybe you already found a bug. Hopefully not!

The Hello, World! test is about as simple as it gets. If you take a look at the test, all it does is load `log4sh`, reset the default logging level from `ERROR` to `INFO`, and the logs a "Hello, world!" message. As you can see, it didn't take much to setup and use log4sh.

#### Properties Configuration Test

In this example, a `log4sh.properties` configuration file will be used to preconfigure log4sh before any logging messages are output. It demonstrates that a configuration file can be used to alter the behavior of log4sh without having to change any shell code.

Run the properties configuration test.

```
$ ./test-prop-config
INFO - We are the Simpsons!
INFO - Mmmmmm .... Chocolate.
INFO - Homer likes chocolate
...
```

You should see much more output on your terminal that what was listed above. What is actually happening is log4sh is outputting information to STDERR using logging statements that were stored in the `test-common` script. In addition, there were multiple log files generated (take a look in the `test` directory), and output was written also written via Syslog. Take a look at both the property configuration script (`test-prop-config`) and the common script (`test-common`) if you would like to see what is happening. If you do, you will notice that nowhere in code was it configured to write to the any of those different locations. The `log4sh.properties` configuration file did all of that work for us. Go ahead and take a look at it too. You might be amazed with how easy it was to write to so many locations with such a small amount of code.

#### Runtime Configuration Test

This example is **exactly** like the last example as far as output is concerned (they both execute the same `test-common` script), but this one is configured instead at runtime with function calls. It demonstrates that log4sh is fully configurable at runtime.

Run the runtime configuration test.

```
$ ./test-runtime-config
INFO - We are the Simpsons!
INFO - Mmmmmm .... Chocolate.
INFO - Homer likes chocolate
...
```

You should again see much more output on your terminal that what was listed above. The output should also have been exactly the same (except that the times were different) as the above example. This is because the same logging commands were used. If you take a look a look in the `test-runtime-config` script though, you will see that this time log4sh was configured completely at runtime. The `log4sh.properties` was not used. It shows that log4sh can be fully configured without a preexisting configuration file. This isn't nearly as friendly as using the configuration file, but there are times when it is needed.

## Usage Guide

The usage of log4sh is simple. There are only a few simple steps required to setup and use log4sh in your application.

- Preconfigure log4sh by creating a properties file (optional).
- Source the log4sh script code into the shell script.
- Configure log4sh in code.
- Call logging statements.

### Preconfigure log4sh (optional)

To preconfigure log4sh, create a properties file (see the "Properties file" section later in this document). If the properties file is not located in the same directory as log4sh, set the `LOG4SH_CONFIGURATION` environment variable to the full path to the properties file.

### Source log4sh

To source the code into your script (known as "sourcing" or "including"), use the sourcing ability of shell to source one script into another. See the following quick example for how easy this is done.

*Sourcing external shell code into current program*

```shell
#! /bin/sh

# Source log4sh from current directory.
. ./log4sh
```

Here is some sample code that looks for log4sh in the same directory as the script is located, as well as the current directory. If log4sh could not be found, it exits with an error. If log4sh is found, it is loaded, along with the `log4sh.properties` file in the current directory. It then logs a message at the INFO level to `STDOUT`.

*Hello, world (using properties file)*

```shell
#! /bin/sh
#
# log4sh example: Hello, world
#
myDir=`dirname $0`

# Find and source log4sh.
if [ -r "$myDir/log4sh" ]; then
  log4shDir=$myDir
elif [ -r "./log4sh" ]; then
  log4shDir=.
else
  echo "fatal: could not find log4sh" >&2
  exit 1
fi
. $log4shDir/log4sh

# Say Hello to the world.
logger_info "Hello, world"
```

Here is the `log4sh.properties` file for the previous example. Save it in the same directory you are running the above script from.

*Hello, world; properties file*

```properties
#
# log4sh example: Hello, world properties file
#

# Set root logger level to INFO and its only appender to A1.
log4sh.rootLogger=INFO, A1

# A1 is set to be a ConsoleAppender.
log4sh.appender.A1=ConsoleAppender

# A1 uses a PatternLayout.
log4sh.appender.A1.layout=PatternLayout
log4sh.appender.A1.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n
```

### Configure log4sh in code

If log4sh was not preconfigured, the default configuration will be equivalent the config shown below.

Note: log4sh will complain if no configuration file was specified or found. If you meant for the default configuration to be used, or you want to configure log4sh via code, make sure to define the `LOG4SH_CONFIGURATION` with the value of 'none'.

```
log4sh.rootLogger=ERROR, stdout
log4sh.appender.stdout=ConsoleAppender
log4sh.appender.stdout.layout=PatternLayout
log4sh.appender.stdout.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n
```

To configure log4sh in code, simply call the appropriate functions in your code. The following code sample loads log4sh from the current directory, configures it for `STDERR` output, and the logs a message at the INFO level.

*Hello, world (configured in code)*

```shell
#! /bin/sh
#
# log4sh example: Hello, world
#

# Load log4sh (disabling properties file warning) and clear the default
# configuration.
LOG4SH_CONFIGURATION='none' . ./log4sh
log4sh_resetConfiguration

# Set the global logging level to INFO.
logger_setLevel INFO

# Add and configure a FileAppender that outputs to STDERR, and activate the
# configuration.
logger_addAppender stderr
appender_setType stderr FileAppender
appender_file_setFile stderr STDERR
appender_activateOptions stderr

# Say Hello to the world.
logger_info 'Hello, world'
```

### Logging with log4sh

Once log4sh is loaded, logging is as simple as calling the appropriate logging function with a message to be logged. Take a look at the above examples to see just how easy it was to log the statement "Hello, world" at an INFO level.

The samples above show the standard way of logging a message via log4sh. That standard method is by calling the appropriate function, and passing the message as a parameter.

*Standard method of logging a message*

```shell
logger_info 'message to log'
```

There is a second way of logging as well. The second method is via pipes. What this method is really good for is logging the standard output (`STDOUT`) of a command to the log file. Piping `echo` statements is a bit silly, but something like piping the output of a `ls` is more practical (e.g. `ls -l |logger_info`).

*Alternate method of logging a message*

```shell
echo 'message to log' |logger_info
```

## Configuration

### Properties file

log4sh can be configured with a properties file that is separate from the actual script where the logging takes place. By default, log4sh looks for its properties file called `log4sh.properties` in the current directory. If the file is located elsewhere or with a different name, log4sh can be configured by setting the `LOG4SH_CONFIGURATION` environment variable (eg. `LOG4SH_CONFIGURATION="/etc/log4sh.conf"`).

A `log4sh.properties` file that is completely empty is sufficient to configure log4sh. There will be absolutely no output however (which might just be what is desired). Usually though, some output is desired, so there is at least a recommended minimum configuration file. An explanation of the file follows the example.

*Recommended minimum `log4sh.properties` file*

```properties
log4sh.rootLogger=INFO, stdout
log4sh.appender.stdout=ConsoleAppender
```

In the first line, the root logger is configured by setting the default logging level, and defining the name of an appender. In the second line, the `stdout` appender is defined as a `ConsoleAppender`.

### Root Logger

(future)

### Levels

*Logging Levels (from most output to least)*

Level | Definition
----- | ----------
TRACE | The TRACE level has the lowest possible rank and is intended to turn on all logging.
DEBUG | The DEBUG level designates fine-grained informational events that are most useful to debug an application.
INFO | The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
WARN | The WARN level designates potentially harmful situations.
ERROR | The ERROR level designates error events that might still allow the application to continue running.
FATAL | The FATAL level designates very severe error events that will presumably lead the application to abort.
OFF | The OFF level has the highest possible rank and is intended to turn off logging.

### Appenders

An appender name can be any alpha-numeric string containing no spaces.

*Sample appender names*

Name        | Validity
----------- | --------
myAppender  | valid
my appender | invalid

### Types

An appender can be set to one of several different types.

*Setting an appender type*

```properties
log4sh.appender.A1=FileAppender
```

*Appender Types*

Type                     | Definition | Supported?
------------------------ | ---------- | ----------
ConsoleAppender          | Output sent to console (STDOUT). | yes
FileAppender             | Output sent to a file. | yes
DailyRollingFileAppender | Output sent to a file that rolls over daily. | partial; logs written, but not rotated
RollingFileAppender      | Output sent to a file that rolls over by size. | partial; works, but needs improvement
SMTPAppender             | Output sent via email. | parital; works, but needs improvement
SyslogAppender           | Output sent to a remote syslog daemon. | partial; only localhost supported

### Options

An appender can take several different options.

*Setting an appender option*

```properties
log4sh.appender.A1.File=output.log
```

*Appender Options*

Option         | Definition | Supported?
-------------- | ---------- | ----------
DatePattern    | Configure a pattern for the output filename. | no (ignored)
File           | Output filename (special filename of STDERR used for logging to STDERR). | yes
MaxBackupIndex | Number of old log files to keep. | no (ignored)
MaxFileSize    | Maximum size of old log files. | no (ignored)
Threshold      | Logging level of the appender. | yes

### Layouts

An appender can be configured with various Layouts to customize how the output looks.

*Setting an appender's layout*

```properties
log4sh.appender.A1.layout=PatternLayout
```
*Layouts*

Layout        | Definition | Supported?
------------- | ---------- | ----------
HTMLLayout    | Layout using HTML. | no (same as SimpleLayout)
SimpleLayout  | A simple default layout ('%p - %m') | yes
PatternLayout | A patterned layout (default: '%d %p - %m%n') | yes

An layout has many different options to configure how it appears. These are known as patterns.

*Setting an appender's layout pattern*

```properties
log4sh.appender.A1.layout.ConversionPattern=%d [%p] %c - %m%n
```

*Pattern Options*

Option | Definition | Supported?
------ | ---------- | ----------
c | Used to output the category of logging request. As this is not applicable in shell, the conversion character will always returns 'shell'. | partial (fixed)
d | Used to output the date of the logging event. The date conversion specifier may be followed by a **date format specifier** enclosed between braces, but this specifier will be ignored. For example, `%d{HH:mm:ss,SSS}`, or `%d{ISODATE}`. The specifier is allowed only for compatibility with log4j properties files.<br/><br/>The default format of the date returned is equivalent to the output of the Unix `date` command with a format of `+%Y-%m-%d %H:%M:%S`. | yes
F | Used to output the file name where the logging request was issued.<br/><br/>The default value is equivalent `basename $0`. | yes
L | This option is for compatibility with log4j properties files. | no (ignored)
m | Used to output the script supplied message associated with the logging event. | yes
n | This option is for compatibility with log4j properties files. | no (ignored)
p | Used to output the priority of the logging event. | yes
r | Used to output the number of seconds elapsed since the start of the script until the creation of the logging event. | yes
t | Used to output the current executing thread. As shell doesn't actually support threads, this is simply a value that can be set that can be put into the messages.<br/><br/>The default value is 'main'. | yes
x | This option is for compatibility with log4j properties files. | no (ignored)
X | Used to output the MDC (mapped diagnostic context) associated with the thread that generated the logging event. The `X` conversion character **must** be followed by an environment variable name placed between braces, as in `%X{clientNumber}` where `clientNumber` is the name of the environment variable. The value in the MDC corresponding to the environment variable will be output. | yes
% | The sequence `%%` outputs a single percent sign. | yes

### Environment variables

There are some environment variables that can be used to preconfigure log4sh, or to change some of its default behavior. These variables should be set before log4sh is sourced so that they are immediately available to log4sh.

Here is the full list of supported variables.

*log4sh environment variables*

Variable | Usage
-------- | -----
LOG4SH_CONFIGURATION | This variable is used to tell log4sh what the name of (and possibly the full path to) the configuration (a.k.a properties) file that should be used to configure log4sh at the time log4sh is sourced. If the value 'none' is passed, than log4sh will expect to be configured at a later time via run-time configuration.<br/><br/>E.g. `LOG4SH_CONFIGURATION='/path/to/log4j.properties'`
LOG4SH_CONFIG_PREFIX | This variable is used to tell log4sh what prefix it should use when parsing the configuration file. Normally, the default value is 'log4sh' (e.g. 'log4sh.rootLogger'), but the value can be redefined so that a configuration file from another logging frame work such as log4j can be read.<br/><br/>E.g. `LOG4SH_CONFIG_PREFIX='log4j'`

## Advanced usage

This chapter is dedicated to some more advanced usage of log4sh. It is meant to demonstrate some functionality that might not normally be understood.

### Environment variables

There are several environment variables that can be set to alter the behavior of log4sh. The full listing is below.

*log4sh Environment Variables*

Variable              | Default  | Description
--------------------- | -------- | -----------
LOG4SH_ALTERNATIVE_NC | *none*   | Provide log4sh with the absolute path to the `nc` (netcat) command -- e.g. `/bin/nc`
LOG4SH_CONFIGURATION  | *none*   | Provide log4sh with the absolute path to the log4sh properties file.
LOG4SH_CONFIG_PREFIX  | `log4sh` | Define the expected prefix to use for parsing the properties file -- e.g. `log4j`
LOG4SH_DEBUG          | *none*   | Enable internal log4sh debug output. Set to any non-empty value.
LOG4SH_DEBUG_FILE     | *none*   | Define a file where all internal log4sh trace/debug/info output will be written to -- e.g. `log4sh_internal.log`
LOG4SH_INFO           | *none*   | Enable internal log4sh info output. Set to any non-empty value.
LOG4SH_TRACE          | *none*   | Enable internal log4sh trace output. Set to any non-empty value.

### Remote Syslog logging

Logging to a remote syslog host is incredibly easy with log4sh, but it is not functionality that is normally exposed to a shell user. The `logger` command, which is used for local syslog logging, unfortunately does not support logging to a remote syslog host. As such, a couple of choices are available to enable logging to remote hosts.

Choice #1 -- reconfigure the `syslogd` daemon

One can alter the configuration of the local syslog daemon, and request that certain types of logging information be sent to remote hosts. This choice requires no extra software to be installed on the machine, but it does require a reconfiguration of the system-wide syslog daemon. As the syslog daemon is different between operating systems, and even between OS releases, no attempt will be made to describe how to do this in this document. Read the respective `man` page for your particular system to learn what is required.

Choice #2 -- install `nc` (netcat) command -- **recommended**

The `nc` (netcat) command has the ability to generate the UDP packet to port 514 that is required for remote syslog logging. If you have this command installed, you can tell log4sh that this **alternative** command exists, and then you will be able to use the `appender_syslog_setHost()` function as you would expect.

The examples below show what a minimum properties file or a minimum script should look like that do remote syslog logging.

*Sample log4sh properties file demonstrating remote syslog logging*

```properties
#
# log4sh example: remote syslog logging
#

# Set the 'nc' alternative command to enable remote syslog logging.
log4sh.alternative.nc = /bin/nc

# Set root logger level to INFO and its only appender to mySyslog.
log4sh.rootLogger=INFO, mySyslog

# mySyslog is set to be a SyslogAppender.
log4sh.appender.mySyslog = SyslogAppender
log4sh.appender.mySyslog.SyslogHost = somehost
```

*Sample shell script demonstrating remote syslog logging*

```shell
#! /bin/sh
#
# log4sh example: remote syslog logging
#

# Load log4sh (disabling properties file warning) and clear the default
# configuration.
LOG4SH_CONFIGURATION='none' . ./log4sh
log4sh_resetConfiguration

# Set alternative 'nc' command.
log4sh_setAlternative nc /bin/nc

# Add and configure a SyslogAppender that logs to a remote host.
logger_addAppender mySyslog
appender_setType mySyslog SyslogAppender
appender_syslog_setFacility mySyslog local4
appender_syslog_setHost mySyslog somehost
appender_activateOptions mySyslog

# Say Hello to the world.
logger_info 'Hello, world'
```

### Automated file rolling

Logging is great, but not when it runs you out of hard drive space. To help prevent such situations, log4sh has automated file rolling built in. By changing your `FileAppender` into a `RollingFileAppender`, you enable automatic rolling of your log files. Each log file will be rolled after it reaches a maximum file size that you determine, and you can also decide the number of backups to be kept.

To limit the maximum size of your log files, you need to set the `MaxFileSize` appender option in a properties file, or use the `appender_file_setMaxFileSize()` function. The maximum size is specified by giving a value and a unit for that value (e.g. a 1 megabyte log file can be specified as '1MiB', '1024KiB', or '1048576B'). Note, the unit must be specified with the proper case, i.e. a unit of 'KB' is correct 'kb' is not.

The default maximum file size is equivalent to 1MiB.

*Acceptable file size units*

Unit            | Bytes             | Equivalent sizes
--------------- | ----------------- | ----------------
B (bytes)       |                 1 | 1B
KB (kilobytes)  |             1,000 | 1 KB = 1000B
KiB (kibibytes) |             1,024 | 1KiB = 1024B
MB (megabytes)  |         1,000,000 | 1MB = 1000KB
MiB (mebibytes) |         1,048,576 | 1MiB = 1024KiB
GB (gigabytes)  |     1,000,000,000 | 1GB = 1000MB
GiB (gibibytes) |     1,073,741,824 | 1GiB = 1024MiB
TB (terabytes)  | 1,000,000,000,000 | 1TB = 1000GB
TiB (tebibytes) | 1,099,511,627,776 | 1TiB = 1024GiB

**Note:** log4sh differs from log4j in the interpretation of its units. log4j assumes that all units are base-2 units (i.e. that KB = 1024B), where as log4sh makes a distinction between the standard SI units of KB (base-10 ~ 1000B = 10^3) and KiB (base-2 ~ 1024B = 2^10). If this causes problems, call the `log4sh_enableStrictBehavior()` once after loading log4sh to force the unit interpretation to be like log4j.

To limit the maximum number of backup files kept, you need to set the `MaxBackupIndex` appender option in a properties file, or use the `appender_file_setMaxBackupIndex()` function. Whenever a file has reached the point of needing rotation, log4sh will rename the current log file to include an extension of `.0`, and any other backups will have their extension number increased as well. With a maximum backup index of zero, no backups will be kept.

The default maximum backup index is equivalent to 1MiB.

*Sample log4sh properties file demonstrating a RollingFileAppender*

```properties
#
# log4sh example: Using the RollingFileAppender
#

# Set root logger level to INFO and its only appender to R.
log4sh.rootLogger=INFO, R

# Add a RollingFileAppender named R.
log4sh.appender.R = RollingFileAppender
log4sh.appender.R.File = /path/to/some/file
log4sh.appender.R.MaxFileSize = 10KB
log4sh.appender.R.MaxBackupIndex = 1
```

*Sample shell script demonstrating a RollingFileAppender*

```shell
#! /bin/sh
#
# log4sh example: Using the RollingFileAppender
#

# Load log4sh (disabling properties file warning) and clear the default
# configuration.
LOG4SH_CONFIGURATION='none' . ./log4sh
log4sh_resetConfiguration

# Add and configure a RollingFileAppender named R.
logger_addAppender R
appender_setType R RollingFileAppender
appender_file_setFile R '/path/to/some/file'
appender_file_setMaxFileSize R 10KB
appender_file_setMaxBackupIndex R 1
appender_activateOptions R

# Say Hello to the world.
logger_info 'Hello, world'
```

## Conclusion

The idea of log4sh is obviously not novel, but the availability of such a powerful logging framework that is available in (nearly) pure shell is. Hopefully you will find it useful in one of your projects as well.

If you like what you see, or have any suggestions on improvements, feel free to drop me an email at kate.ward@forestent.com.

log4sh is licensed under the Apache 2.0 license. The contents and copyright of this document and all provided source code are owned by Kate Ward.
