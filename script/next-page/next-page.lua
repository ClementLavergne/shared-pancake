-- Force going to next PDF page
function process_macro (div)
    if div.classes[1] == 'blank' then
        if FORMAT:match 'latex' then
            return pandoc.RawBlock('latex', '\\newpage\n')
        else
            return {}
        end
    end
end

return {
    { Div = process_macro }
}