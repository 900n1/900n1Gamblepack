--====SEALS====
SMODS.Seal{
	object_type = "Seal",
    loc_txt = {
        name = 'Concealed Truth',
        text = {
          '{C:chips,s:1.2}Are you sure you',
          '{C:chips,s:1.2}know what it is?',
        },
        label = 'Deceit',
    },
	key = "truth",
	badge_colour = HEX("344E9E"),
	config = {},
	atlas = "enhance",
	pos = { x = 0, y = 0 },
	calculate = function(self, card, context)
		if context.before and context.cardarea == G.play then
            if card.ability.truth1 ~= nil and card.ability.truth2 ~= nil then
                SMODS.change_base(card,card.ability.truth1,card.ability.truth2)
            end
            card:set_seal(nil)
		end
	end,
    in_pool = function()
        return false
    end
}

--====ENHANCEMENTS====
SMODS.Enhancement{
	key = 'blankcard',
	loc_txt = {
		name = 'Blank Card',
		text = {
			'{C:inactive}No rank or suit.',
            '{C:inactive}It holds no value.',
            '{C:inactive}It does not matter.',
		}
	},
	config = {},
    weight = 0.01,
	pos = { x = 1, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'enhance',
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = false,
}

SMODS.Enhancement{
	key = 'multchip',
	loc_txt = {
		name = 'Extra Bonus Card',
		text = {
			'{C:chips}+#1#{} bonus Chips',
            '{C:mult}+#2#{} Mult'
		}
	},
	config = {bonus = 50, mult = 5},
	pos = { x = 4, y = 1 },
    weight = 1,
    effect = "Extra Bonus Card",
	unlocked = true,
	discovered = true,
	atlas = 'amalgam',
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.bonus,center.ability.mult}}
    end
}

SMODS.Enhancement{
	key = 'sandwichcard',
	loc_txt = {
		name = 'Card Sandwich',
		text = {
			'{C:attention}Contains playing cards{}',
            'Unpacks held playing cards',
            'into playing hand when played',
            'Repacks cards back into the',
            'sandwich after each hand',
		}
	},
	config = {},
    weight = 0,
	pos = { x = 2, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'enhance',
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function()
        return false
    end,
    loc_vars = function(self, info_queue, card)
        return {
            main_end = (card.ability.Scards ~= nil) and {
                {n=G.UIT.C, config={align = "bm", minh = 0.4}, nodes={
                    {n=G.UIT.C, config={ref_table = self, align = "m", colour = G.C.CLEAR, r = 0.05, padding = 0.06}, nodes={
                        generate_sandiwch_cards(card.ability.Scards)
                    }}
                }}
            } or nil
        }
    end
}