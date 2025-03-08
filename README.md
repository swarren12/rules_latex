<!--
  ~~ README.md - Hello, curious person ^_^
  -->

# `rules_latex` - Compile documents using Bazel

Bazel rules for processing LaTeX files.

## Usage

### Bzlmod

```python
# MODULE.bazel
bazel_dep(name = "rules_latex", version="2025.3.0", dev_dependency = True)
```

### `latex_document`

```python
# BUILD.bazel
load("@rules_latex//latex:latex.bzl", "latex_document")

latex_document(
    name = "document",
    main = "index.tex",
    srcs = glob(["*.tex"]).
    format = "pdf"
)

```

## To-do List

- Literally everything...