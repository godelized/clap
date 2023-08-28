# Bash CLAP

CLAP is a source-able bash script allowing to declare flags and positional parameters in a declarative manner and parse them.

It comes with two features:

- command line argument parsing,
- generate the command usage to help the user.

CLAP provides a prelude. When sourced, the CLAP prelude is executed and initializes few `CLAP_*` variables. These variables allow to configure CLAP. They are declared using the `declare` builtin of bash: it makes `CLAP_*` variables local to the function and its children and ultimately allow to nest multiple CLAPs and define sub-commands.

It does not perform any kind validation. It just reads flags and positional parameters. Validation is left to the caller.

# Limitations / TODOs

- No support of flags with value(s).
- `clap_parse` expects flags first, from the first mismatch every argument is considered a positional parameter.
- CLAP is not pure bash because it currently relies on `column` to render the help.

# Usage

```bash
#!/usr/bin/env bash

main() {
    # 1. Execute the prelude.
    source clap.sh

    # 2. Configure CLAP_* variables.
    CLAP_cfg[name]='clap_snippet'
    CLAP_flags_def[-h]=''
    CLAP_flags_def_alt[--help]=-h
    CLAP_positionals_def=(words...)

    # 3. Parse.
    clap_parse "$@"

    # 4. Flags and positional parameters are available via:
    #    - CLAP_flags: associative array.
    #    - CLAP_positionals: array.
    if [ $# == 0 ] || [ -n "${CLAP_flags[-h]+x}" ]; then
        clap_show_usage
        exit
    fi

    for word in "${CLAP_positionals[@]}"; do
        echo "$word"
    done
}

main "$@"
```

```bash
λ. ./clap_snippet 
clap_snippet [<OPTIONS>] WORDS...

POSITIONAL PARAMETERS:

  WORDS...  

OPTIONS:

  -h 
```

```bash
λ. ./clap_snippet foo bar baz
foo
bar
baz
```


## Configuration variables: main configuration

- `CLAP_cfg[name]='cat'`: command name.
- `CLAP_cfg[description]='Concatenate FILE(s) to standard output.'`: command description.

## Configuration variables: flags

### `CLAP_flags_def`

Definition of flags.

This is the minimum requirement to define flags.

Associative array:

- Key: flag.
- Value: n/a.

Example:

```bash
CLAP_flags_def[-h]=''
```

### `CLAP_flags_def_alt`

Definition of alternate flags.

Alternate flags allow to have multiple versions of flags. For example mapping `--help` to `-h`.

Associative array:

- Key: alternate flag.
- Value: associated flag.

Example:

```bash
CLAP_flags_def_alt[--help]='-h'
```

### `CLAP_flags_def_help`

Definition of help text rendered by `clap_show_usage`.

Associative array:

- Key: flag.
- Value: free text.

Example:

```bash
CLAP_flags_def_help[-h]='Display this help and exit.'
```

## Configuration variables: positional parameters

### `CLAP_positionals_def`

Definition of positional parameters.

Array.

Example:

```bash
CLAP_positionals_def=(file)
```

### `CLAP_positionals_def_help`

Definition of help text rendered by `clap_show_usage`.

Associative array:

- Key: flag.
- Value: free text.

Example:

```bash
CLAP_positionals_def_help[file]='File to process.'
```

## Functions

### `clap_parse`

Parse flags and positional parameters according to `CLAP_*` configuration.

### `clap_show_usage`

Display an help according to `CLAP_*` configuration.
