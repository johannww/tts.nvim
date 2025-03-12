# Text-to-speech in neovim

Read your visual selection using the [edge_tts](https://github.com/rany2/edge-tts) python library.

# Dependencies

- ffplay
- edge_tts
- plenary.nvim

# Installation

Lazy:

```lua
{
    "johannww/tts.nvim",
    cmd = { "TTS" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("tts-nvim").setup() end,
},

```
