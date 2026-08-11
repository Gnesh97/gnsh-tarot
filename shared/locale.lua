-- Resolves a locale key against Config.Locale, falling back to 'en', then to
-- the raw key itself so a missing translation never crashes a screen.
-- Extra args are applied with string.format when the template contains %s/%d.
function _L(key, ...)
    local table_ = Locales[Config.Locale] or Locales['en'] or {}
    local template = table_[key]

    if template == nil and Locales['en'] then
        template = Locales['en'][key]
    end

    if template == nil then
        return key
    end

    local args = { ... }
    if #args == 0 then
        return template
    end

    local ok, formatted = pcall(string.format, template, ...)
    if ok then
        return formatted
    end

    return template
end
