-- Place content at the bottom of a page
function process_macro (div)
    if div.classes[1] == 'bottom' then
        if FORMAT:match 'latex' then
            return pandoc.Plain {
                pandoc.RawInline('latex', '\\vfill\n')
            }
        else
            return {}
        end
    end
end

return {
    { Div = process_macro }
}