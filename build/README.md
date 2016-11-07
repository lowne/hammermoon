## App
Bundler not working atm :/

## Docs

Hammermoon docs are generated via a custom script using a [metalua]-generated model from [luadocumentor]. Modifications from vanilla luadocumentor include:

- "inline" template engine
- support for generating (github-flavored) markdown files in addition to html
- support for various kinds of filtering
- support for custom tags:
  - `@private` (do not include in docs; useful when `heuristics=true`)
  - `@static` for static tables (i.e. not used as metatables/classes)
  - `@const` for constant fields (e.g. event names)
  - `@dev` for advanced/dangerous stuff
  - `@apichange` and `@internalchange` to make the respective doc files (using the aforementioned filtering)

TODO: [dashing] to be used to build the `.docset` file.

[metalua]: https://github.com/fab13n/metalua
[luadocumentor]: https://github.com/LuaDevelopmentTools/luadocumentor
[dashing]: https://github.com/technosophos/dashing

### To build the docs:


You'll need a *vanilla* Lua 5.1 interpreter (required by metalua); the easiest way is:

```bash
brew install lua51
```

If you already have an appropriate interpreter, make sure that 
`lua5.1` is symlinked to it (if not, `ln -s` accordingly):

```bash
which lua5.1
```

The required modules are provided (inside `lib`), so this should now work:

```bash
./build_docs
```


#### To install the dependencies via luarocks (not required):

In case `./build_docs` complains of missing modules, or if you want to do things properly:

- Install luarocks if necessary (`brew` installs it automatically with Lua)

- Install luadocumentor + dependencies (including metalua):

```bash
luarocks-5.1 install luadocumentor --local
```

- Fix your `package.path` + `.cpath` for "local" rocks:

```bash
# in your .bashrc or similar
eval luarocks-5.1 path
```

- For non-bash shells, adjust accordingly - something like this for fish:

```bash
# in your config.fish
set -xg LUA_PATH (lua -e "print(package.path)")";"(luarocks-5.1 path --lr-path)
set -xg LUA_CPATH (lua -e "print(package.cpath)")";"(luarocks-5.1 path --lr-cpath)
```

