local ruinVanilla = {
    "j_mime", "j_dna", "j_baron", "j_photograph", "j_hanging_chad", "j_trading", "j_sock_and_buskin", "j_bloodstone",
    "j_ring_master", "j_ancient","j_mail", "j_rocket", "j_selzer", "j_ramen", "j_oops", "j_idol", "j_chicot", "j_perkeo"
}

SMODS.Blind	{
    key = 'gameruin',
    loc_txt = {
        name = 'The Means More Than Necessary To Accomplish What This Blind Is Supposed To Do In A Modded Environment Wall',
        text = { 
            "Debuffs Blueprint and Brainstorm.",
            "Sells Mime, DNA, Baron, Photograph, Hanging Chad,",
            "Trading Card, Sock and Buskin, Bloodstone, Showman,",
            "Ancient Joker, Mail-In Rebate, Rocket, Seltzer, Ramen,",
            "Oops! All 6s, The Idol, Chicot and Perkeo.",
            "Sets the sell value of Egg to 0.",
            "Cavendish and Obelisk is given Eternal and Rental.",
            "Instantly kills 1 random card from your deck."
        }
    },
    boss = {min = 0, max = 9999, showdown = false},
    boss_colour = HEX("3C4C82"),
    atlas = "funny_blinds",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 0,
    no_debuff = true,
    discovered = true,
    descriptions = {
        "ninehund_bdesc_gameruin",
        "ninehund_bdesc_nodebuff"
    },
    mult = 4,
    in_pool = function(self)
        return G.GAME.n_darkworld
    end,
    set_blind = function(self)
        local find = {
            SMODS.find_card('j_blueprint'),
            SMODS.find_card('j_brainstorm')
        }
        for _, i in pairs(find) do
            if i ~= nil then
                for _, f in pairs(i) do
                    SMODS.debuff_card(f,true,"gameruin")
                end
            end
        end
        local destroyList = {}
        for i=1,#ruinVanilla do
            destroyList[i] = SMODS.find_card(ruinVanilla[i])
        end
        for _, i in pairs(destroyList) do
            if i ~= nil then
                for _, f in pairs(i) do
                    ease_dollars(f.sell_cost)
                    f:start_dissolve(nil,true);
                end
            end
        end
        local eggHi = SMODS.find_card("j_egg")
        if #eggHi > 0 then
            for _, f in pairs(eggHi) do
                f.sell_cost = 0
            end
        end
        local unfortunately = {
            SMODS.find_card('j_cavendish'),
            SMODS.find_card('j_obelisk')
        }
        for _, i in pairs(unfortunately) do
            if i ~= nil then
                for _, f in pairs(i) do
                    f.ability.eternal = true
                    f.ability.rental = true
                end
            end
        end
        G.playing_cards[math.random(1,#G.playing_cards)]:damage_card(99999)
    end,
    defeat = function(self)
        local find = {
            SMODS.find_card('j_blueprint',true),
            SMODS.find_card('j_brainstorm',true)
        }
        for _, i in pairs(find) do
            if i ~= nil then
                for _, f in pairs(i) do
                    SMODS.debuff_card(f,false,"gameruin")
                end
            end
        end
    end,
}

--lol back to the real blinds

local asriel_attacks = {
    function()
        for i=1, #G.hand.cards do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        local _poslol = (111)+(G.hand.cards[i].children.center.CT.x*G.hand.cards[i].children.center.scale.x)
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                        n_makeImage(
                            "att_light","att_light",
                            _poslol, ninehund.constants.CS.y-203, 0,
                            n_randNeg(5), 5,
                            function(self)
                                self.timer = self.timer + ninehund.dt
                                self.frame = n_nextFrame(self.totalframes,16,self.timer)
                                self.alpha = lerp(self.alpha,0,ninehund.dt*3)
                                self.x = self.posx+math.random(-20,20)
                                if self.alpha <= 0.05 then
                                    n_removeImage("att_light",nil,self.id)
                                end
                            end,
                            nil, nil, nil,
                            {timer = 0, id = i, posx = _poslol}
                        )
                    return true
                    end
                }))
            end
        end
    end,
    function()
        for i=#G.hand.cards, 1, -1 do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        local _poslol = (111)+(G.hand.cards[i].children.center.CT.x*G.hand.cards[i].children.center.scale.x)
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                        n_makeImage(
                            "att_light","att_light",
                            _poslol, ninehund.constants.CS.y-203, 0,
                            n_randNeg(5), 5,
                            function(self)
                                self.timer = self.timer + ninehund.dt
                                self.frame = n_nextFrame(self.totalframes,16,self.timer)
                                self.alpha = lerp(self.alpha,0,ninehund.dt*3)
                                self.x = self.posx+math.random(-20,20)
                                if self.alpha <= 0.05 then
                                    n_removeImage("att_light",nil,self.id)
                                end
                            end,
                            nil, nil, nil,
                            {timer = 0, id = i, posx = _poslol}
                        )
                    return true
                    end
                }))
            end
        end
    end,
    function()
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
                n_makeImage(
                    "att_sword","asrielslash",
                    ninehund.constants.CS.x-61, ninehund.constants.CS.y, 0,
                    -6, 6,
                    function(self)
                        self.timer = self.timer + ninehund.dt
                        self.frame = n_nextFrame(self.totalframes,16,self.timer)
                        if self.frame == 9 then
                            n_removeImage("att_sword")
                        end
                    end,
                    true, 1, 
                    {
                        frames = 9,
                        px = 123, py = 161
                    },
                    {timer = 0}
                )
                for i=1, math.floor(#G.hand.cards/2) do
                    G.hand.cards[i]:damage_card(2);
                    G.ROOM.jiggle = 2
                end
                return true
            end
        }))
    end,
    function()
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
                n_makeImage(
                    "att_sword","asrielslash",
                    ninehund.constants.CS.x+184, ninehund.constants.CS.y, 0,
                    6, 6,
                    function(self)
                        self.timer = self.timer + ninehund.dt
                        self.frame = n_nextFrame(self.totalframes,16,self.timer)
                        if self.frame == 9 then
                            n_removeImage("att_sword")
                        end
                    end,
                    true, 1, 
                    {
                        frames = 9,
                        px = 123, py = 161
                    },
                    {timer = 0}
                )
                for i=#G.hand.cards,math.floor((#G.hand.cards/2)+0.5), -1  do
                    G.hand.cards[i]:damage_card(2);
                    G.ROOM.jiggle = 2
                end
                return true
            end
        }))
    end,
    function()
        play_sound('ninehund_asriel_star', math.random(9,11)*0.1,0.5);
        for i=1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    play_sound('ninehund_asriel_hit', math.random(9,11)*0.1,0.5);
                    local _ouch = pseudorandom_element(G.hand.cards, pseudoseed('attack'))
                    _ouch:damage_card(2)
                    n_makeImage(
                        "att_star","starboom",
                        (292*0.5)+(_ouch.children.center.CT.x*_ouch.children.center.scale.x), ninehund.constants.CS.y, 0,
                        1.2, 1.2,
                        function(self)
                            self.timer = self.timer + ninehund.dt
                            self.frame = n_nextFrame(self.totalframes,16,self.timer)
                            if self.frame == 5 then
                                n_removeImage("att_star",nil,self.id)
                            end
                        end,
                        true, 1, 
                        {
                            frames = 5,
                            px = 292, py = 292
                        },
                        {timer = 0, id = i}
                    )
                    G.ROOM.jiggle = 2
                    return true
                end
            }))
        end
    end,
}

SMODS.Blind	{
    key = 'asriel',
    loc_txt = {
        name = 'God of HYPERDEATH',
        text = { 
            "It's the end, isn't it?"
        }
    },
    boss = {min = 8, max = 64, showdown = true},
    boss_colour = HEX("273133"),
    atlas = "asriel",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 15,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_gift",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_asriel"
    },
    mult = 6,
    remaining_hits = 6,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindStart = true
        G.GAME.n_blindEnd = false
        G.GAME.n_blindFinal = false
        local find = SMODS.find_card('j_ninehund_asrieljoker');
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,true,"asriel")
            end
        end
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindStart then
            G.GAME.n_blindStart = false;
        elseif G.GAME.n_blindFinal then
            G.GAME.n_blindFinal = false;
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    play_sound('ninehund_asriel_goner', 1,0.5);
                    n_makeImage(
                        "goner","hypergoner",
                        ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
                        3, 3,
                        function(self)
                            self.timer = self.timer + ninehund.dt
                            self.frame = n_nextFrame(self.totalframes,18,self.timer)
                            if self.timer >= 2.5 then
                                n_removeImage("goner")
                            end
                        end,
                        true, 1, 
                        {
                            frames = 8,
                            px = 640, py = 380
                        },
                        {
                            timer = 0,
                        }
                    )
                    change_blind_size(to_big(G.GAME.blind.chips)*to_big(10))
                    for i=1, #G.hand.cards do
                        G.hand.cards[i]:damage_card(0);
                    end
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                timer = "REAL",
                delay = 2.5,
                func = function()
                    n_screen(1,0)
                    play_sound('ninehund_und_flash', 0.6,0.5);
                    for i=1, #G.hand.cards do
                        G.hand.cards[i].ability.health = 1;
                    end
                    return true
                end
            }))
        else
            pseudorandom_element(asriel_attacks, pseudoseed('attack'))();
        end
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        local find = SMODS.find_card('j_ninehund_asrieljoker',true);
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,false,"asriel")
            end
        end
        local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_asrieljoker');
        _card:add_to_deck()
        _card:start_materialize()
        G.jokers:emplace(_card)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if score >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if G.GAME.n_blindHits <= 1 then
                            G.GAME.n_blindEnd = true
                            G.GAME.n_blindFinal = true
                        end
                        play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                        n_screen(2,0)
                        return true
                    end
                })) 
                for o = 1, 20 do
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = o*0.01,
                        func = function()
                            ease_background_colour({new_colour = hsvToRgb(((o/3)+(G.GAME.n_blindHits*3))/20,1,(20/o)/20,1), special_colour = hsvToRgb(((o/3)+(self.remaining_hits*6))/20,1,1,1), contrast = 2})
                            G.ROOM.jiggle = 20/o
                            return true
                        end
                    })) 
                end
                play_area_status_text(G.GAME.n_blindHits.." out of 6 left.", false, 2);
                refresh_deck();
            elseif G.GAME.n_blindHits <= 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            n_screen(2,0)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            G.GAME.n_blindEnd = false;
                            G.GAME.nine_musicspeed = 0.01;
                        end
                        return true
                    end
                })) 
                return score
            else
                play_area_status_text("MISS", false, 2);
            end
        end
        return 0
    end,
}

SMODS.Blind	{
    key = 'fear',
    loc_txt = {
        name = 'FEAR',
        text = { 
            "All I did... was try to save you..."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("45105A"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 2},
    vars = {},
    dollars = 7,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_fear"
    },
    mult = 6,
    remaining_hits = 3,
    in_pool = function(self)
        return false
    end,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindReset = false
        G.GAME.n_blindEnd = false
        for k,v in pairs(G.jokers.cards) do
            v:flip()
        end
        n_makeImage(
            "blindeffect","feareffect",
            ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
            6, 6,
            function(self)
                if G.GAME.n_blindEnd then
                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                else
                    self.alpha = lerp(self.alpha,1,0.05*ninehund.dt)
                end
                self.frame = n_nextFrame(4,4,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 320, py = 180
            },
            {
                alpha = 0
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k,v in pairs(G.jokers.cards) do
            SMODS.debuff_card(v,false,"fear")
        end
        n_removeImage('blindeffect')
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.." out of 3 left.", false, 2);
                refresh_deck();
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    G.GAME.n_blindEnd = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                n_screen(2,0)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
    end,
    stay_flipped = function(self, area, card)
        return true
    end,
    press_play = function(self)
        for k,v in pairs(G.jokers.cards) do
            SMODS.debuff_card(v,false,"fear")
        end
        local currentjokers = {}
        for k, v in ipairs(G.jokers.cards) do currentjokers[#currentjokers+1] = v end
        local chosenjokers = {}
        pseudoshuffle(currentjokers, pseudoseed('attack'))
        for i=1, math.max(1,math.floor(#currentjokers/4)) do
            chosenjokers[i] = currentjokers[i]
        end
        for k, v in pairs(chosenjokers) do
            SMODS.debuff_card(v,true,"fear")
        end
    end,
    on_click = function(self, x, y)
        if G.CONTROLLER.hovering.target and G.CONTROLLER.hovering.target.config.center ~= nil then
            if G.CONTROLLER.hovering.target.config.center.set == "Default" then
                pseudoshuffle(G.hand.cards,pseudoseed('lmao'))
            end
        end
    end
}

SMODS.Blind	{
    key = 'greed',
    loc_txt = {
        name = 'GREED',
        text = { 
            "You really fell for it!"
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("C8A24A"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 0,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_greed"
    },
    mult = 6,
    remaining_hits = 3,
    fail_safe = true,
    in_pool = function(self)
        return false
    end,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindReset = false
        G.GAME.n_blindEnd = false
        G.GAME.n_blindTarget = nil
        self.fail_safe = false
        n_makeImage(
            "blindeffect","greedeffect",
            ninehund.constants.CS.x, 9999, 0,
            3, 3,
            function(self)
                if G.GAME.n_blindTarget ~= nil then
                    self.x = (self.SSTable.px*2)+(G.GAME.n_blindTarget.children.center.CT.x*G.GAME.n_blindTarget.children.center.scale.x)
                    self.y = lerp(self.y,(self.SSTable.px*5)+(G.GAME.n_blindTarget.children.center.CT.y*G.GAME.n_blindTarget.children.center.scale.y),5*ninehund.dt)
                else
                    self.y = lerp(self.y,ninehund.constants.WS.y*2,5*ninehund.dt)
                end
                self.frame = n_nextFrame(4,4,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 71, py = 380
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"greed")
        end
        n_removeImage('blindeffect')
        ease_dollars(-G.GAME.dollars/2, true)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.." out of 3 left.", false, 2);
                refresh_deck();
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                G.GAME.n_blindEnd = true;
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            n_screen(2,0)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            G.GAME.nine_musicspeed = 0;
                        end
                        return true
                    end
                })) 
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
        G.GAME.n_blindTarget = pseudorandom_element(G.hand.cards, pseudoseed('attack'))
        G.GAME.n_blindTarget.ability.forced_selection = true
        G.hand:add_to_highlighted(G.GAME.n_blindTarget)
    end,
    press_play = function(self)
        if self.fail_safe then
            self.fail_safe = false
        else
            SMODS.debuff_card(G.GAME.n_blindTarget,true,"greed")
        end
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 1,
            func = function()
                G.GAME.n_blindTarget = nil
                return true
            end
        })) 
    end,
    on_discard = function(self, card)
        if card == G.GAME.n_blindTarget then
            G.GAME.n_blindTarget = nil
            return true
        end
    end
}

SMODS.Blind	{
    key = 'solitude',
    loc_txt = {
        name = 'SOLITUDE',
        text = { 
            "As I watch you descend",
            "into the void with me..."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("234B91"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 1},
    vars = {},
    dollars = 7,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_solitude"
    },
    mult = 6,
    remaining_hits = 4,
    in_pool = function(self)
        return false
    end,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindEnd = false
        G.GAME.n_blindReset = false
        G.GAME.n_solitudeEye = true
        G.GAME.n_solitudeEyeCount = 0
        G.GAME.n_solitudeSpeed = G.SETTINGS.GAMESPEED
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"solitude")
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                G.SETTINGS.GAMESPEED = G.GAME.n_solitudeSpeed
                return true
            end
        })) 
        n_removeImage('blindeffect',true)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.." out of 4 left.", false, 2);
                refresh_deck();
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                G.GAME.n_blindEnd = true;
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            n_screen(2,0)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            G.GAME.nine_musicspeed = 0;
                        end
                        return true
                    end
                })) 
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
        G.GAME.n_solitudeEye = true
    end,
    press_play = function(self)
        G.GAME.n_solitudeEye = false
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" and v.active then
                alarmed = true
            end
        end
        if alarmed then
            for k, v in pairs(G.hand.highlighted) do
                SMODS.debuff_card(v,true,"solitude")
            end
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                G.SETTINGS.GAMESPEED = G.GAME.n_solitudeSpeed
                return true
            end
        })) 
    end,
    on_discard = function(self, card)
        G.GAME.n_solitudeEye = false
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" and v.active then
                alarmed = true
            end
        end
        if alarmed then
            SMODS.debuff_card(card,true,"solitude")
        end
    end,
    per_tick = function(self, t)
        if not G.GAME.n_blindEnd and G.GAME.n_solitudeEye then 
            G.SETTINGS.GAMESPEED = 1
            if math.fmod(t,100) == 0 and math.random() < 0.5  then
                for i=1, math.random(1,3) do
                    G.GAME.n_solitudeEyeCount = G.GAME.n_solitudeEyeCount + 1
                    play_sound('crumple2', math.random(9,11)*0.1,1);
                    n_makeImage(
                        "blindeffect","solitudeeffect",
                        (ninehund.constants.CS.x+(n_randrange(0.45)*ninehund.constants.WS.x)), (ninehund.constants.CS.y-(math.random()*0.35*ninehund.constants.WS.y)), 0,
                        1, 1,
                        function(self)
                            if G.GAME.blind.config.blind.key ~= "bl_ninehund_solitude" then n_removeImage("blindeffect",nil,self.id) end
                            self.timer = self.timer + ninehund.dt
                            if self.close then
                                self.active = false
                                if self.frame == 11 then 
                                    n_removeImage("blindeffect",nil,self.id) 
                                else
                                    self.frame = n_nextFrame(5,8,self.timer)+6
                                end
                            else
                                if self.frame < 5 then
                                    self.frame = n_nextFrame(5,8,self.timer)
                                else
                                    self.active = true
                                    self.frame = n_nextFrame(3,4,self.timer)+4
                                end
                            end
                        end,
                        true, 1,
                        {
                            frames = 11,
                            px = 119, py = 82
                        }, 
                        {
                            id = G.GAME.n_solitudeEyeCount,
                            timer = 0,
                            close = false,
                            active = false
                        }
                    )
                end
            end
        end
    end,
    on_click = function(self, x, y)
        local alarmed = false
        for _, v in pairs(ninehund.imagetable.images) do
            if v.key == "blindeffect" then
                if CheckCollision(v.x-v.ox,v.y-v.oy,v.SSTable.px,v.SSTable.py,x,y,2,2) and not v.close then 
                    v.close = true
                    v.timer = 0
                    play_sound('crumple1', math.random(9,11)*0.1,1);
                end
                if v.active then
                    alarmed = true
                end
            end
        end
        if G.CONTROLLER.hovering.target and G.CONTROLLER.hovering.target.config.center ~= nil then
            if G.CONTROLLER.hovering.target.config.center.set == "Default" and alarmed then
                for k, v in pairs(G.hand.cards) do
                    v:damage_card(1)
                end
            end
        end
    end
}

SMODS.Blind	{
    key = 'hatred',
    loc_txt = {
        name = 'HATRED',
        text = { 
            "FOR I AM THE SCOURGE OF EVERYONE",
            "THAT YOU CANNOT HIDE."
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("7C0503"),
    atlas = "blocktales_blinds",
    pos = {x = 0, y = 3},
    vars = {},
    dollars = 10,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_mysteryunlock",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_hatred"
    },
    mult = 10,
    remaining_hits = 3,
    in_pool = function(self)
        return false
    end,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindReset = false
        G.GAME.n_blindEnd = false
        G.GAME.n_blindPlaying = false
        local find = SMODS.find_card('j_ninehund_asrieljoker');
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,true,"hatred")
                f:flip()
            end
        end
        n_makeImage(
            "blindeffect","hatredeffect",
            ninehund.constants.CS.x, ninehund.constants.CS.y, 0,
            1.5, 1.5,
            function(self)
                if G.GAME.n_blindEnd then
                    self.alpha = lerp(self.alpha,0,2*ninehund.dt)
                else
                    self.alpha = lerp(self.alpha,0.8,0.5*ninehund.dt)
                end
                self.frame = n_nextFrame(4,8,G.TIMERS.REAL)
            end,
            true, 1,
            {
                frames = 4,
                px = 1280, py = 720
            },
            {
                alpha = 0
            }
        )
    end,
    defeat = function(self)
        G.GAME.nine_musicspeed = 1;
        for k, v in pairs(G.playing_cards) do
            SMODS.debuff_card(v,false,"hatred")
        end
        n_removeImage('blindeffect')
        local find = SMODS.find_card('j_ninehund_asrieljoker',true);
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,false,"hatred")
            end
        end
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.." out of 3 left.", false, 2);
                refresh_deck();
                change_blind_size(to_big(G.GAME.blind.chips)*to_big(5))
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    self.ending = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                n_screen(2,0)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
        G.GAME.n_blindPlaying = false
    end,
    press_play = function(self)
        G.GAME.n_blindPlaying = true
        SMODS.debuff_card(pseudorandom_element(G.hand.highlighted, pseudoseed('attack')),true,"hatred")
    end,
    per_tick = function(self, t)
        if not G.GAME.n_blindEnd and not G.GAME.n_blindPlaying then 
            if math.fmod(t,300) == 0 then
                for k, v in pairs(G.hand.cards) do
                    v:damage_card(1)
                end
            end
        end
    end
}

SMODS.Blind	{
    key = 'titan',
    loc_txt = {
        name = 'TITAN',
        text = { 
            "End of the line.",
        }
    },
    boss = {min = -9999, max = -9999, showdown = true},
    boss_colour = HEX("D8D8D8"),
    atlas = "roaring_blinds",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 0,
    no_debuff = true,
    no_reroll = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_titan"
    },
    mult = 100,
    remaining_hits = 100,
    in_pool = function(self)
        return false
    end,
    set_blind = function(self)
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindReset = false
        G.GAME.n_blindEnd = false
        G.GAME.n_blindPlaying = false
    end,
    defeat = function(self)
        play_area_status_text("INTERESTING. VERY INTERESTING.", false, 2);
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.."..", false, 2);
                refresh_deck();
                change_blind_size(to_big(G.GAME.blind.chips)*to_big(100))
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    self.ending = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                n_screen(2,0)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
        G.GAME.n_blindPlaying = false
    end,
    press_play = function(self)
        G.GAME.n_blindPlaying = true
    end,
    per_tick = function(self, t)
        if not G.GAME.n_blindEnd and not G.GAME.n_blindPlaying then 
            if math.fmod(t,20) == 0 then
                change_blind_size(to_big(G.GAME.blind.chips)*to_big(10),true,true)
            end
            if math.fmod(t,200) == 0 then
                local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_titanspawn');
                _card:add_to_deck()
                _card:start_materialize()
                G.jokers:emplace(_card)
            end
        end
    end
}

local mathQuestions = {
    [1] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];return a+b end,
            str = function(tab) local a = tab[1];local b = tab[2];return a.." + "..b end,
            vals = function() return {math.random(-100,100),math.random(-100,100)} end
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];return a-b end,
            str = function(tab) local a = tab[1];local b = tab[2];return a.." - "..b end,
            vals = function() return {math.random(-100,100),math.random(-100,100)} end
        }
    },
    [2] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];return a*b end,
            str = function(tab) local a = tab[1];local b = tab[2];return a.." * "..b end,
            vals = function() return {math.random(-12,12),math.random(-12,12)} end
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];return a/b end,
            str = function(tab) local a = tab[1];local b = tab[2];return a.." / "..b end,
            vals = function() 
                local nums = {math.random(-12,12),math.random(-12,12)}
                if nums[1] == 0 then nums[1] = nums[1] + 1 end
                if nums[2] == 0 then nums[2] = nums[2] + 1 end
                return {nums[1]*nums[2],nums[math.random(1,2)]}
            end
        }
    },
    [3] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c-(a+b) end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c.."-("..a.."+"..b..")" end,
            vals = function() return {math.random(-100,100),math.random(-100,100),math.random(-10,10)} end
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c+(a*b) end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c.."+("..a.."*"..b..")" end,
            vals = function() return {math.random(-12,12),math.random(-12,12),math.random(-10,10)} end
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c+(a/b) end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c.."+("..a.."/"..b..")" end,
            vals = function()
                local nums = {math.random(-12,12),math.random(-12,12)}
                if nums[1] == 0 then nums[1] = nums[1] + 1 end
                if nums[2] == 0 then nums[2] = nums[2] + 1 end
                return {nums[1]*nums[2],nums[math.random(1,2)],math.random(-10,10)} 
            end
        },
    },
    [4] = {
        {
            eq = function(tab) local a = tab[1];return a^3 end,
            str = function(tab) local a = tab[1];return (a<0 and ("("..a..")^3")) or (a.."^3") end,
            vals = function() return {math.random(-5,5)} end
        },
        {
            eq = function(tab) local a = tab[1];return math.sqrt(a) end,
            str = function(tab) local a = tab[1];return "sqrt("..a..")" end,
            vals = function() return {math.random(6,15)^2} end
        }
    },
    [5] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return (a-c)/b end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return b.."x+"..c.."="..a..", x=?" end,
            vals = function() 
                local nums = {math.random(-12,12),math.random(-12,12)}
                local othernum = math.random(1,20)
                if nums[1] == 0 then nums[1] = nums[1] + 1 end
                if nums[2] == 0 then nums[2] = nums[2] + 1 end
                return {(nums[1]*nums[2])+othernum,nums[math.random(1,2)],othernum}
            end
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return (a+c)/b end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return b.."x-"..c.."="..a..", x=?" end,
            vals = function() 
                local nums = {math.random(-12,12),math.random(-12,12)}
                local othernum = math.random(1,20)
                if nums[1] == 0 then nums[1] = nums[1] + 1 end
                if nums[2] == 0 then nums[2] = nums[2] + 1 end
                return {(nums[1]*nums[2])-othernum,nums[math.random(1,2)],othernum}
            end
        }
    },
    [6] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return b end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return c.."=("..a.."^2)+".."(x^2), x=?" end,
            vals = function() 
                local nums = {math.random(2,10),math.random(2,10)}
                return {nums[1],nums[2],(nums[1]^2)+(nums[2]^2)}
            end,
            allow_neg = true
        }
    },
    [7] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];local d = tab[4];return (a-c)/(b-d) end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];local d = tab[4];return (a < 0 and (b.."x+"..c.."="..d.."x-"..-a..", x=?")) or (b.."x+"..c.."="..d.."x+"..a..", x=?") end,
            vals = function() 
                local nums = {math.random(-10,10),math.random(-10,10)}
                local othernums = {math.random(1,20),math.random(1,20)}
                local rand = math.random(1,2)
                if nums[1] == 0 then nums[1] = nums[1] + 1 end
                if nums[2] == 0 then nums[2] = nums[2] + 1 end
                if nums[rand] - othernums[1] == 0 then othernums[1] = othernums[1] - 1 end
                return {(nums[1]*nums[2])+othernums[2],nums[rand]+othernums[1],othernums[2],othernums[1]}
            end
        }
    },
    [8] = {
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];local ans = (a*b)-c;return (ans%2==0 and 1) or -1 end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return "(-1)^[("..a.."*"..b..")-"..c.."]" end,
            vals = function() 
                return {math.random(99,999),math.random(99,999),math.random(99,999)}
            end,
        },
        {
            eq = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];local ans = a*(b-c);return (ans%2==0 and 1) or -1 end,
            str = function(tab) local a = tab[1];local b = tab[2];local c = tab[3];return "(-1)^["..a.."*("..b.."-"..c..")]" end,
            vals = function() 
                return {math.random(99,999),math.random(99,999),math.random(99,999)}
            end,
        },
    },
    [9] = {
        {
            eq = function(tab) return 1 end,
            str = function(tab) return "csc^2 x - cot^2 x" end,
            vals = function() 
                return {1}
            end,
        }
    }
}

SMODS.Blind	{
    key = 'algebra',
    loc_txt = {
        name = 'Algebra',
        text = { 
            "Good luck."
        }
    },
    boss = {min = 8, max = 9999, showdown = true},
    boss_colour = HEX("13A7DF"),
    atlas = "funny_blinds",
    pos = {x = 0, y = 1},
    vars = {},
    dollars = 20,
    no_debuff = true,
    no_pause = true,
    descriptions = {
        "ninehund_bdesc_algebra",
        "ninehund_bdesc_boss",
        "ninehund_bdesc_nopause",
    },
    mult = 1,
    remaining_hits = 9,
    fail_safe = true,
    equation = {},
    vals = nil,
    str = nil,
    set_blind = function(self)
        G.GAME.nine_disableplay = true
        G.GAME.n_blindHits = self.remaining_hits
        G.GAME.n_blindReset = false
        G.GAME.n_blindEnd = false
        G.GAME.n_blindPlaying = false
        G.GAME.n_algebraInput = 0
        G.GAME.n_blindPunish = 0
        self.fail_safe = false
    end,
    defeat = function(self)
        G.GAME.nine_disableplay = false
        G.GAME.nine_musicspeed = 1;
        local _card = create_card('Joker',G.jokers,nil,nil,nil,nil,'j_ninehund_algebrajoker');
        _card:add_to_deck()
        _card:start_materialize()
        G.jokers:emplace(_card)
    end,
    cap_score = function(self, score, deco)
        if not deco then
            if to_big(score) + to_big(G.GAME.chips) >= G.GAME.blind.chips and G.GAME.n_blindHits > 1 then
                G.GAME.n_blindHits = G.GAME.n_blindHits - 1
                G.GAME.n_blindReset = true
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left - G.GAME.n_blindPunish,true);
                ease_discard(math.max(1, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                play_area_status_text(G.GAME.n_blindHits.." hits left.", false, 2);
                refresh_deck();
                return 0
            elseif G.GAME.n_blindHits <= 1 then
                if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                    self.ending = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = 0.1,
                        blockable = true,
                        func = function()
                                n_screen(2,0)
                                play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                                G.GAME.nine_musicspeed = 0;
                            return true
                        end
                    })) 
                end
            end
        end
        return score
    end,
    drawn_to_hand = function(self)
        if G.GAME.n_blindReset then
            G.GAME.n_blindReset = false;
            ease_chips(0);
        end
        G.GAME.nine_disableplay = true
        G.GAME.n_algebraInput = 0
        self.equation = pseudorandom_element(mathQuestions[(G.GAME.n_blindHits > 0 and 10-G.GAME.n_blindHits<=#mathQuestions) and 10-G.GAME.n_blindHits or #mathQuestions], pseudoseed('math')) --pseudorandom_element(mathQuestions[G.GAME.n_blindHits > 0 and 17-G.GAME.n_blindHits or 16], pseudoseed('math'))
        self.vals = self.equation.vals()
        self.str = self.equation.str(self.vals)
        self.ans = self.equation.eq(self.vals)
        G.GAME.n_blindPlaying = false
        n_removeImage("blindeffect",true)
        n_makeImage(
            "blindeffect","fakeInfoBox",
            ninehund.constants.CS.x-120, -400, math.rad(n_randrange(60)),
            1.5, 1.5,
            function(self)
                if not G.GAME.n_blindPlaying then
                    self.timer = self.timer + ninehund.dt
                    self.y = lerp(self.y,ninehund.constants.CS.y-60,5*ninehund.dt)
                    self.r = lerp(self.r,0,5*ninehund.dt)
                    love.graphics.push()
                    love.graphics.setColor(G.C.RAINBOW)
                    love.graphics.rectangle("fill", self.x-(self.ox*self.sx)+10,self.y-20,lerp((self.ox*2*self.sx)-20,0,self.timer/10),20)
                    love.graphics.pop()
                    if self.timer > 10 then
                        G.GAME.n_blindPlaying = true
                        if G.GAME.blind.config.blind.ans == G.GAME.n_algebraInput or (G.GAME.blind.config.blind.equation.allow_neg and G.GAME.blind.config.blind.ans == -G.GAME.n_algebraInput) then
                            G.GAME.nine_disableplay = false
                        else
                            G.GAME.n_blindPunish = G.GAME.n_blindPunish + 1
                            G.GAME.blind.config.blind.drawn_to_hand(G.GAME.blind.config.blind)
                            ease_hands_played(-1,true)
                            if G.GAME.current_round.hands_left <= 0 then
                                G.STATE = G.STATES.GAME_OVER
                                G.STATE_COMPLETE = false
                            end
                        end
                    end
                else
                    self.acc = self.acc + ninehund.dt
                    self.x = self.x + self.rand2
                    self.y = self.y + (self.acc*40)
                    self.r = self.r + self.rand
                    if self.y > ninehund.constants.WS.y+240 then
                        n_removeImage("blindeffect")
                    end
                end
                self.frame = n_nextFrame(4,4,G.TIMERS.REAL)
                love.graphics.push()
                love.graphics.setColor(G.C.WHITE)
                drawCenteredText(self.x-(self.ox)*1.5,self.y-(self.oy)*1.5,self.ox*2*1.5,self.oy*1.5,G.GAME.blind.config.blind.str,2,self.r)
                if G.GAME.n_algebraInput ~= nil then
                    love.graphics.setColor(G.C.GREEN)
                    drawCenteredText(self.x-(self.ox)*1.5,self.y-(self.oy)*0.125,self.ox*2*1.5,self.oy*1.5,tostring(G.GAME.n_algebraInput),2,self.r)
                end
                love.graphics.pop()
            end,
            nil,nil,nil,{
                rand = n_randrange(0.4), acc = 0,rand2 = n_randrange(20), timer = 0
            }
        )
        local ohyouthinkyougotit = -1
        for i=0, 12 do
            if (i-1)%3==0 then ohyouthinkyougotit = ohyouthinkyougotit + 1 end
            if i==0 then ohyouthinkyougotit = ohyouthinkyougotit + 1 end
            local imgonnablow = (i>0 and ninehund.constants.CS.x+(((i-1)%3)*174)+200) or ninehund.constants.CS.x+(((i-2)%3)*174)+200
            n_makeImage(
                "Abuttons","numberButtons",
                imgonnablow, ninehund.constants.WS.y+200, 0,
                1, 1,
                function(self)
                    if not G.GAME.n_blindPlaying then
                        self.y = lerp(self.y,self.buttpos,5*ninehund.dt)
                        self.r = lerp(self.r,0,5*ninehund.dt)
                        self.sx = lerp(self.sx,1,5*ninehund.dt)
                        self.sy = lerp(self.sy,1,5*ninehund.dt)
                    else
                        self.acc = self.acc + ninehund.dt
                        self.x = self.x + self.rand2
                        self.y = self.y + (self.acc*40)
                        self.r = self.r + self.rand
                        if self.y > ninehund.constants.WS.y+300 then
                            n_removeImage("Abuttons",nil,self.id)
                        end
                    end
                end,
                true, i+1,
                {
                    frames = 13,
                    px = 172, py = 74
                },
                {
                    id = i, acc = 0, buttpos = ninehund.constants.CS.y+(ohyouthinkyougotit*-70)+100, rand2 = n_randrange(20), rand = n_randrange(0.4)
                }
            )
        end
    end,
    per_tick = function(self, t)
        if self.fail_safe then
            self.fail_safe = false
            G.GAME.nine_disableplay = false
            self.drawn_to_hand(self)
        end
    end,
    press_play = function(self)
        G.GAME.n_blindPlaying = true
    end,
    on_click = function(self, x, y)
        for _, v in pairs(ninehund.imagetable.images) do
            if CheckCollision(v.x-(v.ox*v.sx),v.y-(v.oy*v.sy),v.ox*2*v.sx,v.oy*2*v.sy,x,y,2,2) then 
                if v.key == "Abuttons" then
                    local str = tostring(G.GAME.n_algebraInput)
                    if v.id < 10 then
                        G.GAME.n_algebraInput = tonumber(str..v.id)
                        G.GAME.n_algebraInput = (G.GAME.n_algebraInput and G.GAME.n_algebraInput) or 0
                    elseif v.id == 10 then
                        G.GAME.n_blindPlaying = true
                        if self.ans == G.GAME.n_algebraInput or (self.equation.allow_neg and self.ans == -G.GAME.n_algebraInput) then
                            G.GAME.nine_disableplay = false
                        else
                            G.GAME.n_blindPunish = G.GAME.n_blindPunish + 1
                            self.drawn_to_hand(self)
                            ease_hands_played(-1,true)
                            if G.GAME.current_round.hands_left <= 0 then
                                G.STATE = G.STATES.GAME_OVER
                                G.STATE_COMPLETE = false
                            end
                        end
                    elseif v.id == 11 and string.len(str) > 0 then
                        G.GAME.n_algebraInput = (G.GAME.n_algebraInput and -G.GAME.n_algebraInput) or 0
                    elseif v.id == 12 then
                        G.GAME.n_algebraInput = (string.len(str) > 0 and tonumber(str:sub(1,-2))) or 0
                    end
                    v.r = math.rad(n_randrange(20))
                    v.sx = 1 + n_randrange(0.2)
                    v.sy = 1 + n_randrange(0.2)
                    play_sound('button', math.random(9,11)*0.1,1);
                end
            end
        end
    end
}

--unfinished but had an ambitious mechanic that i lost interest in making, maybe some other day?
--you can look at the files to see the assets i made for this
--[[
SMODS.Blind	{
    key = 'starlight',
    loc_txt = {
        name = 'Starlight',
        text = { 
            "This could never be a sad place!"
        }
    },
    boss = {min = 0, max = 9999, showdown = true},
    boss_colour = HEX("FF498D"),
    atlas = "funny_blinds",
    pos = {x = 0, y = 2},
    vars = {},
    dollars = 20,
    no_debuff = true,
    discovered = true,
    no_reroll = true,
    no_pause = true,
    fail_safe = true,
    descriptions = {
        "ninehund_bdesc_boss",
        "ninehund_bdesc_nopause",
        "ninehund_bdesc_noreroll",
        "ninehund_bdesc_starlight"
    },
    mult = 1,
    set_blind = function(self)
        G.GAME.nine_disableplay = true
        self.fail_safe = false
        G.GAME.abbie_speed = 1
    end,
    per_tick = function(self, t)
        if self.fail_safe then
            self.fail_safe = false
            G.GAME.nine_disableplay = false
            self.drawn_to_hand(self)
        end
    end,
    press_play = function(self)
        G.GAME.n_blindPlaying = true
    end,
    defeat = function(self)

    end,
}
]]