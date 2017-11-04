# SmartMacro

This project is an addon for World of Warcraft client that allows to run more advanced macro commands.

## Main Idea

The following points caused this project to emerge:

* Macros are easy to understand and use by end-users; they have pretty nice support in default UI.
* Macro language is rather limited, it might not be expressive enough if you're trying to do something advanced.
* Lua language is much less limited, but in macro commands it does not work good because of 255 characaters length limitation.

The main idea of the project is to improve macro language by fusing it with Lua. Here is an example:

```
#showtooltip

if api.player.isPaladin then
    /cast {{api.spell.DivineSteed}}
elseif api.player.isShaman then
    /cast {{api.spell.GhostWolf}}
elseif api.player.isDruid then
    /cast {{api.spell.Dash}}
elseif api.player.isDeathKnight then
    /cast {{api.spell.WraithWalk}}
end
```