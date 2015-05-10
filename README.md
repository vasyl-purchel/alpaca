# AlpacaBuildTool

[![Build Status](https://travis-ci.org/vasyl-purchel/alpaca.svg?branch=master)](https://travis-ci.org/vasyl-purchel/alpaca)
[![Dependency Status](https://gemnasium.com/vasyl-purchel/alpaca.svg)](https://gemnasium.com/vasyl-purchel/alpaca)
[![Coverage Status](https://coveralls.io/repos/vasyl-purchel/alpaca/badge.svg?branch=master)](https://coveralls.io/r/vasyl-purchel/alpaca?branch=master)
[![Code Climate](https://codeclimate.com/github/vasyl-purchel/alpaca/badges/gpa.svg)](https://codeclimate.com/github/vasyl-purchel/alpaca)
[![Inline docs](https://inch-ci.org/github/vasyl-purchel/alpaca.svg)](http://inch-ci.org/github/vasyl-purchel/alpaca)
[![Gem Version](https://badge.fury.io/rb/alpacabuildtool.svg)](http://badge.fury.io/rb/alpacabuildtool)

<p align="center">
  <img src="https://raw.githubusercontent.com/vasyl-purchel/alpaca/master/lib/alpacabuildtool/data/logo.jpg" alt="Logo"/>
</p>

**AlpacaBuildTool** is a Ruby gem with **alpaca** command line interface that
helps to work with C# Visual Studio solutions

Most aspects of its behavior can be tweaked via various
[configuration options][1]
or via _alpaca configure_ command

- [Installation](#installation)
- [Basic usage](#basic-usage)
- [Configuration](#configuration)
    - [Inheritance](#inheritance)
    - [Defaults](#defaults)
    - [User wide](#user-wide)
    - [Solution specific](#solution-specific)
- [Default tools](#tools)
- [Compatibility](#compatibility)
- [Contribution](#contribution)
    - [Pull requests](#pull-requests)
- [Changelog](#changelog)
- [Copyright](#copyright)

## Installation

Install gem:

   ```
   $ gem install alpacabuildtool
   ```

## Basic Usage

   ```
   SYNOPSIS
       alpaca [global options] command [command options] [arguments...]

   GLOBAL OPTIONS
       --help            - Show this message
       -p, --pattern=arg - Solutions search pattern (default: **/*.sln)
       --version         - Display the program version

   COMMANDS
       compile   - Compile solution[s]
       configure - Configure alpaca to your needs
       help      - Shows a list of commands or help for one command
       pack      - Create packages for solution[s]
       release   - Release packages for solution[s]
       report    - Generate reports for solution[s]
       test      - Test solution[s]
       update    - Update solution[s] versions
   ```

Run `$ alpaca compile` and by default *alpaca* will search for all solutions
recurcively in current folder and compile all of them unless they have
*nobuild* tag in a name(`no_build: ['.nobuild']`)

It is safe to run alpaca from solution folder or any parent folders
If you want to build only specific solution then use global option
`$ alpaca -p '**/Cool.sln' compile`

Check `$ alpaca command --help` for help on each command

## Configuration

### Inheritance

Alpaca's configuration has 3 levels - default, global, local.
Local configuration has the highest priority so it can override any property
from other configurations. Global configuration can override only default
configuration.

### Defaults

Default configuration _(lib/data/.alpaca.conf)_ is stored with installing gem
so alpaca can work out of the box.
It shouldn't be changed as it will get overriden after gem updated

You can check it's defaults [here][1]

### User Wide

Global configuration _(~/.alpaca.conf)_ can be created manually or
with a help of `alpaca configure global ...`
You can use it to store user wide configuration to apply some tweaks of
default configuration to all your solutions

Check [default configuration][1]
for full explanation of structure and examples

### Solution Specific

Local configuration _(#{solution-folder}/.alpaca.conf)_ can be created
manually or with a help of `alpaca configure local ...`
You can use it to store solution specific configuration like nuget packages
to be created from solution or reports names.

Also you can change default path to local configuration by setting

   ```yaml
   local_configuration:        'any/relative/path/to/local/configuration'
   ```

_this example will put your local configuration into_
`#{solution-folder}/any/relative/path/to/local/configuration` _file_

Common usage for local configuration would be nuget packages

#### Example

   ```yaml
   packages:
      - id:          "Package.Unique.Id"
        type:        :tool
        project:     "Console.Tool"
        source:      "tools-repository"
        description: "Tool to make cool stuff"
   ```

#### Notes

If you need to use tool on multi os then you may want to have different values
for executables path's so you can use:

   ```
   field:
     :windows: value1
     :linux:   value2
   ```

For packages:

Mandatory fields: `id`, `type`, `project`, `source`, `description`, `authors`
Optional fields: `title`, `licenseUrl`, `projectUrl`, `copyright`, `iconUrl`,
                 `requireLicenseAcceptance`, `releaseNotes`, `tags`, `owners`

Store common fields in global configuration under *all_packages* field

You can use types:

* `:tool` - to put all files from project/bin/[Configuration]/ folder
  into tools/
* `:project` - to create usual nuget package from Project.csproj

## Tools

* MSBuild (C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe)
  _for compilation_
* Nuget (C:\Nuget\Nuget.exe)
  _for package management_
* NUnit (NUnit.Console latest pre-release nuget package)
  _for tests_
* OpenCover (OpenCover latest release nuget package)
  _for coverage_
* NUnitOrange (NUnitOrange latest release nuget package)
  _for nunit tests result convertion to html_
* ReportGenerator (ReportGenerator latest release nuget package)
  _for OpenCover result convertion to html_

## Compatibility

Alpaca is tested on travis-ci.org with following Ruby implementations:

* MRI 1.9.3
* MRI 2.0
* MRI 2.1
* MRI 2.2

## Contribution

If you discover issues, have ideas for improvements or new features,
please report them to me <vasyl.purchel@gmail.com> or submit a pull
request. Please, try to follow these guidelines when you do so.

### Rake tasks

   ```
   rake build                # Build alpacabuildtool-1.0.0.rc.gem
                             #   into the pkg directory.
   rake clean                # Remove any temporary products.
   rake clobber              # Remove any generated file.
   rake clobber_rdoc         # Remove RDoc HTML files
   rake coverage             # Run RSpec with code coverage
   rake features             # Run Cucumber features
   rake install              # Build and install alpacabuildtool gem
                             #   into system gems.
   rake install:local        # Build and install alpacabuildtool gem
                             #   into system gems without network access.
   rake rdoc                 # Build RDoc HTML files
   rake release              # Create tag v{VERSION} and build and
                             #   push alpacabuildtool gem to Rubygems
                             #   To prevent publishing in Rubygems
                             #   use `gem_push=no rake release`
   rake rerdoc               # Rebuild RDoc HTML files
   rake rubocop              # Run RuboCop
   rake rubocop:auto_correct # Auto-correct RuboCop offenses
   rake test                 # Run RSpec code examples
   ```

### Pull requests

* Read [how to properly contribute to open source projects on Github][2].
* Fork the project.
* Write [good commit messages][3].
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it
  in a future version unintentionally.
* Add an entry to the [Changelog](CHANGELOG) accordingly.
* [Squash related commits together][4].
* Open a [pull request][5]

## Changelog

Alpaca's changelog is available [here](CHANGELOG).

## Copyright

Copyright (c) 2015 Vasyl Purchel. See [LICENSE](LICENSE) for further details.

[1]: https://github.com/vasyl-purchel/alpaca/blob/master/lib/alpacabuildtool/data/.alpaca.conf
[2]: http://gun.io/blog/how-to-github-fork-branch-and-pull-request
[3]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[4]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[5]: https://help.github.com/articles/using-pull-requests