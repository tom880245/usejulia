using PkgTemplates
Template(interactive=true)("MyPkg")

Template(;
    user="tom880245",
    dir="~/code",
    authors="Acme Corp",
    julia=v"1.1",
    plugins=[
        License(; name="MPL"),
        Git(; manifest=true, ssh=true),
        GitHubActions(; x86=true),
        Codecov(),
        Documenter{GitHubActions}(),
        Develop(),
    ],
)


