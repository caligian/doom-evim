return to_callable(function(keys, font_switcher)
    assert_s(keys)

    kbd('n', keys or '<leader>hf', font_switcher, {noremap=true}, 'Switch to another font'):enable()
end)
