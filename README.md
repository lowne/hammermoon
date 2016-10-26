# Hammermoon
A luajit+objc.lua-powered reimplementation of Hammerspoon in pure Lua

###Setup
```
git clone https://github.com/lowne/hammermoon.git hammermoon
cd hammermoon
./mgit clone-all
```

###Run
For now Hammermoon does `require'user'()`, so create a `user.lua` file that returns a function with your userscript. Then:
```
./luajit hammermoon
```

