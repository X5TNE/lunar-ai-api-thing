--[[

Notes on what I am giving you:
- This is my own free API for inference, no built in API key
- Use generously, have at least a built in rate limit of 15 rpm
- Inference is slow, I'm sorry but I rely solely on eco-friendly hardware and am currently at a loss of budget
- AI generated, you should always tell users that an API is generating, not providing human feedback.
- Not logged
- Now rate-limited:
> IP-based Limit
> 15 RPM
> 5,000 RPD
> 20,000 TPM
> Global Limit (All Users)
> 50,000 RPD
> 200,000 TPM
- OpenAI-compatible

-- As of writing this script the server I have is in maintenence anyway, expect 404s until DD-MM-YY: 25-04-26.

]]

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Standard Base64 encode
function base64_encode(data)
    return ((data:gsub('.', function(x)
        local r,byte='',x:byte()
        for i=8,1,-1 do
            r = r .. (byte % 2^i - byte % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i=1,6 do
            c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0)
        end
        return b:sub(c+1,c+1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- Helper func
function CallLunarAI(messages, model, callback)
    -- Build OpenAI payload
    local payload = {
        model = "smollm3-3b", --[[
        ---All Models--

        --Unlimited Usage--
        playdate2-2b (Unavailable unless you ask me)

        --Accepted Models--
        smollm3-3b
        gemma-3-1b-it
        qwen2.5-7b-instruct
        qwen3.5-9b
        
        --Key Only--
        gemma-4-26B-A4B
        gemma-4-31B
        qwen3.6-35b-A3b
        qwen3.6-27b
        ]]
        messages = messages
    }

    -- Encode JSON → Base64
    local json = json.serialize(payload) -- i forgot is it this or json:serialize(payload)
    local base64 = base64_encode(json)

    -- Send as form field
    local body = "input=" .. base64
    -- Use /internal/openai-compatiblev1 if it turns out you can change the content header and I am just stupid
    Http:Post("https://lunarai.pp.ua/internal/phpwrapper/openai-compatv1", body, function(data, error, errmsg)
        if error then
            callback(nil, errmsg)
            return
        end
        callback(data, nil)
    end, {})
end

-- Example
CallLunarAI({
    {role = "system", content = "You are a helpful assistant."},
    {role = "user", content = "Write a joke about robots"}
}, "smollm3-3b", function(result, err)
    print(result or err)
end)
