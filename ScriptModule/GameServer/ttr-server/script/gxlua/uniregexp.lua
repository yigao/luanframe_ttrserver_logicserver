uniregexp= uniregexp or {}

--[[
    exp: 
        uniregexp.match("foo.*","seafood") => true nil
        uniregexp.match("bar.*","seafood") => false nil
        uniregexp.match("a(b","seafood")   => false error parsing regexp: missing closing ): `a(b` 
--]]
uniregexp.match = function(pattern, s)
    return go.uniregexp.Match(pattern, s)
end

--[[
    exp: 
       quotemeta(`[foo]`) => `\[foo\]` 
--]]
uniregexp.quotemeta = function(s)
    return go.uniregexp.QuoteMeta(s)
end

-- 其余api可以调用go.uniregexp.***** 参考go语言 regexp.Regexp类方法
