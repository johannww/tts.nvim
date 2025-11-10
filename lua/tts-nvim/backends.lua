local M = {}

-- Backend interface definition
-- Each backend should implement:
-- - get_script_path(): returns the path to the backend's Python script
-- - get_args(text, config, nvim_data_dir, to_file): returns the arguments for the backend script
-- - validate_config(config): validates backend-specific configuration

M.backends = {}

-- Edge TTS backend
M.backends.edge = {
    name = "edge",

    get_script_path = function(plugin_dir)
        return plugin_dir .. "/backends/edge.py"
    end,

    get_args = function(config, nvim_data_dir, to_file)
        local voice
        if config.languages_to_voice and config.languages_to_voice.edge then
            voice = config.languages_to_voice.edge[config.language]
        end
        -- Fallback to flat structure for backward compatibility
        if not voice and config.languages_to_voice then
            voice = config.languages_to_voice[config.language]
        end
        local args = { voice, tostring(config.speed), nvim_data_dir }
        if to_file then
            table.insert(args, to_file)
        end
        return args
    end,

    validate_config = function(config)
        if not config.languages_to_voice then
            return false, "languages_to_voice configuration is required for edge backend"
        end
        local voice
        if config.languages_to_voice.edge then
            voice = config.languages_to_voice.edge[config.language]
        else
            -- Fallback to flat structure for backward compatibility
            voice = config.languages_to_voice[config.language]
        end
        if not voice then
            return false, "No voice configured for language: " .. config.language
        end
        return true
    end,
}

-- Piper backend
M.backends.piper = {
    name = "piper",

    get_script_path = function(plugin_dir)
        return plugin_dir .. "/backends/piper_tts.py"
    end,

    get_args = function(config, nvim_data_dir, to_file)
        local model
        -- First check for language-specific model
        if config.languages_to_voice and config.languages_to_voice.piper then
            model = config.languages_to_voice.piper[config.language]
        end
        -- Fallback to piper_model config or default
        if not model then
            model = config.piper_model or "en_US-lessac-medium"
        end
        local args = { model, tostring(config.speed), nvim_data_dir }
        if to_file then
            to_file = to_file:gsub("%.mp3$", ".wav")
            table.insert(args, to_file)
        end
        return args
    end,

    validate_config = function(config)
        -- Piper has sensible defaults, so always valid
        return true
    end,
}

-- OpenAI TTS backend
M.backends.openai = {
    name = "openai",

    get_script_path = function(plugin_dir)
        return plugin_dir .. "/backends/openai_tts.py"
    end,

    get_args = function(config, nvim_data_dir, to_file)
        -- OpenAI uses the same voice for all languages
        local voice = (config.openai and config.openai.voice) or "alloy"
        local model = (config.openai and config.openai.model) or "tts-1"
        local args = { voice, model, tostring(config.speed), nvim_data_dir }
        if to_file then
            table.insert(args, to_file)
        end
        return args
    end,

    validate_config = function(config)
        local api_key = os.getenv("OPENAI_API_KEY")
        if not api_key or api_key == "" then
            return false, "OpenAI API key is required. Set OPENAI_API_KEY environment variable"
        end
        return true
    end,
}

-- Get backend by name
M.get_backend = function(backend_name)
    return M.backends[backend_name]
end

-- Get available backend names
M.get_available_backends = function()
    local names = {}
    for name, _ in pairs(M.backends) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return M
