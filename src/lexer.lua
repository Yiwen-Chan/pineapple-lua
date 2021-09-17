---Copyright 2020-2021 the original author or authors
---@Author: Kanri
---@Date: 2021-09-12 20:52:50
---@LastEditors: Kanri
---@LastEditTime: 2021-09-17 20:05:39
---@Description: Lexer

local insert = table.insert
local sub = string.sub

const = {
    -- SPECIAL
    ILLEGAL = 0,
	EOF = 1,
	COMMENT = 2,
    -- LITERAL
    IDENT = 10,
    INT = 11,
    FLOAT = 12,
    IMAG = 13,
    CHAR = 14,
    STRING = 15,
    -- OPERATOR
    ADD = 20,
    SUB = 21,
    MUL = 22,
    QUO = 23,
    REM = 24,

    PRINT = 30
}

const.TOKENS = {
    -- SPECIAL
    [const.ILLEGAL] = 'ILLEGAL',
    [const.EOF] = 'EOF',
    [const.COMMENT] = 'COMMENT',
    -- LITERAL
    [const.IDENT] = 'IDENT',
    [const.INT] = 'INT',
    [const.FLOAT] = 'FLOAT',
    [const.IMAG] = 'IMAG',
    [const.CHAR] = 'CHAR',
    [const.STRING] = 'STRING',
    -- OPERATOR
    [const.ADD] = '+',
    [const.SUB] = '-',
    [const.MUL] = '/',
    [const.QUO] = '*',
    [const.REM] = '%',

    [const.PRINT] = 'print'
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
function lexer:init(source_code)
    self.src = source_code
    self.len = #self.src
    self.index = 1
    self.line = 1
end

-- @param n int
function lexer:set_next_index(n)
    self.index = self.index + n
end

-- @param n int
function lexer:set_next_line(n)
    self.line = self.line + n
end

-- @param n int
function lexer:get_cur_char(n)
    return sub(self.src, self.index, self.index + n - 1)
end

function lexer:is_letter(cur)
    local c = cur or self:get_cur_char(1)
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_'
end

function lexer:is_white_space(cur)
    local c = cur or self:get_cur_char(1)
    return c == ' ' or c == '\t' or c == '\v' or c == '\f'
end

function lexer:is_next_line(cur)
    local c = cur or self:get_cur_char(1)
    -- windows \r\n
    if self:get_cur_char(2) == '\r\n' then
        self:set_next_index(1)
        self:set_next_line(1)
        return true
    elseif c == '\n' or c == '\r' then
        self:set_next_line(1)
        return true
    end
    return false
end

function lexer:is_quote(cur)
    local c = cur or self:get_cur_char(1)
    return c == '"'
end

function lexer:is_note(cur)
    local c = cur or self:get_cur_char(2)
    return c == '\\\\'
end

function lexer:get_next_token()
    local outset = self.index
    while self.index <= self.len do
        local cur = self:get_cur_char(1)
        if self:is_quote(cur) then
            -- 字符串
            self:set_next_index(1)
            local is_escape = false
            local temp = {}
            while is_escape or ~self:is_quote() do
                local c = self:get_cur_char(1)
                if is_escape then
                    is_escape = false
                    insert(temp, #temp, c)
                    self:set_next_index(1)
                elseif c == '\\' then
                    is_escape = true
                    self:set_next_index(1)
                else
                    insert(temp, #temp, c)
                    self:set_next_index(1)
                end
            end
            return temp
        elseif self:is_note() then
            -- 跳过注释
            self:set_next_index(2)
            while ~self:is_next_line() do
                self:set_next_index(1)
            end
            return '\n'
        elseif self:is_letter(cur) then
            -- 英文字符
            self:set_next_index(1)
            while self:is_letter() do
                self:set_next_index(1)
            end
            local ident = sub(self.src, outset, self.index)
            if ident == 'if' then
                return 'if'
            end
        elseif self:is_white_space(cur) then
            -- 空白
            self:set_next_index(1)
            while self:is_white_space() do
                self:set_next_index(1)
            end
            return ' '
        elseif self:is_next_line(cur) then
            -- 换行
            self:set_next_index(1)
            while self:is_next_line() do
                self:set_next_index(1)
            end
            return '\n'
        end
    end
end
