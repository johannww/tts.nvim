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
        return plugin_dir .. "/backends/edge_tts.py"
    end,
    
    get_args = function(text, config, nvim_data_dir, to_file)
        local voice = config.languages_to_voice[config.language]
        local args = {text, voice, tostring(config.speed), nvim_data_dir}
        if to_file then
            table.insert(args, to_file)
        end
        return args
    end,
    
    validate_config = function(config)
        if not config.languages_to_voice then
            return false, "languages_to_voice configuration is required for edge backend"
        end
        local voice = config.languages_to_voice[config.language]
        if not voice then
            return false, "No voice configured for language: " .. config.language
        end
        return true
    end
}

-- Piper backend
M.backends.piper = {
    name = "piper",
    
    get_script_path = function(plugin_dir)
        return plugin_dir .. "/backends/piper.py"
    end,
    
    get_args = function(text, config, nvim_data_dir, to_file)
        local model = config.piper_model or "en_US-lessac-medium"
        local args = {text, model, tostring(config.speed), nvim_data_dir}
        if to_file then
            table.insert(args, to_file)
        end
        return args
    end,
    
    validate_config = function(config)
        -- Piper has sensible defaults, so always valid
        return true
    end
}

-- OpenAI TTS backend
M.backends.openai = {
    name = "openai",
    
    get_script_path = function(plugin_dir)
        return plugin_dir .. "/backends/openai_tts.py"
    end,
    
    get_args = function(text, config, nvim_data_dir, to_file)
        local voice = config.openai_voice or "alloy"
        local model = config.openai_model or "tts-1"
        local api_key = config.openai_api_key or os.getenv("OPENAI_API_KEY")
        -- Pass empty string if no API key to allow Python script to handle the error
        local args = {text, voice, model, api_key or "", tostring(config.speed), nvim_data_dir}
        if to_file then
            table.insert(args, to_file)
        end
        return args
    end,
    
    validate_config = function(config)
        local api_key = config.openai_api_key or os.getenv("OPENAI_API_KEY")
        if not api_key or api_key == "" then
            return false, "OpenAI API key is required. Set openai_api_key in config or OPENAI_API_KEY environment variable"
        end
        return true
    end
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
