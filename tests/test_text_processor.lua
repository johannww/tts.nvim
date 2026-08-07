local text_processor = require("tts-nvim.text_processor")

local passed = 0
local failed = 0

local function test(name, input, expected, processor)
    local result = processor(input)
    if result == expected then
        passed = passed + 1
        print("  PASS: " .. name)
    else
        failed = failed + 1
        print("  FAIL: " .. name)
        print("    Input:    " .. input)
        print("    Expected: " .. expected)
        print("    Got:      " .. result)
    end
end

print("\n=== process_markdown_simple ===")

-- Basic link
test("basic link",
    "[link](url)",
    "link",
    text_processor.process_markdown_simple)

-- Multiple links
test("multiple links",
    "see [a](url1) and [b](url2) here",
    "see a and b here",
    text_processor.process_markdown_simple)

-- Link text with spaces
test("link text with spaces",
    "[multi word text](url)",
    "multi word text",
    text_processor.process_markdown_simple)

-- No links (pass through)
test("no links",
    "plain text without any links",
    "plain text without any links",
    text_processor.process_markdown_simple)

-- Bold markers
test("bold markers **",
    "**bold**",
    "bold",
    text_processor.process_markdown_simple)

-- Bold markers __
test("bold markers __",
    "__bold__",
    "bold",
    text_processor.process_markdown_simple)

-- Italic markers *
test("italic markers *",
    "*italic*",
    "italic",
    text_processor.process_markdown_simple)

-- Italic markers _
test("italic markers _",
    "_italic_",
    "italic",
    text_processor.process_markdown_simple)

-- Heading markers
test("heading markers",
    "# heading",
    "heading",
    text_processor.process_markdown_simple)

-- Inline code
test("inline code",
    "use `code` block",
    "use code block",
    text_processor.process_markdown_simple)

-- List markers
test("list marker *",
    "* item",
    "item",
    text_processor.process_markdown_simple)

-- List marker -
test("list marker -",
    "- item",
    "item",
    text_processor.process_markdown_simple)

-- HTML tags
test("html tags",
    "<p>text</p>",
    "text",
    text_processor.process_markdown_simple)

-- Image syntax (note: ! remains since it's outside the bracket pattern)
test("image syntax",
    "![alt](url)",
    "!alt",
    text_processor.process_markdown_simple)

print("\n=== process_latex_simple ===")

-- LaTeX command removal
test("latex command",
    "\\textbf{bold text}",
    " bold text",
    text_processor.process_latex_simple)

-- LaTeX braces
test("latex braces",
    "{content}",
    "content",
    text_processor.process_latex_simple)

-- LaTeX math
test("latex math",
    "$E=mc^2$",
    "E=mc^2",
    text_processor.process_latex_simple)

print("\n=== Results ===")
print(string.format("%d passed, %d failed, %d total", passed, failed, passed + failed))

if failed > 0 then
    vim.cmd("cq")
end
