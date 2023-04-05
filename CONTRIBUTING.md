# Contributing to the Docs

Thanks for contributing to the documentation repository! The documentation is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0). Before
patches are accepted and merged, we require that these relatively simple guidelines be followed:
* Adhere to the documentation style guidelines
* Sign your work

Also, read an [overview](https://developers.google.com/tech-writing/overview) on Technical Writing from Google on authoring good technical content!

## Documentation style guidelines

This documentation is authored using [reStructuredText](http://docutils.sourceforge.net/rst.html) as a markup language and uses the
[Sphinx](https://www.sphinx-doc.org/en/master/) documentation generator.

### Filenames
Use only lowercase alphanumeric characters and hyphens `-` where required. Filenames are suffixed with the `.rst` extension.

### Headings

Use title case for headings.
Refer to https://titlecase.com/ for more information.

The headings follow this convention:

1. `H1` or document title based on `#` with overline
1. `H2` based on `*` with overline
1. `H3` based on `=`
1. `H4` based on `-`
1. `H5` based on `^`
1. `H6` based on `"`

If you need more levels, then consider creating a new document. A document has only one `H1`.

### Guideline for Kubernetes Object Types in Body Text

Prefer lowercase plain text such as namespace, pod, daemon set, container, service, and so on.
This guideline applies to multi-word types like custom resource definition.

Use the camel case name only if you follow the name with object, resource, and so on.
For example, "Delete the ``Pod`` object..."
However, that example is not compelling and is just as clear when written as "Delete the pod..."

### Console Outputs
#### Directives
For console outputs in this document, use `code-block:: console` directive. This results in a red prompt, which makes it easy to distinguish between the prompt
and the command.

#### Commands
Separate each command into its own `code-block`. Since this repository uses the Sphinx `copy-button` to allow for easy copy/pasting of commands
by users, it makes sense to separate each command for readability and usage.

If you need to aggregate multiple commands, then use the separator, 2-space indentation and `&&` on each line as shown in the example below:
```console
$ command1 \
    && command2 \
    && command3
```

#### Outputs
Separate outputs and commands into their own `code-block` sequence. Since the repository is configured to copy everything (including items after the prompt lines by
setting `copybutton_only_copy_prompt_lines` to false), it is desirable to only copy commands.

### Block Diagrams

The repo includes the [blockdiag](http://blockdiag.com/en/) plugin to allow diagrams to be generated using text. For examples on how to use blockdiag,
refer to this [page](http://blockdiag.com/en/blockdiag/examples.html).

## Sign your work

The sign-off is a simple line at the end of the explanation for the patch. Your
signature certifies that you wrote the patch or otherwise have the right to pass
it on as an open-source patch. The rules are pretty simple: if you can certify
the below (from [developercertificate.org](http://developercertificate.org/)):

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

Then you just add a line to every git commit message:

    Signed-off-by: Joe Smith <joe.smith@email.com>

Use your real name (sorry, no pseudonyms or anonymous contributions.)

If you set your `user.name` and `user.email` git configs, you can sign your
commit automatically with `git commit -s`.
