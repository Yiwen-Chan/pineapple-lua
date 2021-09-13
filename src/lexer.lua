---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-09-12 20:52:50
---@LastEditors: Kanri
---@LastEditTime: 2021-09-12 22:31:13
---@Description: Lexer

local sub = string.sub

t = {}

t.TOKEN_EOF = 0
t.TOKEN_VAR_PREFIX = 1
t.TOKEN_LEFT_PAREN = 2
t.TOKEN_RIGHT_PAREN = 3
t.TOKEN_EQUAL = 4
t.TOKEN_QUOTE = 5
t.TOKEN_DUOQUOTE = 6
t.TOKEN_NAME = 7
t.TOKEN_PRINT = 8
t.TOKEN_IGNORED = 9

t.token_name_map = {
    [t.TOKEN_EOF] = 'EOF',
    [t.TOKEN_VAR_PREFIX] = '$',
    [t.TOKEN_LEFT_PAREN] = '(',
    [t.TOKEN_RIGHT_PAREN] = ')',
    [t.TOKEN_EQUAL] = '=',
    [t.TOKEN_QUOTE] = '"',
    [t.TOKEN_DUOQUOTE] = '""',
    [t.TOKEN_NAME] = 'Name',
    [t.TOKEN_PRINT] = 'print',
    [t.TOKEN_IGNORED] = 'Ignored'
}

t.keywords = {
    ['print'] = t.TOKEN_PRINT
}

t.lexer = {
    source_code = '',
    line_num = 0,
    next_token = '',
    next_token_type = 0,
    next_token_line_num = 0
}

-- @param sourcecode string
function t.new_lexer(source_code)
   t.lexer.source_code = source_code
   t.lexer.line_num = 0
   t.lexer.next_token = ''
   t.lexer.next_token_type = 0
   t.lexer.next_token_line_num = 0
end

function t.get_line_num()
    return t.lexer.line_num
end

function t.skip_source_code(n)
    t.lexer.source_code = sub(lexer.source_code, n+1)
end

function t.is_ignore()
    local is_ignore = false
    while #t.lexer.source_code > 0 do
        local c1 = sub(t.lexer.source_code,1,1)
        local c2 = sub(t.lexer.source_code,1,2)
        if c1 == ' ' or c1 == '\t' or c1 == '\n' or c1 == '\v' or c1 == '\f' or c1 == '\r' then
            t.lexer.source_code = t.skip_source_code(1)
            is_ignore = true
        elseif c1 == '\r' or c1 == '\n' then
            t.lexer.source_code = t.skip_source_code(1)
            t.lexer.line_num = t.lexer.line_num + 1
            is_ignore = true
        elseif c2 == '\r\n' or c2 == '\n\r' then
            t.lexer.source_code = t.skip_source_code(2)
            t.lexer.line_num = t.lexer.line_num + 1
            is_ignore = true
        else
            break
        end
    end
    return is_ignore
end

function t.get_next_token()
    if (t.nextTokenLineNum > 0) then
        local token = t.lexer.next_token
        local token_type = t.lexer.next_token_type
        local line_num = t.lexer.next_token_line_num
        t.lexer.line_num = t.lexer.next_token_line_num
        t.lexer.next_token_line_num = 0
        return token, token_type, line_num
    end
    return t.match_token()
end

function t.match_token()
    if t.lexer.is_ignore() then
        return t.lexer.line_num, t.TOKEN_IGNORED, "Ignored"
    end
    if #t.lexer.source_code == 0 then
        return t.lexer.line_num, t.TOKEN_EOF, t.token_name_map[t.TOKEN_EOF]
    end
    local c1 = sub(t.lexer.source_code,1,1)
    local c2 = sub(t.lexer.source_code,1,2)
    if c1 == '$' then
        t.lexer.skip_source_code(1)
        return t.lexer.line_num, t.TOKEN_VAR_PREFIX, c1
    elseif c1 == '(' then
        t.lexer.skip_source_code(1)
        return t.lexer.line_num, t.TOKEN_LEFT_PAREN, c1
    elseif c1 == ')' then
        t.lexer.skip_source_code(1)
        return t.lexer.line_num, t.TOKEN_RIGHT_PAREN, c1
    elseif c1 == '=' then
        t.lexer.skip_source_code(1)
        return t.lexer.line_num, t.TOKEN_EQUAL, c1
    elseif c2 == '' then
        t.lexer.skip_source_code(2)
        return t.lexer.line_num, t.TOKEN_DUOQUOTE, c2
    elseif c1 == '"' then
        t.lexer.skip_source_code(1)
        return t.lexer.line_num, t.TOKEN_DUOQUOTE, c1
    end
    -- @todo 错误抛出
end

function t.is_letter(c)
    return c >= 'a' and c <= 'z' or c >= 'A' and c <= 'Z'
end