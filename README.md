![Continuous Integration](https://github.com/ClementLavergne/shared-pancake/workflows/Continuous%20Integration/badge.svg)

# shared-pancake 🥞 user's guide

Management of templated documents written in a *customizable* `Markdown` syntax, for:

* Focusing on content only
* Using centralized data to avoid redundancy (e.g. abbreviations, terms, references)
* Generating multiple markup formats (e.g. html, pdf, docx)
* Adding specific features to your project (e.g. auto-generation of objects)
* Taking advantage of existing code workflows

> This tool may be considered as a [pandoc](https://github.com/jgm/pandoc) framework.
> `Pandoc's markdown` syntax is then used by default.

---

## How-to

### Create a new project

`shared-pancake` allows you to create your own project structure through a `YAML` configuration file. However, this file shall match the [default files](https://pandoc.org/MANUAL.html#default-files) format expected by `pandoc`.

A project can manage multiple sources and output generation, it's up to you! 🤓

That's why `shared-pancake` defines two category of configuration files:

* A **source configuration file**
* A **template configuration file**

> For instance, the `example/` project owns **skeleton** and **tutorial** sources with different configuration files. This project is a good starting point to figure out how the tool actually works.

#### Source configuration file

Let's have a look to the `example/tutorial-custom.yml` one:

```yaml
metadata:
    title:          How to write documents?
    subtitle:       Introduction
    description: |
                    This document describes briefly how
                    to use the tool.
    category:       Tutorial
    version:        0.2.0
    targets:
        latex:      template/latex-custom.yml
        json:       template/json-default.yml
        native:     template/native-default.yml
        html:       template/html-custom.yml
        pdf:        template/pdf-custom.yml
        docx:       template/docx-default.yml

input-files:
    - source/tutorial/markdown/introduction.md
    - source/tutorial/markdown/basics.md
    - source/tutorial/markdown/tables.md
    - source/tutorial/markdown/code-blocks.md
    - source/tutorial/markdown/macros.md
    - source/tutorial/markdown/textual-diagrams.md

metadata-files:
    - meta/abbreviations.yml
    - meta/terms.yml
    - meta/references.yml
    - source/tutorial/meta/revisions.yml

filters:
    - script/generic-table/generic-table.lua
    - script/plantuml-diagram/plantuml-diagram.lua
    - script/show-unnumbered-toc/show-unnumbered-toc.lua

resource-path: [".","source/tutorial/markdown"]
```

A **source configuration file** provides relevant information for generating your document:

* Metadata (raw or files)
* Markdown files and their processing order
* Relevant folders for relative paths
* Specific filters
* ... and more

In order to provide versatility, the `targets` metadata is mandatory to work properly with `shared-pancake`! Thanks to it, you can define expected markup formats with corresponding templates.

#### Template configuration file

Considering the previous **source configuration file**, the **html** markup format uses the **template file** located at `example/template/html-custom.yml`:

```yaml
template:   template/source/pandoc-template.html

input-files:
    - template/markdown/preamble.md

css:
    - template/theme/custom-style.css

highlight-style:    template/theme/code-block.theme
preserve-tabs:      true
self-contained:     true
toc:                true
toc-depth:          3
```

A **template file** can be shared by multiple documents, that's why it is entirely specific to your project. However, this file shall - at least - define the corresponding source for the selected markup format.
In that case, the `template` metadata uses a file which has a `.html` extension.

> For PDF generation, it depends of the selected engine. Our example renders thanks to a `LaTeX` template, but there are other ways.

### Create a new template

As described before, a **template** file is required for the generation of a given markup format.

You can start creating your own from scratch or from a default one:

```bash
pandoc -D FORMAT > FILE
```

Make sure to make things coherent!

### Enrich the Markdown syntax

`pandoc` translates any input markup format to an intermediate *Abstract Syntax Tree* one (AST).
Scripts called *filters* are executed in a specific order to apply modification to such **AST** format before generating the desired output file.

Those **filters** enable smart generation of output formats and must be written in `lua`; more information [here](https://pandoc.org/filters.html) and [here](https://pandoc.org/lua-filters.html). A [Github repository](https://github.com/pandoc/lua-filters) already lists interesting `lua` filters.

It is possible to create a new filter and append it to your project through a **configuration file**; this is really powerful and enables infinite possibilities.

### Limitations

#### Relative paths from configuration file

As default files does not manage relative paths, each path should be relative to a common starting point, e.g `example/` is defined as the **project path**.

> This limitation may disappear soon with next `pandoc` releases.

#### Pandoc filters

##### Selecting a markup format

The following syntax from a **configuration file** is not supported yet:

```yaml
filters:
    - type: latex
      path: filter/lookup-function.lua
```

##### Python filters with Docker image

There is no support of `Python` from the Docker image, please use `Lua` ones instead!

## Command-line options

`shared-pancake` automates `pandoc` calls through a **Makefile**.

### COMMAND

The expected command line - noted as **COMMAND** - have the following pattern:

```bash
make [TARGET] [ARGUMENTS]
```

Things within brackets are considered as *optionnals*. If nothing is provided, the tool will execute a default command related to the `example/` project.

> This is a good way to debug tool installation. Generated files will be located into `generated/` folder.

### TARGET

According to defined markup formats from the **source configuration file**, the following targets are available:

| Target | Expected value |
| --- | ---------|
| `all` | Generate each markup format; default target |
| `<FORMAT>` | Generate the selected markup format |
| `clean-<FORMAT>` | Clean generated files related to a markup format only |
| `clean` | Clean all generated files |

### ARGUMENTS

| Argument | Expected value | Default value |
| --- | ---------| ----- |
| `PRJ_PATH`| Absolute path to a project folder | example |
| `OUT_PATH`| Absolute path to desired output location | generated |
| `SRC_FILE`| Relative path from `PRJ_PATH` to selected **source configuration file** | source/tutorial-custom.yml |

## Installation

### Docker-based

This installation process is *highly* encouraged for many reasons:

* Out-of-the-box solution
* Avoid polluting your machine with required software and environment variables
* Be aligned with *Continuous Integration* (CI/CD) jobs
* Be always up to date
* Manage multiple versions of the tool

Obviously, [Docker](https://www.docker.com) is required on your operating system. Follow the steps described online. Once done, make sure the `Docker` engine is running on your machine.

#### IMAGE

As the `Docker` image is not yet available online, you can generate it locally from the *Dockerfile*:

```bash
docker build -t shared-pancake:1.0.0 .
```

The `shared-pancake:1.0.0` image should be available when executing this command:

```bash
docker images
```

#### Executing

There are plenty ways to invoke the `Makefile` through a container.

The following command can be run anywhere; it instantiates a new container using **IMAGE**, shares a volume with the *host* and executes the **COMMAND** before being deleted:

```bash
docker run --rm -v HOST_DIRECTORY:CONTAINER_DIRECTORY -i -t IMAGE COMMAND
```

The mounted volume between the *host* and the *container* enables the user to retrieve generated files directly from *host* side.

In other words, there is a hard-link between **CONTAINER_DIRECTORY** and **HOST_DIRECTORY** to become the same place! 😯

> Make sure the selected volume is allowed from `Docker` preferences.
More information about `-v` option [there](https://docs.docker.com/engine/reference/commandline/run/#mount-volume--v---read-only).

However, it can be more convenient to make a container persistent and *attach* to it:

```bash
docker run -v HOST_DIRECTORY:CONTAINER_DIRECTORY -i -t IMAGE
```

#### Limitations

As few `LaTeX` packages are pre-installed, you'll probably need to install new ones according to your needs.

If an error occurs when generating a `PDF`, you should follow the steps described into chapter *Maintenance* of the [TinyTeX web page](https://yihui.org/tinytex/#maintenance).

> Feel free to create your own `Docker` image from this one.

### Ubuntu

Follow the `Dockerfile`. Easy. 🤓

### Windows

Please follow these steps if `Docker` is not allowed on your machine only!
The generated PDF documents might differ from the `Docker` image due to available `LaTeX` libraries.

#### Make

1. Download [make.exe](http://gnuwin32.sourceforge.net/packages/make.htm)
2. Add corresponding **bin** folder to environment variable `PATH`

#### Pandoc

Download latest [Pandoc](<https://pandoc.org/installing.html>) installer and run it!

#### Plantuml

1. Install `java`
2. Create a new environment variable `JAVA_HOME` which points to `java` binary
3. Download [plantuml.jar](https://plantuml.com/fr/download)
4. Create a new environment variable `PLANTUML` which points to `plantuml.jar`

#### Graphviz

1. Download [Graphviz](https://www.graphviz.org) installer and run it
2. Add corresponding **bin** folder to environment variable `PATH`

#### LaTeX packages

* Install the [MikTeX](<https://miktex.org/download>) package manager.
* Configure the proxy settings if necessary to allow downloading the required pacakges at first time.

#### Jq

1. Install [jq](https://stedolan.github.io/jq/download/)
2. Add corresponding **bin** folder to environment variable `PATH`

#### Ruby

1. Install [ruby](https://rubyinstaller.org)
2. Add corresponding **bin** folder to environment variable `PATH`