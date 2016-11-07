# Hammermoon
A [`luajit`](https://github.com/luapower/luajit)+[`objc.lua`](https://github.com/lowne/objc/)-powered reimplementation of [Hammerspoon](https://hammerspoon.org) in pure Lua

### WIP Status
Not even.

- [ ] Cocoa app (just a dumb window for now)
- [x] `logger` (in Lua, no porting needed)
- [x] `uielement`
- [ ] `window` (partial)
- [ ] `application` (partial)
- [ ] `screen` (partial)
- [ ] `timer` (partial)
- [ ] `drawing` (very partial)
- [x] `geometry` (in Lua)

### Docs
- [User documentation](docs/md/README.md)
- [API changes](docs/md/apichanges.md) from Hammerspoon
- [Internal changes](docs/md/internalchanges.md) from Hammerspoon

### Setup
```bash
git clone https://github.com/lowne/hammermoon.git hammermoon
cd hammermoon
./mgit clone-all
```

### Run
For now Hammermoon does `require'user'()`, so create a `user.lua` file that returns a function with your userscript. Then:
```
./luajit hammermoon
```

### Why?

1. Performance 
  - Hammerspoon can struggle with "heavy" userscripts (I can attest to that from personal experience)
  - Initial, *very* informal benchmarks show that even in a contrived worst-case scenario relying heavily on (slow) ffi callbacks (where ObjC has the full home advantage) Hammermoon seems to be at least twice as fast. Yay luajit!
2. Beauty
  - FACT: Objective C is ugly, Lua is elegant :)
  - Bliss is never having to type `make`
3. Practicality
  - FACT: Objective C is clunky; Lua gets things done with 10% of the effort (or SLoC)
  - Xcode is made of evil
  - HS is meant to be used and extended by its users in Lua anyway; having everything in Lua removes all barriers
  - Live coding beats debugging: type, save, see the results
  - Did I mention I don't want to wait for silly compilers ever again? Why wait when you can JIT?


