https://www.youtube.com/watch?v=q-LV4zoxc-E&t=206s


https://pkgdocs.julialang.org/v1/creating-packages/

1. project.toml   &&  Manifest 

2. project environment

➤Agenda

●what is a project?

◯Project.toml

◯Manifest.toml

●Interaction with Code Loading

◯LOAD_PATH

◯How to make a project avaliable?

◯What happens when you type using X

●Examples - What are projects useful for?

◯Package development

◯"Task specific" projects

◯Applictions

◯Reproducibility




●what is a project?

◯A project is a pair of Project.toml + Manifest.toml in a folder

◯Default(global) project in ~/.julia/envirnments/vi

◯Projects are basically "free" (just two files) and can be used liberally

example:

==================================================
◯Project.toml

name = "MyProject"
uuid = "12345678-90ab-cdef-1234-567890abcdef"
authors = ["Your Name <your.email@example.com>"]
version = "0.1.0"

[deps]
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"

[compat]
julia = "1.6"
HTTP = "0.9"
JSON = "0.21"


=================================================

◯Manifest.toml

[[HTTP]]
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"
repo = "https://github.com/JuliaWeb/HTTP.jl.git"
tree_hash = "4e2f74f1c4e1f4e94f5f32d7d2b5e1b88e9f2e8c"

[[JSON]]
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"
repo = "https://github.com/JuliaIO/JSON.jl.git"
tree_hash = "92b1c2f72fb3fb11b5efacb7873f20a8b6a6e2a8"


================================================

更新庫最好是project 一起動 如果只有 Project.toml
應該
1.Pkg.resolve()
這將根據 Project.toml 文件解析依賴關係並更新或生成 Manifest.toml 文件。
2  Pkg.instantiate()
這將根據 Manifest.toml 文件安裝所有具體版本的依賴項，確保您的開發環境與 Manifest.toml 文件中的記錄一致。



===============================================

●Is a packeage a project?

◯ Yes , but not every project is a package.

◯ A package is a project with

	name = "Packagename"
	uuid = "..."
	
    in its Project.toml, and a src/PackageName.jl file that defines a PackageName module




●Project.toml => Pkg.add 會用到Project.toml   並更新Manifest.toml


◯Project.tomal describes the project on a high level

	→Dependenceies(in the [deps] section)
	→Compatibility constraints (in the [compat] section)

◯For a package: Project.toml defines the package name and UUID


◯Project.toml is what users interact and modeify (usually through Pkg)

◯Project.toml is the input to Pkg's resolver
	→For pkg> add Example the input is the current project + Example@*+current julia version

或者使用 add Example@^1.2.3  選擇 Example 套件中符合 ^1.2.3 的最高版本

●Manifest.toml  =>Pkg.instantiate() 會用到

◯Manifest.toml describes the absolute stae of the project
	→　For dependency graph(direct + indirect dependancies)
	→  Exact versions of all packages(direct + indirect dependancies)

◯Manifest.toml is the output from Pkg's resolver

	→For pkg> add Example the output is the new dependency graph and specific versions for
                   all packages(e.g. Example@0.5.3)

◯For a package:Manifest.toml is unused(!!!)

◯Manifest.toml is machine generated,editing it manally is not recommended

➤LOAD_PATH
#=
全局變量，包含了 Julia 用於查找包和模塊的路徑列表。當您使用 using 或 import 語句來加載包時，Julia 會按照 LOAD_PATH 中定義的順序來搜索這些包。
=#
●LOAD_PATH defines a stack of projects
◯3-element Vector{String}:
	"@"       當前專案環境
 	"@v#.#"   全局環境
	"@stdlib" Julia 安裝目錄中的標準庫位置

◯Expanded load path from Base.load_path()
julia> Base.load_path()
3-element Vector{String}:
	 "c:\\Users\\user\\.julia\\dev\\MyPkg\\Project.toml"  
	 "C:\\Users\\user\\.julia\\environments\\v1.9\\Project.toml"
	 "C:\\Users\\user\\AppData\\Local\\Programs\\Julia-1.9.0\\share\\julia\\stdlib\\v1.9"

◯LOAD_PATH can be modified from within julia,or with the JULIA_LOAD_PATH environment variable

#= 放置路徑
unshift!(Base.LOAD_PATH, "/home/user/my_julia_packages")
push!(Base.LOAD_PATH, "/home/user/my_julia_packages")
=#

➤Activate project

●"@" entry in LOAD_PATH expands to nothing by default,otherwise expands to either of

	A specifically activated project path(pkg>activate)
	A specifically set "home project"path(--project,JULIA_PROJECT)

● Example LOAD_PATH of developing package X:
julia> Base.load_path()
3-element Vector{String}:
	 "c:\\Users\\user\\.julia\\dev\\MyPkg\\Project.toml"  
	 "C:\\Users\\user\\.julia\\environments\\v1.9\\Project.toml"
	 "C:\\Users\\user\\AppData\\Local\\Programs\\Julia-1.9.0\\share\\julia\\stdlib\\v1.9"
#=

➤如何激活專案
●使用 pkg> activate 激活專案：
您可以在 Julia 的 Pkg 模式下使用 activate 命令來激活一個專案。

import Pkg
Pkg.activate("path/to/your/project")
●使用 --project 命令行選項：
您可以在啟動 Julia 時使用 --project 命令行選項來指定專案路徑。


julia --project=c:\\Users\\user\\.julia\\dev\\MyPkg
●設置 JULIA_PROJECT 環境變量：
您可以設置 JULIA_PROJECT 環境變量來指定專案路徑。

export JULIA_PROJECT="/path/to/your/project"
julia

=#

➤Code Loading

●what happends for using x?

    ◯Look through projects in LOAD_PATH[1],LOAD_PATH[2],LOAD_PATH[3],... for 
    [deps] x="$X_UUID"
    ◯Look for X_UUID entry in Manifest.toml which gives
	Version of x (and implicitly where x's source code is stored)
	UUIDs of x's dependencies
    ◯ Load path/to/x/src/x.jl

●what is allowed to using?

    ◯From "toplevel" Any package found in a [deps] seciton of a project file in LOAD_PATH

    ◯From inside a package module:Any package found in the [deps] section of the package
      Project.toml

●in particular for the default setup it is possible to load packages from the global
  project even if is not the first project--useful for package development


# 好用的包 Debugger

julia> using Debugger

julia> @enter DataFrames
In ##thunk#292() at REPL[9]:1
>1  1 ─     return Main.DataFrames

About to run: return DataFrames
1|debug> q (退出)

● "Task project"



EXAMPLE 
https://www.youtube.com/watch?v=q-LV4zoxc-E&t=206s 
觀看第二十分時

如果只想導入某個路徑的環境

] export JULIA_LOAD_PATH=$PWD

JULIA

LOAD_PATH

會看到只剩指定環境
+++++++++++++++++++++++++++++++++++++++++++++++++++
注意 :  下面會刪除所有packages 底下資料  不要用
cd
cd .julia/
rm -rf packages/ 
++++++++++++++++++++++++++++++++++++++++++++++++++

刪除前最好 先備份

cp -r ~/.julia ~/.julia_backup

確認後 刪除  然後 
instantiate


初始化也可以用
 instantiate


載入某個專案也可以這樣做

julia --project=$pwd

想看底下有甚麼資料夾
使用 readdir() 函數列出目錄下的文件和資料夾。
使用 stat() 函數查看文件或資料夾的詳細信息。

Thanks for yor attention!








