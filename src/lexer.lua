---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-09-12 20:52:50
---@LastEditors: Kanri
---@LastEditTime: 2021-09-14 11:47:29
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
function t.lexer:new_lexer(source_code)
    self.source_code = source_code
    self.index = 1
    self.line_num = 0
    self.next_token = ''
    self.next_token_type = 0
    self.next_token_line_num = 0
end

-- @param n int
function t.lexer:skip_source_code(n)
    self.index = self.index + n
end

-- @param n int
function t.lexer:get_source_code(n)
    return sub(self.source_code, self.index, self.index + n - 1)
end

function t.lexer:is_ignore()
    local is_ignore = false
    while self.index <= 41 do
        local c1 = self:get_source_code(1)
        local c2 = self:get_source_code(2)
        if c1 == ' ' or c1 == '\t' or c1 == '\n' or c1 == '\v' or c1 == '\f' or c1 == '\r' then
            self:skip_source_code(1)
            is_ignore = true
        elseif c1 == '\r' or c1 == '\n' then
            self:skip_source_code(1)
            self.line_num = self.line_num + 1
            is_ignore = true
        elseif c2 == '\r\n' or c2 == '\n\r' then
            self:skip_source_code(2)
            self.line_num = self.line_num + 1
            is_ignore = true
        else
            break
        end
    end
    return is_ignore
end

function t.lexer:get_next_token()
    if (self.nextTokenLineNum > 0) then
        local token = self.next_token
        local token_type = self.next_token_type
        local line_num = self.next_token_line_num
        self.line_num = self.next_token_line_num
        self.next_token_line_num = 0
        return token, token_type, line_num
    end
    return self:match_token()
end

function t.lexer:match_token()
    if self:is_ignore() then
        return self.line_num, t.TOKEN_IGNORED, 'Ignored'
    end
    if self.index >= #self.source_code then
        return self.line_num, t.TOKEN_EOF, t.token_name_map[t.TOKEN_EOF]
    end
    local c1 = self:get_source_code(1)
    local c2 = self:get_source_code(2)
    if c1 == '$' then
        self:skip_source_code(1)
        return self.line_num, t.TOKEN_VAR_PREFIX, c1
    elseif c1 == '(' then
        self:skip_source_code(1)
        return self.line_num, t.TOKEN_LEFT_PAREN, c1
    elseif c1 == ')' then
        self:skip_source_code(1)
        return self.line_num, t.TOKEN_RIGHT_PAREN, c1
    elseif c1 == '=' then
        self:skip_source_code(1)
        return self.line_num, t.TOKEN_EQUAL, c1
    elseif c2 == '""' then
        self:skip_source_code(2)
        return self.line_num, t.TOKEN_DUOQUOTE, c2
    elseif c1 == '"' then
        self:skip_source_code(1)
        return self.line_num, t.TOKEN_DUOQUOTE, c1
    elseif c1 == "_" or self:is_letter(c1) then
        local start = self.index
        local finish = start
        while (self.index <= #self.source_code)
        do
            finish = self.index
            local c = self:get_source_code(1)
            if c == "_" or self:is_letter() then
                self:skip_source_code(1)
            else
                break
            end
        end
        return self.line_num, t.TOKEN_DUOQUOTE, sub(t.lexer.source_code, start, finish-1)
    end
    self:skip_source_code(1)
    -- @todo 错误抛出
end

function t.lexer:is_letter()
    local c = self:get_source_code(1)
    return c >= 'a' and c <= 'z' or c >= 'A' and c <= 'Z'
end

local source_code=[[$a = "pen pineapple apple pen."
print($a)]]
t.lexer:new_lexer(source_code)
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
t.lexer:match_token()
_, _, xxx = t.lexer:match_token()
print(xxx)