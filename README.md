# Text-to-speech in neovim

Read your visual selection using the [edge_tts](https://github.com/rany2/edge-tts) python library.


https://github.com/user-attachments/assets/a1f7fa26-eafc-49c4-b273-1332a726ee17

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
    opts = {
        voice = "en-GB-SoniaNeural",
    },
},

```

## List voices

```bash
python -m edge_tts --list-voices
```

or:

```bash
edge-tts -l
```

# Disclaimer

For now we hardcode the selected voice to "en-GB-SoniaNeural". This will change in the future.
