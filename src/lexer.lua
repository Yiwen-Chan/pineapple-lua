---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-09-12 20:52:50
---@LastEditors: Kanri
---@LastEditTime: 2021-09-15 14:24:21
---@Description: Lexer

local sub = string.sub

const = {}

const.TOKEN_EOF = 0
const.TOKEN_VAR_PREFIX = 1
const.TOKEN_LEFT_PAREN = 2
const.TOKEN_RIGHT_PAREN = 3
const.TOKEN_EQUAL = 4
const.TOKEN_QUOTE = 5
const.TOKEN_DUOQUOTE = 6
const.TOKEN_NAME = 7
const.TOKEN_PRINT = 8
const.TOKEN_IGNORED = 9

const.token_name_map = {
    [const.TOKEN_EOF] = 'EOF',
    [const.TOKEN_VAR_PREFIX] = '$',
    [const.TOKEN_LEFT_PAREN] = '(',
    [const.TOKEN_RIGHT_PAREN] = ')',
    [const.TOKEN_EQUAL] = '=',
    [const.TOKEN_QUOTE] = '"',
    [const.TOKEN_DUOQUOTE] = '""',
    [const.TOKEN_NAME] = 'Name',
    [const.TOKEN_PRINT] = 'print',
    [const.TOKEN_IGNORED] = 'Ignored'
}

const.keywords = {
    ['print'] = const.TOKEN_PRINT
}

lexer = {
    source_code = '',
    line_num = 0,
    next_token = '',
    next_token_type = 0,
    next_token_line_num = 0
}

-- @param sourcecode string
function lexer:new_lexer(source_code)
    self.source_code = source_code
    self.index = 1
    self.line_num = 0
    self.next_token = ''
    self.next_token_type = 0
    self.next_token_line_num = 0
end

-- @param n int
function lexer:skip_source_code(n)
    self.index = self.index + n
end

-- @param n int
function lexer:get_source_code(n)
    return sub(self.source_code, self.index, self.index + n - 1)
end

function lexer:is_ignore()
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

function lexer:get_next_token()
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

function lexer:match_token()
    if self:is_ignore() then
        return self.line_num, const.TOKEN_IGNORED, 'Ignored'
    end
    if self.index >= #self.source_code then
        return self.line_num, const.TOKEN_EOF, const.token_name_map[const.TOKEN_EOF]
    end
    local c1 = self:get_source_code(1)
    local c2 = self:get_source_code(2)
    if c1 == '$' then
        self:skip_source_code(1)
        return self.line_num, const.TOKEN_VAR_PREFIX, c1
    elseif c1 == '(' then
        self:skip_source_code(1)
        return self.line_num, const.TOKEN_LEFT_PAREN, c1
    elseif c1 == ')' then
        self:skip_source_code(1)
        return self.line_num, const.TOKEN_RIGHT_PAREN, c1
    elseif c1 == '=' then
        self:skip_source_code(1)
        return self.line_num, const.TOKEN_EQUAL, c1
    elseif c2 == '""' then
        self:skip_source_code(2)
        return self.line_num, const.TOKEN_DUOQUOTE, c2
    elseif c1 == '"' then
        self:skip_source_code(1)
        return self.line_num, const.TOKEN_DUOQUOTE, c1
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
        return self.line_num, const.TOKEN_DUOQUOTE, sub(lexer.source_code, start, finish-1)
    end
    self:skip_source_code(1)
    -- @todo 错误抛出
end

function lexer:is_letter()
    local c = self:get_source_code(1)
    return c >= 'a' and c <= 'z' or c >= 'A' and c <= 'Z'
end

local source_code=[[$a = "pen pineapple apple pen."
print($a)]]
lexer:new_lexer(source_code)
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
lexer:match_token()
_, _, xxx = lexer:match_token()
print(xxx)