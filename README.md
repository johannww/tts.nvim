# Text-to-speech in Neovim

Read your visual selection using multiple TTS backends including [edge-tts](https://github.com/rany2/edge-tts), [Piper](https://github.com/rhasspy/piper), and [OpenAI TTS](https://platform.openai.com/docs/guides/text-to-speech).

"TTS" command reads the visual selection using `ffplay`, while "TTSFile" outputs the audio to a file.


https://github.com/user-attachments/assets/f331db4b-ace3-475d-8423-e5e3df81083b

# Dependencies

## Required (All backends)

- ffplay
```bash
sudo apt install ffmpeg
```
```bash
sudo pacman -S ffmpeg
```
- plenary.nvim

## Backend-specific Dependencies

### Edge TTS (default backend)
- edge-tts
```bash
pip install edge-tts
```
```bash
yay -S python-edge-tts
```

### Piper
- piper-tts
```bash
pip install piper-tts
```
Or install from source: [Piper Installation](https://github.com/rhasspy/piper#installation)

### OpenAI TTS
- openai Python package
```bash
pip install openai
```
- OpenAI API key (set as `OPENAI_API_KEY` environment variable)

## Optional (for syntax removal)

- **pandoc**: For pandoc-based syntax removal. Only required if using `syntax_removal_method = "pandoc"`.
```bash
sudo apt install pandoc
```
```bash
sudo pacman -S pandoc
```

# Features

## Multiple TTS Backends

The plugin supports three TTS backends:

1. **Edge TTS** (default): Free, cloud-based Microsoft Edge TTS with many voices
2. **Piper**: Fast, local, open-source neural TTS
3. **OpenAI TTS**: High-quality cloud-based TTS (requires API key)

Configure the backend in your setup:

```lua
require("tts-nvim").setup({
    backend = "edge", -- "edge", "piper", or "openai"
})
```

## Syntax Removal

The plugin can remove syntax from Markdown and LaTeX files before reading them aloud. This ensures that the TTS engine speaks only the actual text content, without markup symbols like `#`, `*`, `\textbf{}`, etc.

Two methods are supported:

1. **Simple** (default): Uses pattern-based regex to remove common markdown and LaTeX syntax. Works without any external dependencies.
2. **Pandoc**: Uses pandoc to convert Markdown/LaTeX to plain text. Requires pandoc to be installed. Falls back to simple method if pandoc fails.

To enable syntax removal, set `remove_syntax = true` in your configuration:

```lua
require("tts-nvim").setup({
    remove_syntax = true,
    syntax_removal_method = "pandoc", -- or "simple"
})
```

# Installation

## Lazy

### Edge TTS (default)

```lua
{
    "johannww/tts.nvim",
    cmd = { "TTS", "TTSFile", "TTSSetLanguage", "TTSSetBackend" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        backend = "edge", -- default backend
        language = "en",
        speed = 1.0,
        remove_syntax = false,
        syntax_removal_method = "pandoc",
        languages_to_voice = {
            edge = {
                ["en"] = "en-GB-SoniaNeural",
                ["pt"] = "pt-BR-AntonioNeural",
                ["es"] = "es-ES-ElviraNeural",
                ["fr"] = "fr-FR-DeniseNeural",
                ["de"] = "de-DE-KatjaNeural",
                ["it"] = "it-IT-ElsaNeural",
                ["ja"] = "ja-JP-NanamiNeural",
                ["zh"] = "zh-CN-XiaoxiaoNeural",
            },
            piper = {
                ["en"] = "en_US-lessac-medium",
                ["pt"] = "pt_BR-faber-medium",
                ["es"] = "es_ES-sharvard-medium",
                ["fr"] = "fr_FR-siwis-medium",
                ["de"] = "de_DE-thorsten-medium",
                ["it"] = "it_IT-riccardo-x_low",
                ["ja"] = "ja_JP-haruka-medium",
                ["zh"] = "zh_CN-huayan-medium",
            },
            -- OpenAI uses the same voice for all languages
            -- Configure the voice in openai_voice option below
        },
        openai_voice = "alloy",  -- Available: alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer
        openai_model = "tts-1", -- OpenAI model: "tts-1" or "tts-1-hd"
    },
}
```

### Piper

```lua
{
    "johannww/tts.nvim",
    cmd = { "TTS", "TTSFile", "TTSSetLanguage", "TTSSetBackend" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        backend = "piper",
        language = "en",
        speed = 1.0,
        piper_model = "en_US-lessac-medium", -- or other Piper models
    },
}
```

### OpenAI TTS

**Note:** OpenAI TTS requires the `OPENAI_API_KEY` environment variable to be set.

```lua
{
    "johannww/tts.nvim",
    cmd = { "TTS", "TTSFile", "TTSSetLanguage", "TTSSetBackend" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        backend = "openai",
        language = "en",
        speed = 1.0,
        openai_model = "tts-1", -- or "tts-1-hd" for higher quality
        openai_voice = "alloy", -- Available: alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer
    },
}
```

## Backend-Specific Configuration

### Edge TTS - List Available Voices

```bash
python -m edge_tts --list-voices
```

or:

```bash
edge-tts -l
```

Output:

<details>
  <summary>Voice List</summary>

```text
af-ZA-AdriNeural
af-ZA-WillemNeural
am-ET-AmehaNeural
am-ET-MekdesNeural
ar-AE-FatimaNeural
ar-AE-HamdanNeural
ar-BH-AliNeural
ar-BH-LailaNeural
ar-DZ-AminaNeural
ar-DZ-IsmaelNeural
ar-EG-SalmaNeural
ar-EG-ShakirNeural
ar-IQ-BasselNeural
ar-IQ-RanaNeural
ar-JO-SanaNeural
ar-JO-TaimNeural
ar-KW-FahedNeural
ar-KW-NouraNeural
ar-LB-LaylaNeural
ar-LB-RamiNeural
ar-LY-ImanNeural
ar-LY-OmarNeural
ar-MA-JamalNeural
ar-MA-MounaNeural
ar-OM-AbdullahNeural
ar-OM-AyshaNeural
ar-QA-AmalNeural
ar-QA-MoazNeural
ar-SA-HamedNeural
ar-SA-ZariyahNeural
ar-SY-AmanyNeural
ar-SY-LaithNeural
ar-TN-HediNeural
ar-TN-ReemNeural
ar-YE-MaryamNeural
ar-YE-SalehNeural
az-AZ-BabekNeural
az-AZ-BanuNeural
bg-BG-BorislavNeural
bg-BG-KalinaNeural
bn-BD-NabanitaNeural
bn-BD-PradeepNeural
bn-IN-BashkarNeural
bn-IN-TanishaaNeural
bs-BA-GoranNeural
bs-BA-VesnaNeural
ca-ES-EnricNeural
ca-ES-JoanaNeural
cs-CZ-AntoninNeural
cs-CZ-VlastaNeural
cy-GB-AledNeural
cy-GB-NiaNeural
da-DK-ChristelNeural
da-DK-JeppeNeural
de-AT-IngridNeural
de-AT-JonasNeural
de-CH-JanNeural
de-CH-LeniNeural
de-DE-AmalaNeural
de-DE-ConradNeural
de-DE-FlorianMultilingualNeural
de-DE-KatjaNeural
de-DE-KillianNeural
de-DE-SeraphinaMultilingualNeural
el-GR-AthinaNeural
el-GR-NestorasNeural
en-AU-NatashaNeural
en-AU-WilliamNeural
en-CA-ClaraNeural
en-CA-LiamNeural
en-GB-LibbyNeural
en-GB-MaisieNeural
en-GB-RyanNeural
en-GB-SoniaNeural
en-GB-ThomasNeural
en-HK-SamNeural
en-HK-YanNeural
en-IE-ConnorNeural
en-IE-EmilyNeural
en-IN-NeerjaExpressiveNeural
en-IN-NeerjaNeural
en-IN-PrabhatNeural
en-KE-AsiliaNeural
en-KE-ChilembaNeural
en-NG-AbeoNeural
en-NG-EzinneNeural
en-NZ-MitchellNeural
en-NZ-MollyNeural
en-PH-JamesNeural
en-PH-RosaNeural
en-SG-LunaNeural
en-SG-WayneNeural
en-TZ-ElimuNeural
en-TZ-ImaniNeural
en-US-AnaNeural
en-US-AndrewMultilingualNeural
en-US-AndrewNeural
en-US-AriaNeural
en-US-AvaMultilingualNeural
en-US-AvaNeural
en-US-BrianMultilingualNeural
en-US-BrianNeural
en-US-ChristopherNeural
en-US-EmmaMultilingualNeural
en-US-EmmaNeural
en-US-EricNeural
en-US-GuyNeural
en-US-JennyNeural
en-US-MichelleNeural
en-US-RogerNeural
en-US-SteffanNeural
en-ZA-LeahNeural
en-ZA-LukeNeural
es-AR-ElenaNeural
es-AR-TomasNeural
es-BO-MarceloNeural
es-BO-SofiaNeural
es-CL-CatalinaNeural
es-CL-LorenzoNeural
es-CO-GonzaloNeural
es-CO-SalomeNeural
es-CR-JuanNeural
es-CR-MariaNeural
es-CU-BelkysNeural
es-CU-ManuelNeural
es-DO-EmilioNeural
es-DO-RamonaNeural
es-EC-AndreaNeural
es-EC-LuisNeural
es-ES-AlvaroNeural
es-ES-ElviraNeural
es-ES-XimenaNeural
es-GQ-JavierNeural
es-GQ-TeresaNeural
es-GT-AndresNeural
es-GT-MartaNeural
es-HN-CarlosNeural
es-HN-KarlaNeural
es-MX-DaliaNeural
es-MX-JorgeNeural
es-NI-FedericoNeural
es-NI-YolandaNeural
es-PA-MargaritaNeural
es-PA-RobertoNeural
es-PE-AlexNeural
es-PE-CamilaNeural
es-PR-KarinaNeural
es-PR-VictorNeural
es-PY-MarioNeural
es-PY-TaniaNeural
es-SV-LorenaNeural
es-SV-RodrigoNeural
es-US-AlonsoNeural
es-US-PalomaNeural
es-UY-MateoNeural
es-UY-ValentinaNeural
es-VE-PaolaNeural
es-VE-SebastianNeural
et-EE-AnuNeural
et-EE-KertNeural
fa-IR-DilaraNeural
fa-IR-FaridNeural
fi-FI-HarriNeural
fi-FI-NooraNeural
fil-PH-AngeloNeural
fil-PH-BlessicaNeural
fr-BE-CharlineNeural
fr-BE-GerardNeural
fr-CA-AntoineNeural
fr-CA-JeanNeural
fr-CA-SylvieNeural
fr-CA-ThierryNeural
fr-CH-ArianeNeural
fr-CH-FabriceNeural
fr-FR-DeniseNeural
fr-FR-EloiseNeural
fr-FR-HenriNeural
fr-FR-RemyMultilingualNeural
fr-FR-VivienneMultilingualNeural
ga-IE-ColmNeural
ga-IE-OrlaNeural
gl-ES-RoiNeural
gl-ES-SabelaNeural
gu-IN-DhwaniNeural
gu-IN-NiranjanNeural
he-IL-AvriNeural
he-IL-HilaNeural
hi-IN-MadhurNeural
hi-IN-SwaraNeural
hr-HR-GabrijelaNeural
hr-HR-SreckoNeural
hu-HU-NoemiNeural
hu-HU-TamasNeural
id-ID-ArdiNeural
id-ID-GadisNeural
is-IS-GudrunNeural
is-IS-GunnarNeural
it-IT-DiegoNeural
it-IT-ElsaNeural
it-IT-GiuseppeMultilingualNeural
it-IT-IsabellaNeural
iu-Cans-CA-SiqiniqNeural
iu-Cans-CA-TaqqiqNeural
iu-Latn-CA-SiqiniqNeural
iu-Latn-CA-TaqqiqNeural
ja-JP-KeitaNeural
ja-JP-NanamiNeural
jv-ID-DimasNeural
jv-ID-SitiNeural
ka-GE-EkaNeural
ka-GE-GiorgiNeural
kk-KZ-AigulNeural
kk-KZ-DauletNeural
km-KH-PisethNeural
km-KH-SreymomNeural
kn-IN-GaganNeural
kn-IN-SapnaNeural
ko-KR-HyunsuMultilingualNeural
ko-KR-InJoonNeural
ko-KR-SunHiNeural
lo-LA-ChanthavongNeural
lo-LA-KeomanyNeural
lt-LT-LeonasNeural
lt-LT-OnaNeural
lv-LV-EveritaNeural
lv-LV-NilsNeural
mk-MK-AleksandarNeural
mk-MK-MarijaNeural
ml-IN-MidhunNeural
ml-IN-SobhanaNeural
mn-MN-BataaNeural
mn-MN-YesuiNeural
mr-IN-AarohiNeural
mr-IN-ManoharNeural
ms-MY-OsmanNeural
ms-MY-YasminNeural
mt-MT-GraceNeural
mt-MT-JosephNeural
my-MM-NilarNeural
my-MM-ThihaNeural
nb-NO-FinnNeural
nb-NO-PernilleNeural
ne-NP-HemkalaNeural
ne-NP-SagarNeural
nl-BE-ArnaudNeural
nl-BE-DenaNeural
nl-NL-ColetteNeural
nl-NL-FennaNeural
nl-NL-MaartenNeural
pl-PL-MarekNeural
pl-PL-ZofiaNeural
ps-AF-GulNawazNeural
ps-AF-LatifaNeural
pt-BR-AntonioNeural
pt-BR-FranciscaNeural
pt-BR-ThalitaMultilingualNeural
pt-PT-DuarteNeural
pt-PT-RaquelNeural
ro-RO-AlinaNeural
ro-RO-EmilNeural
ru-RU-DmitryNeural
ru-RU-SvetlanaNeural
si-LK-SameeraNeural
si-LK-ThiliniNeural
sk-SK-LukasNeural
sk-SK-ViktoriaNeural
sl-SI-PetraNeural
sl-SI-RokNeural
so-SO-MuuseNeural
so-SO-UbaxNeural
sq-AL-AnilaNeural
sq-AL-IlirNeural
sr-RS-NicholasNeural
sr-RS-SophieNeural
su-ID-JajangNeural
su-ID-TutiNeural
sv-SE-MattiasNeural
sv-SE-SofieNeural
sw-KE-RafikiNeural
sw-KE-ZuriNeural
sw-TZ-DaudiNeural
sw-TZ-RehemaNeural
ta-IN-PallaviNeural
ta-IN-ValluvarNeural
ta-LK-KumarNeural
ta-LK-SaranyaNeural
ta-MY-KaniNeural
ta-MY-SuryaNeural
ta-SG-AnbuNeural
ta-SG-VenbaNeural
te-IN-MohanNeural
te-IN-ShrutiNeural
th-TH-NiwatNeural
th-TH-PremwadeeNeural
tr-TR-AhmetNeural
tr-TR-EmelNeural
uk-UA-OstapNeural
uk-UA-PolinaNeural
ur-IN-GulNeural
ur-IN-SalmanNeural
ur-PK-AsadNeural
ur-PK-UzmaNeural
uz-UZ-MadinaNeural
uz-UZ-SardorNeural
vi-VN-HoaiMyNeural
vi-VN-NamMinhNeural
zh-CN-XiaoxiaoNeural
zh-CN-XiaoyiNeural
zh-CN-YunjianNeural
zh-CN-YunxiNeural
zh-CN-YunxiaNeural
zh-CN-YunyangNeural
zh-CN-liaoning-XiaobeiNeural
zh-CN-shaanxi-XiaoniNeural
zh-HK-HiuGaaiNeural
zh-HK-HiuMaanNeural
zh-HK-WanLungNeural
zh-TW-HsiaoChenNeural
zh-TW-HsiaoYuNeural
zh-TW-YunJheNeural
zu-ZA-ThandoNeural
```

</details>

### Piper - Available Models

Piper models need to be downloaded before use. See [Piper documentation](https://github.com/rhasspy/piper/blob/master/VOICES.md) for a full list of available voices.

Common models:
- `en_US-lessac-medium` (default, good quality)
- `en_US-lessac-high` (higher quality, slower)
- `en_GB-alan-medium` (British English)
- `en_US-amy-medium` (Female voice)

Models are downloaded automatically to the nvim data directory (`~/.local/share/nvim/tts-nvim/piper_voices/`).

### OpenAI TTS - Available Voices

OpenAI TTS offers 10 voices with different characteristics:

- **alloy**: Neutral and balanced
- **ash**: Clear and articulate
- **ballad**: Warm and expressive
- **coral**: Friendly and engaging
- **echo**: Male, clear and articulate
- **fable**: British accent, expressive
- **nova**: Female, warm and engaging
- **onyx**: Deep male voice
- **sage**: Wise and measured
- **shimmer**: Female, soft and gentle

Models:
- `tts-1`: Standard quality, faster
- `tts-1-hd`: Higher quality, slightly slower

No pre-download required - voices are accessed via API.

# Usage

## Commands

The plugin provides the following commands:

- **`:TTS`** - Read the visual selection aloud using the configured backend
- **`:TTSFile`** - Save the visual selection as an audio file (tts.mp3)
- **`:TTSSetLanguage <lang>`** - Set the language for TTS (e.g., `:TTSSetLanguage en`)
- **`:TTSSetBackend <backend>`** - Switch TTS backend (e.g., `:TTSSetBackend piper`)

## Example Workflow

1. Select text in visual mode
2. Run `:TTS` to hear it spoken
3. Or run `:TTSFile` to save it as an audio file

To switch backends during a session:
```vim
:TTSSetBackend piper
:TTSSetBackend openai
:TTSSetBackend edge
```
