SMODS.Voucher{
    key = "sandwichfunc",
    loc_txt = {
        name = 'Sandwich Dismantling Pass',
        text = {
          '{C:inactive}Used for unpacking sandwiches...',
        },
    },
    atlas = 'vouchers',
    pos = {x = 0, y = 0},
    config = {},
    unlocked = true,
    discovered = true,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Ghost Joker', G.C.GREY, G.C.WHITE, 0.8)
    end,
    calculate = function(self,card,context) --Scards = {S_R, enhancements [table], edition [table], seal}
        if context.but_first then
            for i=1, #context.full_hand do
                if SMODS.has_enhancement(context.full_hand[i], 'm_ninehund_sandwichcard') and context.full_hand[i].ability["Scards"] ~= nil then
                    if #context.full_hand[i].ability.Scards > 0 then
                        local _scards_lookup = context.full_hand[i].ability.Scards
                        for x=1, #_scards_lookup do
                            local funnycard = make_card(_scards_lookup[x][1],nil, G.play, nil, G.C.SECONDARY_SET.Spectral)
                            funnycard.ability["is_sandwiched"] = true;
                            for a, m in pairs(_scards_lookup[x][2]) do
                                if m then
                                    funnycard:set_ability(G.P_CENTERS[tostring(a)]);
                                end
                            end
                            if _scards_lookup[x][3] ~= nil and _scards_lookup[x][3]["key"] ~= nil then
                                funnycard:set_edition(_scards_lookup[x][3]["key"],true,true);
                            end
                            if _scards_lookup[x][4] ~= nil then
                                funnycard:set_seal(_scards_lookup[x][4],true,true);
                            end
                        end
                    end
                end
            end
        end
        if context.destroy_card and context.cardarea == G.play then
            if context.destroying_card.ability["is_sandwiched"] then
                return { remove = true }
            end
        end
    end,
    in_pool = function()
        return false
    end,
}