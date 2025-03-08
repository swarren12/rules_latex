#
# latex_document.bzl - LaTeX document rule
#
""" LaTeX Document Rule """

def _latex_doc(ctx):
    """ Process a LaTeX document """

    inputs = []
    inputs.extend(ctx.files.srcs)
    if not ctx.file.main in inputs:
        inputs.append(ctx.file.main)

    format = ctx.attr.format
    if format not in ["pdf", "dvi"]:
        fail("Output format must be one of pdf or dvi")
        return

    output = ctx.actions.declare_file("%s.%s" % (ctx.attr.name, format))

    # tools = depset([latex.pdftex])
    tools = depset([])

    src_dir = ctx.file.main.dirname
    src_filename = ctx.file.main.basename
    tmp_output_path = "/".join([src_dir, output.basename])

    ctx.actions.run_shell(
        # This is a bit of a hack to get around a weird behaviour in LaTeX...
        # In theory, it would be possible to just execute LaTeX from the initial working directory,
        # and directly specify the `-output-directory` attribute; however, that causes some slightly
        # weird behaviour when using `\subfile`, as this is resolved from the _working directory_ and
        # NOT relative to the entrypoint / file that it is being included from.
        command = "cd %s; /usr/bin/latex $@; cd - >/dev/null; mv -v %s %s" % (src_dir, tmp_output_path, output.path),
        arguments = [ctx.actions.args()
                         .add("-jobname", ctx.attr.name)
                         .add("-output-format", format)
                         .add(src_filename)],
        inputs = inputs,
        outputs = [output],
        mnemonic = "LaTeX",
        progress_message = "Processing LaTeX document %s" % ctx.file.main.short_path,
        tools = tools,
    )

    return DefaultInfo(files = depset([output]))


latex_document = rule(
    implementation = _latex_doc,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "main": attr.label(allow_single_file = [".tex"]),
        "format": attr.string(),
    },
)

#
# Usage:
#  latex_document(
#      name = "my-doc",
#      src = glob(["*.tex"]),
#      main = "index.tex",
#      format = "pdf"
#  )
#