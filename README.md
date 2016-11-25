# Hammermoon
A [`luajit`](https://github.com/luapower/luajit)+[`objc.lua`](https://github.com/lowne/objc/)-powered reimplementation of [Hammerspoon](https://hammerspoon.org) in pure Lua.

### WIP status
Not even.

- [ ] Cocoa app just a dumb window for now
- [x] `logger` already in Lua, no porting needed
- [x] [`uielements`](hm/_os/uielements.lua)
- [ ] [`windows`](hm/windows.lua) partial
- [ ] [`applications`](hm/applications.lua) almost done
- [ ] [`screens`](hm/screen.lua) partial
- [x] [`timer`](hm/timer.lua)
- [ ] [`drawing`](hm/drawing.lua) very partial
- [x] `geometry` already in Lua, needs docs


### Docs
- [User documentation](build/docs/md/README.md) (no advanced stuff)
- [Full documentation](build/fulldocs/md/README.md)
- [API changes](build/docs/md/API_CHANGES.md) from Hammerspoon
- [Internal changes](build/docs/md/INTERNAL_CHANGES.md) from Hammerspoon

### Setup
```bash
git clone https://github.com/lowne/hammermoon.git hammermoon
cd hammermoon
./mgit clone-all
```

### Run
For now Hammermoon does `require'user'`, so create a `user.lua` file with your userscript. Then:
```
./luajit hammermoon
```

### Why?

1. Performance 
  - Hammerspoon can struggle with "heavy" userscripts (I can attest to that from personal experience)
  - Initial, *very* informal benchmarks show that even in a contrived worst-case scenario relying heavily on (slow) ffi callbacks (where ObjC has the full home advantage) Hammermoon seems to be at least twice as fast. Yay luajit!
2. Practicality
  - A lot of desirable core features are very difficult to implement in ObjC
  - Objective C is clunky compared to Lua; Lua gets things done with 10% of the effort (or SLoC)
  - Xcode is made of evil
  - HS is meant to be used and extended by its users in Lua anyway; having everything in Lua removes all barriers
  - Live coding beats debugging: type, save, see the results
      - For example with the testrunner the results even appear inline
3. A clean slate
  - A full rewrite is a chance to design easier/cleaner/better APIs
4. Beauty
  - FACT: Objective C is ugly, Lua is elegant :)
  - Bliss is never having to type `make`

### Main architectural features

- The user API is fully typechecked (at runtime of course). 
  - Adding reusable custom types is very straightforward
  - Structure types and "templates" are supported
  - Typechecking and assertions can be disabled by the user (for performance)
- Modules and their classes are entirely separated; `hm._core.module()` provides common infrastructure for all modules and classes 
- Modules and classes can expose user-facing properties (with getters and setters) as plain fields
  - protected
  - typechecked (for writable properties)
  - cached (for immutable properties)
- The ObjC bridge is mostly relegated into `hm._os`; user-facing modules should wrap and abstract over it
- Deprecation facility for any function or field
- LDoc-based documentation with custom tags (`static`, `class`, `property`, `readonlyproperty`, `prototype`)

### Why (long version)

(slightly edited rant taken from [here](https://github.com/Hammerspoon/hammerspoon/issues/690))

> First: the whole point of Lua is simplicity, and Lua's `nil` is certainly among the top reasons Lua is *simple*; it's a bit like memory allocation: to a spreadsheet user, an empty cell is an empty cell; of course there's no such thing as an empty *RAM* cell, therefore we have 50 layers in-between that jump through endless hoops to keep track of things on the side and give the user the "illusion" of an empty cell. Which is also what the Lua *implementation* does. [...] 

> Second: I *assume* that the point of HS and its predecessor(s) is to make it *simple* to script/extend/customize its functionality; therefore, Lua. (If the point was, say, pure performance, then the way to "script" it would be to fork, code (in C), compile; if the point was to build large scale complex architectures on top of it, the scripting should rather be done in Python; etc.). And once it's decided the *user* API is meant to be used in ("pure") Lua, I (again) *assume* that ideally the API itself should conform to the language; any divergence must be considered another leaky abstraction. [...]

> There have been several instances already where I (so to speak) complained about leaky abstractions or advocated for more "Lua-conformant" solutions; [...] I've been surprised by arguments that boil down to "the way it's done in C/Obj-C/Cocoa feels better/more natural, therefore that's what the user API should look like" more than once. 

[...]

> I *abhor* leaky abstractions. [...]

> I want many small puddles - in a hellish landscape full of sharp rocks and monstrous creatures - of thick, disgusting, toxic slime, so that I can't look into the multibranched abyss beneath even if I wanted to. [...] As I'm busy running from the monsters I want to jump from puddle to puddle, dip in briefly as small a piece of my toe as possible (the slime is disgusting!), and get the job done quickly without even knowing where all the magic came from. [...]

> This nightmarish landscape is *all software ever made*, built with the sole purpose of making me suffer as much as possible.

> To me, HS itself is clearly an *abstraction* over OSX, and I'd rather have it not leak all over the place. [...]

> > it's an integral fact that Hammerspoon is not and never will be just Lua. It's a hybrid of Lua and a bridge to some of OS X

> The way I see it, HS might be secretly powered by tiny hamsters that get "downloaded" inside my MBP, and I (the user) wouldn't care, as long as it does what it says on the box, which is, I *get to script it in Lua*. If the box says I'll need to use a "Lua-like", OSX-specific DSL, then fine, I'll (grudgingly) learn the DSL. Either way, I don't *want* to know *anything* about OSX, I want to read *just* the HS docs.

> > I prefer giving access to as much as possible [...] Others have chosen to only provide limited access to limited features

> That's a false dichotomy. I've advocated several times for *fully exposing* (but not necessarily fully documenting) the *naked*, low-level, ugly-syntax OSX calls, and *against* wrapping things in ObjC; so that then things can get wrapped in Lua (which *excels* at precisely this task) rather than in ObjC (which is *terrible*, if only because it's compiled), with a thought out, simple, idiomatic and *non-leaky* API - while still *keeping* full access to the lower levels for power users/module writers. [...]

> [Hammermoon's architecture enables the following:]

> 1. it's *trivially* easy to create multi-layered APIs
2. much easier to end up with a top API layer (the *user* layer) that is simple, idiomatic and leak-free *Lua*, as advertised on the box
3. easier to improve and build upon existing functionality in useful ways by harnessing the middle and low layers, without having to *fight* against the "hybrid" APIs
4. easier and quicker to open up entirely new abilities by writing thin(ner) ObjC bridges to OSX, and then organising them as per point above
5. simple, obvious solutions to thorny issues such as the venerable #477 
6. [no]  userdata, less memory management, less crashes to debug
7. [...] a likely decrease in performance, which if detectable at all and deemed troublesome [is] *more* than compensated once and for all by switching to LuaJIT+ffi 

