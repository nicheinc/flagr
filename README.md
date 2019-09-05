# flagr
Implements command-line flag parsing in R

# Table of Contents

- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic](#basic)

## About <a name="about"></a>

Although it's fun to play with R in its REPL environment using RStudio or an
interactive R session in your shell, sometimes its necessary to execute an R
utility via the command line. `flagr` lets you write a job or script using R's
strong statistical capabilities and invoke it using the command line.

This is useful if you want to specify environment configurations, model
parameters, file locations, etc.

## Installation <a name="installation"></a>

Unfortunately this package has not yet been submitted to CRAN. However, you can
use `devtools` to install the package from GitHub:

```R
library(devtools)
devtools::install_github("nicheinc/flagr")
```

## Usage <a name="usage"></a>

### Basic <a name="basic"></a>

`test.R` provides a minimal example of a script that might use `flagr`. Instead
of sourcing the code, typical uses would load the library. For example, we
might have a script like

```R
library(flagr)

flagr <- flagr()

echo <- flagr$add_flag(
  name="echo",
  type="character",
  description="Value to echo",
  default="echo...echo...echo"
)

flagr$parse()

cat(paste0(echo, "\n"))
```

In a shell (pick your favorite), running the script would mean issuing

```sh
$ Rscript test.R --help
```

which will produce the usage message:

```sh
Usage of flagr:
-help (h) logical
    Show usage (default FALSE)
-echo character
    Value to echo (default echo...echo...echo)
```

Without asking for `help`, a typical run would look like

```sh
$ Rscript test.R 
echo...echo...echo
$
```
which prints the default value of the `echo` argument. You could also specify
the value you want to get echoed back:

```sh
$ Rscript test.R --echo pickles
pickles
$
```
or
```sh
$ Rscript test.R -echo cherry pickles
cherry
 pickles
$
$ Rscript test.R -echo "cherry pickles"
cherry pickles
$
```
or
```sh
$ Rscript test.R -echo "${PATH}"
/home/nicheinc/go/bin:/usr/local/go/bin:/home/nicheinc/.local/bin:/home/nicheinc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/nicheinc/bin
```

The first example illustrates basic usage in which we want the program to print
exactly what we passed in to the `--echo` flag.

The second example shows how `flagr` supports single dash (`-`) flags as well
as double dash flags (`--`).  It also shows how `flagr` automatically
vectorizes arguments that are separated by a space; printing the whole string
`cherry pickles` on one line requires you to enclose it in quotes, otherwise
the `paste0(echo, "\n")` will concatenate the vector `echo=c("cherry", "
pickles")` with the new line character so that you get `cherry\n pickles\n`.

The last example shows how you can pass in variables you have defined in your
shell.
