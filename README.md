# explorer
Visual explorer of Red structures

(uses https://raw.githubusercontent.com/toomasv/syntax-highlighter/master/info.red)

It can be invoked as `explore <struct>` when compiled (<struct> is optional. If not provided `system` will be explored).

It can also be called as `red explore.red <struct>` from command-line. If <struct> is not provided, a console should open with `explore.red` loaded.

And finally it can be called from console or terminal after `do %explore.red` as `explore <strtuct>`.

Usage: `explore <struct>`

E.g.:
`explore system`,
`explore help-ctx`,
`explore preprocessor`

Clicking on object, map, block and funcs will enter into these structs.

Ctrl-clicking on labels which are behind each other will bring the last one into foreground.

Clicking on central node will lead up one level.

Contextual menu for back and forward history moving.

Wheeling changes diameter.

Adjustable legend:
  - saving, changing and removing from text-box selection
  - changing, (re)moving, adding individual elements from contextual menu

Representation of function's body and spec is currently just simplistic listing. Working on it.
