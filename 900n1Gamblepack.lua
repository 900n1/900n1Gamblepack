function Card:speak(text, col) --from Jen's Alamac
	if type(text) == 'table' then text = text[math.random(#text)] end
	card_eval_status_text(self, 'extra', nil, nil, nil, {message = text, colour = col or G.C.FILTER})
end

--funny talisman
to_big = to_big or function(num)
    return num
end

local PCsuits = {
    ["H"] = "Hearts",
    ["D"] = "Diamonds",
    ["C"] = "Clubs",
    ["S"] = "Spades",
}
function Card:getSuit()
    local suit_prefix = string.sub(self.base.suit, 1, 1)
    return PCsuits[suit_prefix]
end

local PCranksSpecial = {
    [11] = "Jack",
    [12] = "Queen",
    [13] = "King",
    [14] = "Ace"
}
function Card:getRank()
    local rank_suffix = math.min(self.base.id, 14)
    if rank_suffix > 10 and rank_suffix < 15 then
        return PCranksSpecial[rank_suffix]
    end
    return tostring(rank_suffix)
end

local PCranksSuff = {
    [10] = "T",
    [11] = "J",
    [12] = "Q",
    [13] = "K",
    [14] = "A"
}

function Card:getS_R()
    local suit_prefix = string.sub(self.base.suit, 1, 1)
    local rank_suffix = math.min(self.base.id, 14)
    if rank_suffix > 9 and rank_suffix < 15 then
        rank_suffix = PCranksSuff[rank_suffix]
    end
    return suit_prefix.. "_" ..rank_suffix
end

function make_card(suitrank, enhancement, hand, num, secset)
    if enhancement == nil then
        return create_playing_card({front = G.P_CARDS[suitrank]}, hand, nil, num, {secset});
    end
    return create_playing_card({front = G.P_CARDS[suitrank], center = G.P_CENTERS[enhancement]}, hand, nil, num, {secset});
end

function change_blind_size(newsize, instant) --also from Jen's Alamac, sorry
	newsize = to_big(newsize)
	G.GAME.blind.chips = newsize
	local chips_UI = G.hand_text_area.blind_chips
	if instant then
		G.GAME.blind.chip_text = number_format(newsize)
		G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
		G.HUD_blind:recalculate() 
		chips_UI:juice_up()
		play_sound('chips2')
	else
		G.E_MANAGER:add_event(Event({func = function()
			G.GAME.blind.chip_text = number_format(newsize)
			G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
			G.HUD_blind:recalculate() 
			chips_UI:juice_up()
			play_sound('chips2')
		return true end }))
	end
end

function align_layer(card, layer) --from Balatro discord, Numbuh214
    v = card.children[layer]
    if v ~= nil then
      v.states.hover = card.states.hover
      v.states.click = card.states.click
      v.states.drag = card.states.drag
      v.states.collide.can = false
      v:set_role({major = card, role_type = 'Glued', draw_major = card})
    end
end

local set_spritesref = Card.set_sprites --based from Cryptid code
function Card:set_sprites(_center, _front)
    set_spritesref(self, _center, _front)
	if _center and _center.soul_pos and _center.soul_pos.extra9 then
        self.children.center = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.pos
		)
		self.children.floating_sprite = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.soul_pos
		)
        self.children.float2 = Sprite(
			self.T.x,
			self.T.y,
			self.T.w,
			self.T.h,
			G.ASSET_ATLAS[_center.atlas or _center.set],
			_center.soul_pos.extra9
		)
		align_layer(self,"center")
        align_layer(self,"floating_sprite")
        align_layer(self,"float2")
	end
end

function removepopup()
    -- copied from G.FUNCS.overlay_menu just to remove the pop-in anim
    if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
    G.CONTROLLER.locks.frame_set = true
    G.CONTROLLER.locks.frame = true
    G.CONTROLLER.cursor_down.target = nil
    G.CONTROLLER:mod_cursor_context_layer(G.NO_MOD_CURSOR_STACK and 0 or 1)
    G.OVERLAY_MENU = UIBox{
        definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR}, nodes={
                {n=G.UIT.O, config={object = G.nine_image}},
            }},
        }},
        config = {
            align = "cm",
            offset = {x = 0, y = 0},
            major = G.ROOM_ATTACH,
            bond = 'Strong',
        }
    }
end

-- ripped from https://github.com/Mysthaps/LobotomyCorp (with permission...., hi myst lol), modified to be used as a function for image display
function display_image(pos, atlas, cframe, duration)
    G.nine_image_show = true
    G.nine_image_timer = 0
    G.nine_image_runtime = duration
    G.nine_image_anim = false
    G.nine_image_trans = 1
    G.nine_image = Sprite(0, 0, cframe.sx, cframe.sy, G.ASSET_ATLAS[atlas], pos)
    G.nine_image.states.drag.can = false
    G.nine_image.draw_self = function(self, overlay)
        if not self.states.visible then return end
        if self.sprite_pos.x ~= self.sprite_pos_copy.x or self.sprite_pos.y ~= self.sprite_pos_copy.y then
            self:set_sprite_pos(self.sprite_pos)
        end
        prep_draw(self, 1)
        love.graphics.scale(1/(self.scale.x/self.VT.w), 1/(self.scale.y/self.VT.h))
        love.graphics.setColor({1, 1, 1, G.nine_image_trans})
        love.graphics.draw(
            self.atlas.image,
            self.sprite,
            cframe.x, cframe.y,
            0,
            self.VT.w/(self.T.w),
            self.VT.h/(self.T.h)
        )
        love.graphics.pop()
        add_to_drawhash(self)
        self:draw_boundingrect()
        if self.shader_tab then love.graphics.setShader() end
    end
    removepopup()
end

function display_anim(pos, atlas, size, duration, loop)
    G.nine_image_show = true
    G.nine_image_timer = 0
    G.nine_image_runtime = duration
    G.nine_image_anim = true
    G.nine_image_trans = 1
    G.nine_image = AnimatedSprite(0, 0, size.x, size.y, G.ANIMATION_ATLAS[atlas], {0,0}, true)
    G.nine_image.offset_seconds = G.TIMERS.REAL
    G.nine_image.loop = loop
    G.nine_image.states.drag.can = false
    G.nine_image.draw_self = function(self, overlay)
        if not self.states.visible then return end
        prep_draw(self, 1)
        love.graphics.scale(1/(self.scale.x/self.VT.w), 1/(self.scale.y/self.VT.h))
        love.graphics.setColor({1, 1, 1, G.nine_image_trans})
        love.graphics.draw(
            self.atlas.image,
            self.sprite,
            pos.x, pos.y,
            0,
            self.VT.w/(self.T.w),
            self.VT.h/(self.T.h)
        )
        love.graphics.pop()
    end
    removepopup()
end

function AnimatedSprite:custom_animate(fps)
    if self.current_animation.current ~= (self.current_animation.frames - 1) or self.loop then
        local new_frame = math.floor(fps*(G.TIMERS.REAL - self.offset_seconds))%self.current_animation.frames
        if new_frame ~= self.current_animation.current then
            self.current_animation.current = new_frame
            self.frame_offset = math.floor(self.animation.w*(self.current_animation.current))
            self.sprite:setViewport( 
                self.frame_offset,
                self.animation.h*self.animation.y,
                self.animation.w,
                self.animation.h)
        end
    end
end

local game_updateref = Game.update
function Game.update(self, dt)
    if G.nine_image_show then
        if G.nine_image_anim == true then
            G.nine_image:custom_animate(20)
        end
        G.nine_image_timer = G.nine_image_timer + dt
        if G.nine_image_timer >= G.nine_image_runtime then 
            G.nine_image_trans = (G.nine_image_runtime + 1) - G.nine_image_timer
        end
        if G.nine_image_trans <= 0 then
            G.nine_image_trans = 0
            G.nine_image_show = false
            G.SETTINGS.paused = false
            if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
        end
    end

    if G.GAME.blind and G.GAME.blind.config.blind.no_debuff then 
        G.GAME.blind.disabled = nil 
    end
    if G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_asriel" and G.GAME.blind.config.blind.ending == true then
        G.ROOM.jiggle = 2
        ease_background_colour({new_colour = hsvToRgb(G.TIMERS.REAL*0.4,1,0.8,1), special_colour = hsvToRgb(G.TIMERS.REAL*0.5,1,1,1), contrast = 2})
    end
    game_updateref(self, dt)
end

local insane_hook = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(e)
    SMODS.calculate_context({but_first = true, full_hand = G.play.cards})
    insane_hook(e)
end

local peak_hook = SMODS.always_scores
function SMODS.always_scores(card)
    if card.ability["is_sandwiched"] then
        return true
    end
    peak_hook(card)
end

--from Cryptid
function Blind:cap_score(score, deco)
	if not self.disabled then
		local obj = self.config.blind
		if obj.cap_score and type(obj.cap_score) == "function" then
			return obj:cap_score(score, deco)
		end
	end
	return score
end


function force_set_blind(key) --copied from DebugPlus, however it is similar to the original Balatro code
    local par = G.blind_select_opts.boss.parent
    G.GAME.round_resets.blind_choices.Boss = key

    G.blind_select_opts.boss:remove()
    G.blind_select_opts.boss = UIBox {
        T = {par.T.x, 0, 0, 0},
        definition = {
            n = G.UIT.ROOT,
            config = {
                align = "cm",
                colour = G.C.CLEAR
            },
            nodes = {UIBox_dyn_container({create_UIBox_blind_choice('Boss')}, false,
                get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))}
        },
        config = {
            align = "bmi",
            offset = {
                x = 0,
                y = G.ROOM.T.y + 9
            },
            major = par,
            xy_bond = 'Weak'
        }
    }
    par.config.object = G.blind_select_opts.boss
    par.config.object:recalculate()
    G.blind_select_opts.boss.parent = par
    G.blind_select_opts.boss.alignment.offset.y = 0

    for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({
            type = 'new_blind_choice'
        }) then
            break
        end
    end
end

local ease_background_colour_blindref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override)
    if G.GAME.blind then
        if G.GAME.blind.config.blind.key == "bl_ninehund_asriel" then
            ease_background_colour({new_colour = HEX("000000"), special_colour = HEX("FFFFFF"), contrast = 2})
            return
        end
    end
    ease_background_colour_blindref(state, blind_override)
end

function hsvToRgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    local color = {r, g, b, a}
    return color
end

function refresh_deck()
    G.FUNCS.draw_from_discard_to_deck()
    G.FUNCS.draw_from_hand_to_deck()
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 1,
        blockable = false,
        func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.deck:shuffle(G.GAME.blind.config.blind.key..'_refresh')
                    G.deck:hard_set_T()
                return true
                end
            }))
        return true
        end
    }))
end

G.localization.descriptions.Other['health'] = {
    text = {
        "{X:mult,C:white}Health:{C:mult} #1#/#2#"
    }
}

local gen_card_old = generate_card_ui --code taken from https://github.com/art-muncher/Card-Value-Display
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end,card)
    full_UI_table = gen_card_old(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end,card)
    if card and card.ability then
        local desc_nodes = full_UI_table.main
        if card.ability.health ~= nil and card.ability.max_health ~= nil then
            localize{type = 'other', key = 'health', nodes = desc_nodes, vars = {card.ability.health,card.ability.max_health}}
        end
    end
    return full_UI_table
end

function Card:damage_card(dmg)
    if self.ability.health ~= nil and self.ability.max_health ~= nil then
        if dmg ~= 0 then
            if dmg > 0 then
                SMODS.calculate_context({card_damaged = self});
            end
            self:juice_up(-1,-1);
            if self.config.center_key == 'm_glass' then
                self.ability.health = self.ability.health - (dmg*3);
                if self.ability.health <= 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            self:shatter();
                            return true
                        end
                    })) 
                end
                SMODS.calculate_effect({ message = "-" ..(dmg*3).." !", colour = G.C.MULT, instant = true}, self)
            else
                self.ability.health = self.ability.health - dmg;
                if self.ability.health <= 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            self:start_dissolve(nil, true);
                            return true
                        end
                    })) 
                end
                SMODS.calculate_effect({ message = "-" ..dmg, colour = G.C.MULT, instant = true}, self)
            end
        end
    else
        self.ability.max_health = self.base.nominal;
        self.ability.health = self.ability.max_health;
        self:damage_card(dmg);
    end
end

function generate_ui_cardarea_thing(cards) --ripped from UI_definitions
    local cardarea = CardArea(
        2,2,
        3.5*G.CARD_W, --xpadding
        0.75*G.CARD_H, --ypadding
        {card_limit = 0, type = 'play', highlight_limit = 0})
      for k, v in ipairs(cards) do
          local card = Card(0,0, 0.75*G.CARD_W, 0.75*G.CARD_H, G.P_CARDS[v[1]], G.P_CENTERS.c_base)
          cardarea:emplace(card)
      end
    
      return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
          {n=G.UIT.O, config={object = cardarea}}
        }}
      }}
end

function generate_sandiwch_cards(Scards)
    local cardarea = CardArea(
        2,2,
        math.min(3.5*G.CARD_W,G.CARD_W*#Scards), --xpadding
        0.75*G.CARD_H, --ypadding
        {card_limit = 0, type = 'play', highlight_limit = 0})

    if #Scards > 0 then
        for x=1, #Scards do
            local funnycard = make_card(Scards[x][1],nil, cardarea, nil, G.C.SECONDARY_SET.Spectral)
            ease_value(funnycard.T, 'scale',-0.2,nil,'REAL',true,0.1)
            for a, m in pairs(Scards[x][2]) do
                if m then
                    funnycard:set_ability(G.P_CENTERS[tostring(a)]);
                end
            end
            if Scards[x][3] ~= nil and Scards[x][3]["key"] ~= nil then
                funnycard:set_edition(Scards[x][3]["key"],true,true);
            end
            if Scards[x][4] ~= nil then
                funnycard:set_seal(Scards[x][4],true,true);
            end
        end
    end
    
      return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
          {n=G.UIT.O, config={object = cardarea}}
        }}
      }}
end

--===========RESOURCES============

-- from Cryptid, for drawing the third layer in cards, modified to liking and hopefully not clash with cryptid's own third layer
SMODS.DrawStep({
	key = "float2",
	order = 59,
	func = function(self)
		if
			self.config.center.soul_pos
			and self.config.center.soul_pos.extra9
			and (self.config.center.discovered or self.bypass_discovery_center)
		then
			local scale_mod = 0.07
			local rotate_mod = 0.02*math.cos(1.219*G.TIMERS.REAL) + 0.00*math.cos((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2
			self.children.float2:draw_shader(
				"dissolve",
				0,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod,
				nil,
				0.1 + 0.03*math.cos(1.8*G.TIMERS.REAL),
				nil,
				0.6
			)
			self.children.float2:draw_shader(
				"dissolve",
				nil,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod
			)
		end
	end,
	conditions = { vortex = false, facing = "front" },
})
SMODS.draw_ignore_keys.float2 = true

SMODS.Atlas{
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = 'amalgam',
    path = 'amalgam.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'crk',
    path = 'crk.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'supernatural',
    path = 'supernatural.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'custom',
    path = 'creative.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'enhance',
    path = 'enhance.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'vouchers',
    path = 'vouchers.png', 
    px = 71, 
    py = 95 
}
SMODS.Atlas{
    key = 'whitescreen',
    path = 'white.png', 
    px = 1280, 
    py = 720
}
SMODS.Atlas{
    key = 'jesus',
    path = 'hispower.png', 
    px = 640, 
    py = 360
}

SMODS.Sound({
	key = 'rah',
	path = 'rah.ogg',
})

SMODS.Sound({
	key = 'boom',
	path = 'boom.ogg',
})

SMODS.Sound({
	key = 'asriel_light',
	path = 'mus_sfx_a_lithit2.ogg',
})

SMODS.Sound({
	key = 'asriel_swipe',
	path = 'mus_sfx_swipe.ogg',
})

SMODS.Sound({
	key = 'asriel_star',
	path = 'mus_sfx_star.ogg',
})

SMODS.Sound({
	key = 'asriel_hit',
	path = 'snd_bomb.ogg',
})

SMODS.Sound({
	key = 'und_explode',
	path = 'mus_explosion.ogg',
})

SMODS.Sound({
	key = 'und_flash',
	path = 'mus_sfx_eyeflash.ogg',
})

SMODS.Sound({
	key = 'asriel_goner',
	path = 'mus_sfx_hypergoner_laugh.ogg',
})

SMODS.Sound({
	key = 'bell',
	path = 'bell.ogg',
})


SMODS.Sound({
	key = 'music_hopes_and_dreams',
	path = 'hopes_and_dreams.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_asriel") and 1e6 or false
    end,
})

SMODS.Sound({
	key = 'music_save_the_world',
	path = 'save_the_world.ogg',
    pitch = 1,
    sync = false,
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_ninehund_asriel" and G.GAME.blind.config.blind.ending == true) and 1e9 or false
    end,
})

SMODS.Atlas({ 
    key = "asriel", 
    atlas_table = "ANIMATION_ATLAS", 
    path = "asrielBlind.png", 
    px = 34, py = 34, 
    frames = 21 
})

SMODS.Atlas({ 
    key = "att_light", 
    atlas_table = "ANIMATION_ATLAS", 
    path = "att_light.png", 
    px = 296, py = 203, 
    frames = 17
})

SMODS.Atlas({ 
    key = "att_slash", 
    atlas_table = "ANIMATION_ATLAS", 
    path = "asrielslash.png", 
    px = 123, py = 161, 
    frames = 9
})

SMODS.Atlas({ 
    key = "att_star", 
    atlas_table = "ANIMATION_ATLAS", 
    path = "starboom.png", 
    px = 292, py = 292, 
    frames = 5
})

SMODS.Atlas({ 
    key = "att_goner", 
    atlas_table = "ANIMATION_ATLAS", 
    path = "hypergoner.png", 
    px = 640, py = 360, 
    frames = 8
})

SMODS.Rarity {
	key = 'fusion',
	loc_txt = {
		name = 'Fusion'
	},
	badge_colour = HEX('63BBE1'),
    default_weight = 0.5,
}

SMODS.Rarity {
	key = 'icon',
	loc_txt = {
		name = 'Icon Series'
	},
	badge_colour = HEX('dcdcdc'),
    default_weight = 0.01,
}

SMODS.Rarity {
	key = 'super',
	loc_txt = {
		name = 'Supernatural'
	},
	badge_colour = HEX('d10020'),
    default_weight = 0,
}


SMODS.ConsumableType{
    key = 'amalgams',

    collection_rows = {4,5},
    primary_colour = HEX('7D3951'),
    secondary_colour = G.C.DARK_EDITION,
    loc_txt = {
        collection = 'Amalgamate Cards', 
        name = 'Amalgam',
        undiscovered = {
            name = 'Hidden Amalgam',
            text = {'Amalgam not synthesized'} 
        }
    },
    shop_rate = 0.1, --rate in shop out of 100
}

--====================JOKERS======================

SMODS.Joker{
    key = 'eye_rah',
    loc_txt = {
        name = 'Joker of Rah',
        text = {
          'When only one card is played,',
          'if that card is not {C:attention}Stone{},',
          'turn that card into {C:attention}Stone{}',
          'and create {C:attention}#1# Tarot{} cards',
          '{C:inactive}(Must have room)',
        },
    },
    atlas = 'Jokers', 
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    config = { 
      extra = {
        tarotCount = 2
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {vars = {center.ability.extra.tarotCount}}
    end,
    calculate = function(self,card,context)
        if context.joker_main and #G.play.cards == 1 then
            if  G.play.cards[1].config.center_key ~= 'm_stone'  then
                local amoun = card.ability.extra.tarotCount
                if #G.consumeables.cards + amoun > G.consumeables.config.card_limit then
                    amoun = G.consumeables.config.card_limit - #G.consumeables.cards
                end
                G.play.cards[1]:flip()
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 1,
                    func = function()
                        G.play.cards[1]:flip()
                        card:juice_up(1, 1)
                        G.play.cards[1]:set_ability(G.P_CENTERS.m_stone)
                        SMODS.calculate_effect({ message = "chill the fuck up yo", colour = G.C.MULT, instant = true}, card)
                        play_sound('ninehund_rah')
                        if amoun > 0 then
                            for i=1, amoun do
                                local _card = create_card('Tarot', G.consumeables)
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                            end
                        end
                        return true
                    end
                }))
            else
                SMODS.calculate_effect({ message = "yall trippin", colour = G.C.PURPLE, instant = true}, card)
            end
        end
    end,
}

local burnspiceYap =  {
    "I'm bored, BORED!",
    "Witness DESTRUCTION!!",
    "This will be entertaining!",
    "In the end, everything becomes dust.",
    "Oh please, this is child's play! I want MORE!",
    "What am I even doing here in the first place?!"
}

local burnspiceDissapoint = {
    "Seriously?!",
    "BOOORING!",
    "WHAT?! NO MORE??",
    "*sigh*",
    "Give me more!"
}

SMODS.Joker{
    key = 'crk_burnspice',
    loc_txt = {
        name = 'Burning Spice Cookie',
        text = {
          'Deals {C:mult}#4# damage{} {C:attention}#5#{} times',
          'to cards in your hand randomly, and',
          'gains {X:mult,C:white}x#2#{} per card {C:mult}damaged',
          '{C:mult,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}x#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0, extra9 = {x = 2, y = 0}},
    config = { 
      extra = {
        xmult = 1,
        gain = 0.35,
        dmg = 5,
        amount = 3
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.xmult,center.ability.extra.gain, burnspiceYap[math.random(#burnspiceYap)],center.ability.extra.dmg,center.ability.extra.amount}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    calculate = function(self,card,context)
        if context.pre_joker then
            local didathing = false
            for i=1,card.ability.extra.amount do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        if #G.hand.cards >= 1 then
                            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain;
                            local _chosen = pseudorandom_element(G.hand.cards,pseudoseed('crk'))
                            _chosen:damage_card(card.ability.extra.dmg);
                            didathing = true
                            SMODS.calculate_effect({ message = "+x" ..card.ability.extra.gain.." Mult", colour = G.C.MULT, instant = true}, card)
                        end
                        return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 1,
                func = function()
                    if not didathing then
                        SMODS.calculate_effect({ message = burnspiceDissapoint[math.random(#burnspiceDissapoint)], colour = G.C.MULT, instant = true}, card)
                    end
                    return true
                end
            }))
        end
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.xmult,
                message = 'X' .. card.ability.extra.xmult,
                colour = G.C.MULT
            }
        end
    end,
}

local shadowmilkYap = {
    'Oh, this is going to be FUN!',
    "Ever told a lie? Then we're pals!",
    'The game is just beginning!',
    'Let the show BEGIN!',
    "Even I can't tell where I am right now!",
    'Oh no, you got tricked? Well, TOO BAD!',
    "Aw, don't be a drag! C'mon, have some fun!"
}

SMODS.Joker{
    key = 'crk_shadowmilk',
    loc_txt = {
        name = 'Shadow Milk Cookie',
        text = {
          'Playing cards are {C:white,X:chips}Concealed{}',
          'gains {X:mult,C:white}x#2#{} per card deceived.',
          '{C:chips}[After playing, Concealed cards reveal themselves]{}',
          '{C:chips,s:1.2,E:1}#3#{}',
          '{X:mult,C:white,s:2}x#1#{s:2,C:mult} Mult{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 1},
    soul_pos = {x = 1, y = 1, extra9 = {x = 2, y = 1}},
    config = { 
      extra = {
        xmult = 1,
        gain = 0.1
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_SEALS.ninehund_truth
        return {vars = {center.ability.extra.xmult,center.ability.extra.gain, shadowmilkYap[math.random(#shadowmilkYap)]}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    add_to_deck = function(self, card, from_debuff)
		if not from_debuff then
            local prevXMult = card.ability.extra.xmult
            card.ability.extra.xmult = card.ability.extra.xmult + (card.ability.extra.gain*#G.playing_cards)
            card:juice_up(1, 1)
            card:speak("+x"..(card.ability.extra.xmult-prevXMult).." Mult",G.C.MULT)
            for k, v in pairs(G.playing_cards) do
                v.ability["truth1"] = v:getSuit()
                v.ability["truth2"] = v:getRank()
                SMODS.change_base(v,pseudorandom_element({'Hearts','Diamonds','Clubs','Spades'}, pseudoseed('lies')),pseudorandom_element({'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}, pseudoseed('lies')))
                v:set_seal("ninehund_truth",true)
            end
        end
	end,
    calculate = function(self,card,context)
        if context.post_joker then
            card.ability.extra.xmult = card.ability.extra.xmult + (card.ability.extra.gain*#context.full_hand)
            for k, v in pairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 1,
                    func = function()
                        v.ability["truth1"] = v:getSuit()
                        v.ability["truth2"] = v:getRank()
                        SMODS.change_base(v,pseudorandom_element({'Hearts','Diamonds','Clubs','Spades'}, pseudoseed('lies')),pseudorandom_element({'2','3','4','5','6','7','8','9','10','Jack','Queen','King','Ace'}, pseudoseed('lies')))
                        v:set_seal("ninehund_truth",true)
                        v:juice_up()
                        play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                        SMODS.calculate_effect({ message = "+x"..card.ability.extra.gain.." Mult", colour = G.C.MULT, instant = true}, card)
                        return true
                    end
                })) 
            end
        end
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.xmult,
                message = 'X' .. card.ability.extra.xmult,
                colour = G.C.MULT
            }
        end
    end,
}

local mysticflourYap = {
    "Nothing shall last.",
    "Win or lose, it matters not.",
    "Is this truly what you want?",
    "It is all meaningless.",
    "...",
    "I await your moment of awakening.",
    "Empty your heart.",
    "For even greed shall pass...",
    "Wake up, and you shall see the truth.",
    "This place, will eventually decay as well."
}

SMODS.Joker{
    key = 'crk_mysticflour',
    loc_txt = {
        name = 'Mystic Flour Cookie',
        text = {
          'Cards played are {C:white,X:inactive}Wiped.{}',
          'Gains {X:chips,C:white}x#2#{} per card',
          'returned to their origin.',
          '{C:chips}Chips{} are then {C:attention}added to{} {C:mult}Mult{}',
          '{C:inactive,s:1.2,E:1}#3#{}',
          '{X:chips,C:white,s:2}x#1#{s:2,C:chips} Chips{}',
        },
    },
    atlas = 'crk', 
    rarity = "ninehund_icon",
    cost = 4,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 2},
    soul_pos = {x = 1, y = 2, extra9 = {x = 2, y = 2}},
    config = { 
      extra = {
        xchip = 1,
        gain = 0.1
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_blankcard
        return {vars = {center.ability.extra.xchip,center.ability.extra.gain, mysticflourYap[math.random(#mysticflourYap)]}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Beast', HEX('66041E'), G.C.WHITE, 1)
        badges[#badges+1] = create_badge('Cookie Run: Kingdom', G.C.GREY, G.C.WHITE, 0.8)
    end,
    calculate = function(self,card,context)
        if context.pre_joker then
            local prevXchip = card.ability.extra.xchip
            card.ability.extra.xchip = card.ability.extra.xchip + (card.ability.extra.gain*#context.full_hand)
            for k, v in pairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.6,
                    func = function()
                        v:juice_up()
                        if v.config.center_key ~= "m_ninehund_blankcard" then
                            v:set_ability(G.P_CENTERS.m_ninehund_blankcard)
                            v:set_edition(nil)
                            v:set_seal(nil)
                            play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                            SMODS.calculate_effect({ message = "+x"..card.ability.extra.gain.." Chips", colour = G.C.CHIPS, instant = true}, card)
                        end
                        return true
                    end
                })) 
            end
        end
        if context.joker_main then
            hand_chips = mod_chips(hand_chips*card.ability.extra.xchip)
            return {
                chips = 0,
                mult = hand_chips,
                chip_message = {message = "X"..card.ability.extra.xchip.." Chips", colour = G.C.CHIPS},
                mult_message = {message = "+Chips Mult", colour = G.C.MULT}
            }
        end
    end,
}

SMODS.Joker{
    key = 'rockbanana',
    loc_txt = {
        name = 'Rocher Michel',
        text = {
          '{C:mult}+#2#{} Mult per {C:attention}Stone Card{}',
          'in your {C:attention}full deck{}.',
          '{C:green}#3# in #1#{} chance this is',
          'destroyed at the end of the round',
          '{C:inactive}Heh, you know what else is rock hard?',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 7,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 0, y = 0},
    config = { 
      extra = {
        mult = 0,
        chance = 6,
        percard = 50
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        return {vars = {center.ability.extra.chance,center.ability.extra.percard,"" .. (G.GAME and G.GAME.probabilities.normal or 1)}}
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            card.ability.extra.mult = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_stone then card.ability.extra.mult = card.ability.extra.mult+card.ability.extra.percard end
            end
            return {
                card = card,
                mult_mod = card.ability.extra.mult,
                message = '+' .. card.ability.extra.mult,
                colour = G.C.MULT
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition and not context.retrigger_joker then
            if pseudorandom(pseudoseed('banana')) < G.GAME.probabilities.normal / card.ability.extra.chance then
                card:speak("Extinct!")
                G.E_MANAGER:add_event(Event({
					func = function()
                        card:start_dissolve()
                	    return true
					end
				}))
            else
                card:speak("Safe!",G.C.CHANCE)
            end
        end
    end,
}

SMODS.Joker{
    key = 'pridejoker',
    loc_txt = {
        name = 'Prideful Joker',
        text = {
          'Played cards with',
          '{C:attention}any of the four suits{}',
          'give {C:mult}+#1#{} Mult when scored',
          '{C:inactive}Really now?',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 10,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 2, y = 0},
    config = { 
      extra = {
        mult = 12,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.mult}}
    end,
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds') or context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades') then
                return {
                    card = card,
                    mult = card.ability.extra.mult,
                }
            end
        end
    end,
}

SMODS.Joker{
    key = 'whitediamondjoker',
    loc_txt = {
        name = 'White Diamond Joker',
        text = {
          'Scored cards with {C:attention}any of the four suits{} give:',
          '{C:money}$#1#{}',
          '{C:chips}+#3#{} Chips',
          '{C:mult}+#4#{} Mult',
          '{C:green}#6# in #2# chance{} for {X:mult,C:white}x#5#{} Mult',
          '{C:inactive}Perfection.',
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 21,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 3, y = 0},
    config = { 
      extra = {
        money = 1,
        chance = 2,
        chips = 50,
        mult = 7,
        Xmult = 1.5,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.money,center.ability.extra.chance,center.ability.extra.chips,center.ability.extra.mult,center.ability.extra.Xmult,G.GAME.probabilities.normal}}
    end,
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds') or context.other_card:is_suit('Clubs') or context.other_card:is_suit('Spades') then
                if pseudorandom(pseudoseed('wild')) < G.GAME.probabilities.normal / card.ability.extra.chance then
                    return {
                        card = card,
                        dollars = card.ability.extra.money,
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                        x_mult = card.ability.extra.Xmult,
                    }
                else
                    return {
                        card = card,
                        dollars = card.ability.extra.money,
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                    }
                end
            end
        end
    end,
}

SMODS.Joker{
    key = 'hitlistjoker',
    loc_txt = {
        name = 'Hitlist Joker',
        text = {
          'Reduce the {C:attention}blind requirement{} by {C:attention}#2#%{}',
          'if {C:attention}poker hand{} is a {C:attention}#1#{}',
          "{C:inactive}(Hand changes after use",
          "{C:inactive}and start of a Blind)",
          "{C:inactive,s:0.8}Hating on Boss Blinds became",
          "{C:inactive,s:0.8}a part of my lifestyle.",
        },
    },
    atlas = 'amalgam', 
    rarity = 'ninehund_fusion',
    cost = 7,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = true, 
    pos = {x = 4, y = 0},
    config = { 
      extra = {
        type = "High Card",
        percent = 10,
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.type,center.ability.extra.percent}}
    end,
    set_ability = function(self, card, initial, delay_sprites)
		local _poker_hands = {}
        	for k, v in pairs(G.GAME.hands) do
            		if v.visible then _poker_hands[#_poker_hands+1] = k end
	        end
		card.ability.extra.type = pseudorandom_element(_poker_hands, pseudoseed('pokerhand'))
	end,
    calculate = function(self,card,context)
        if (context.cardarea == G.jokers and context.before) or context.setting_blind  then
			if context.scoring_name == card.ability.extra.type then
                card:speak('-'..card.ability.extra.percent..'% Blind Size',G.C.FILTER)
				change_blind_size(to_big(G.GAME.blind.chips) - (to_big(G.GAME.blind.chips)*to_big(card.ability.extra.percent*0.01)))
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                        if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                card.ability.extra.type = pseudorandom_element(_poker_hands, pseudoseed('pokerhand'))
            end
        end
    end,
}

SMODS.Joker{
    key = 'bible',
    loc_txt = {
        name = 'The Holy Bible',
        text = {
          '{C:attention}Cleanses and enlightens you.{}'
        },
    },
    atlas = 'Jokers', 
    rarity = 2,
    cost = 0,
    unlocked = true,
    discovered = true, 
    blueprint_compat = false, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 4, y = 0},
    add_to_deck = function(self, card, from_debuff)
        display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
        play_sound('ninehund_und_flash', 1,0.5);
        for _, j in pairs(G.jokers.cards) do
            j:start_dissolve(nil,true);
        end
        for _, c in pairs(G.consumeables.cards) do
            c:start_dissolve(nil,true);
        end
        ease_hands_played(2- G.GAME.current_round.hands_left,true);
        ease_discard(0 - G.GAME.current_round.discards_left,true);
        ease_dollars(-G.GAME.dollars-77, true)
        G.GAME.round_resets.hands = 2
        G.GAME.round_resets.discards = 0
        card:set_eternal(true);
        G.GAME.nine_biblekillcount = 1;
    end,
    calculate = function(self,card,context)
        if context.questionably_drew and not context.blueprint then
            G.GAME.nine_disableplay = true;
            for i, k in ipairs(G.hand.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 2/(G.GAME.nine_biblekillcount+(i*0.3)),
                    timer = "REAL",
                    blocking = true,
                    func = function()
                        G.GAME.nine_biblekillcount = G.GAME.nine_biblekillcount + 0.3;
                        card:juice_up(G.GAME.nine_biblekillcount-1, G.GAME.nine_biblekillcount-1);
                        G.GAME.nine_musicspeed = 1+((G.GAME.nine_biblekillcount+(i*0.3))*0.2);
                        display_image({x=math.random(0,6),y=0}, "ninehund_jesus", {x = 0, y = 0, sx = 23.2, sy = 13.05}, 0)
                        play_sound('ninehund_bell',1,0.5);
                        k:start_dissolve(nil, true);
                        return true
                    end
                })) 
            end
        end
    end,
}

SMODS.Joker{
    key = 'asrieljoker',
    loc_txt = {
        name = 'Core of Desire',
        text = {
          'When a card is {C:mult}damaged{}:',
          'Increase the {X:mult,C:white}Health{} and {X:mult,C:white}MaxHealth{}',
          'of the card by {X:green,C:white}#1#{}.',
          'Gain {X:purple,C:white}^#3#{}.',
          '{X:purple,C:white,s:2}^#2#{C:purple,s:2} Mult',
          "{C:inactive,s:0.8}Half of the world's prayers.",
        },
    },
    atlas = 'supernatural', 
    rarity = 'ninehund_super',
    cost = 99,
    unlocked = true,
    discovered = true, 
    blueprint_compat = true, 
    eternal_compat = true,
    perishable_compat = false, 
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0, extra9 = {x = 2, y = 0}},
    config = { 
        extra = {
        e_mult = 1.01,
        heal = 1,
        gain = 0.01
      }
    },
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.heal,center.ability.extra.e_mult,center.ability.extra.gain}}
    end,
    set_badges = function(self, card, badges)
        badges[#badges+1] = create_badge('Singular', HEX('525A65'), G.C.WHITE, 1)
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true);
        local find = find_joker('j_ninehund_asrieljoker');
        if #find > 0 then
            find[1].ability.extra.heal = find[1].ability.extra.heal + 1;
            find[1].ability.extra.gain = find[1].ability.extra.gain + 0.01;
            SMODS.calculate_effect({ message = "Upgrade!", colour = G.C.PURPLE, instant = false}, find[1])
            card:start_dissolve(nil, true);
        end
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                emult = card.ability.extra.e_mult,
            }
        end
        if context.card_damaged then
            context.card_damaged.ability.health = context.card_damaged.ability.health + card.ability.extra.heal;
            context.card_damaged.ability.max_health = context.card_damaged.ability.max_health + card.ability.extra.heal;
            card.ability.extra.e_mult = card.ability.extra.e_mult + card.ability.extra.gain;
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    SMODS.calculate_effect({ message = "+" ..card.ability.extra.heal, colour = G.C.GREEN, instant = true}, context.card_damaged)
                    SMODS.calculate_effect({ message = "+^" ..card.ability.extra.gain, colour = G.C.PURPLE, instant = true}, card)
                    return true
                end
            }))
        end
    end,
}


--====================CONSUMABLES======================

SMODS.Consumable{
    key = 'deaikh',
    set = 'amalgams',
    loc_txt = {
        name = 'Deaikh',
        text = {
          'Convert the {C:attention}leftmost{} Joker into the {C:attention}rightmost{} Joker',
          '{C:inactive}(Weird how this works right?)',
        },
    },
    atlas = 'amalgam', 
    cost = 4,
    unlocked = true,
    discovered = true, 
    pos = {x = 1, y = 0},
    config = {},
    can_use = function(self,card)
        if G and G.jokers then
            if G.jokers.cards[1] ~= nil and G.jokers.cards[#G.jokers.cards] ~= nil and #G.jokers.cards >= 2 then
                return true
            end
        end
        return false
    end,
    use = function(self,card,area,copier)
        G.jokers.cards[1]:start_dissolve(nil, true)
        local _card = copy_card(G.jokers.cards[#G.jokers.cards])
        _card:add_to_deck()
        _card:start_materialize()
        G.jokers:emplace(_card)
    end,
}

SMODS.Consumable{
    key = 'emprehant',
    set = 'amalgams',
    loc_txt = {
        name = 'Emprehant',
        text = {
          'Enhances {C:attention}#1#{} selected',
          'cards into {C:attention}Extra Bonus Cards{}',
        },
    },
    atlas = 'amalgam', 
    cost = 4,
    unlocked = true,
    discovered = true, 
    pos = {x = 3, y = 1},
    config = { extra = { count = 2 } },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_multchip
        return {vars = {center.ability.extra.count}}
    end,
    can_use = function(self,card)
        return (#G.hand.highlighted <= card.ability.extra.count and #G.hand.highlighted > 0)
    end,
    use = function(self,card,area,copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                play_sound('tarot1', 1,1)
                card:juice_up()
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do --flips cards
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip();
                    play_sound('card1', percent);
                    G.hand.highlighted[i]:juice_up(0.3, 0.3);
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do --unflips cards
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                     G.hand.highlighted[i]:flip();
                     G.hand.highlighted[i]:set_ability(G.P_CENTERS.m_ninehund_multchip);
                     play_sound('tarot2', percent, 0.6);
                     G.hand.highlighted[i]:juice_up(0.3, 0.3);
                     return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all();
            return true
        end })) --unselects cards
        delay(0.5)
    end,
}

SMODS.Consumable{
    key = 'fuckingnuke',
    set = 'Tarot',
    loc_txt = {
        name = 'Loss',
        text = {
          'Go on, {E:1}take a guess on what it does.{}',
          '{C:green}#1# in 10 chance.'
        },
    },
    atlas = 'custom', 
    cost = 2,
    unlocked = true,
    discovered = true, 
    pos = {x = 1, y = 0},
    config = {},
    loc_vars = function(self,info_queue,center)
        return {vars = {G.GAME.probabilities.normal}}
    end,
    can_use = function(self,card)
        return (#G.hand.cards >= 1)
    end,
    use = function(self,card,area,copier)
        for o = 1, 60 do
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 1/o,
                func = function()
                    card:juice_up(o/100,o/100)
                    play_sound('tarot1', 1.2 * (o/20),1)
                    return true
                end
            })) 
        end
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                play_sound('ninehund_boom',0.5)
                G.ROOM.jiggle = 100
                for k = 1, #G.hand.cards do
                    if pseudorandom(pseudoseed('wild')) < G.GAME.probabilities.normal / 10 then
                        G.hand.cards[k]:set_edition("e_negative",true);
                    else
                        G.hand.cards[k]:start_dissolve(nil, true);
                    end
                end
                return true
            end
        })) 
    end,
}

SMODS.Consumable{
    key = 'construct',
    set = 'Spectral',
    loc_txt = {
        name = 'Construct',
        text = {
          'Combines {C:attention}#1#{} selected',
          'cards into a {C:attention}Sandwich{}',
        },
    },
    atlas = 'custom', 
    cost = 8,
    unlocked = true,
    discovered = true, 
    pos = {x = 0, y = 0},
    config = { extra = { count = 5 } },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ninehund_sandwichcard
        return {vars = {center.ability.extra.count}}
    end,
    can_use = function(self,card)
        return (#G.hand.highlighted <= card.ability.extra.count and #G.hand.highlighted > 1)
    end,
    use = function(self,card,area,copier)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                play_sound('tarot1', 1,1)
                card:juice_up()
                return true
            end
        }))
        local _cardsets = {};
        for i = 1, #G.hand.highlighted do --flips cards
            _cardsets[i] = {
                G.hand.highlighted[i]:getS_R(),
                SMODS.get_enhancements(G.hand.highlighted[i]),
                G.hand.highlighted[i].edition,
                G.hand.highlighted[i].seal
            };
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip();
                    play_sound('card1', percent);
                    return true
                end
            }))
        end
        delay(0.2)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.2,
            func = function()
                for i = 1, #G.hand.highlighted do
                    G.hand.highlighted[i]:start_dissolve(nil, true);
                end
            return true
        end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local _sandwich = make_card("H_2", "m_ninehund_sandwichcard", G.hand, nil, G.C.SECONDARY_SET.Spectral)
                _sandwich.ability["Scards"] = _cardsets;
            return true
        end }))
        delay(0.5)
        if G.GAME.used_vouchers['v_ninehund_sandwichfunc'] == nil then
            local lacard = Card(area.T.x + area.T.w/2 - G.CARD_W/2, area.T.y + area.T.h/2-G.CARD_H/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS["v_ninehund_sandwichfunc"],{bypass_discovery_center = true, bypass_discovery_ui = true})
            lacard.cost=0
            lacard.shop_voucher=false
            lacard:redeem()
            G.E_MANAGER:add_event(Event({
                delay = 0,
                func = function() 
                    lacard:start_dissolve()
                return true
            end}))
        end
    end,
}

SMODS.Consumable{
    key = 'undertaleref',
    set = 'Tarot',
    loc_txt = {
        name = 'Barrier',
        text = {
          'Randomly summons a',
          '{E:1,C:attention} Special Boss Blind'
        },
    },
    atlas = 'custom', 
    cost = 2,
    unlocked = true,
    discovered = true, 
    pos = {x = 2, y = 0},
    config = {},
    can_use = function(self,card)
        return not G.GAME.blind.in_blind
    end,
    use = function(self,card,area,copier)
        for o = 1, 20 do
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 1/o,
                func = function()
                    card:juice_up(o/100,o/100)
                    play_sound('tarot1', 1.2 * (o/20),1)
                    return true
                end
            })) 
        end
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
                play_sound('ninehund_boom',0.8)
                force_set_blind('bl_ninehund_asriel');
                return true
            end
        })) 
    end,
}

--====================ENHANCEMENTS======================

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
            'Unpacks held playing cards into playing',
            'hand when played',
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

--================VOUCHERS==================

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

--====================BLINDS========================

local asriel_attacks = {
    function()
        display_anim({x=40,y=-40}, "ninehund_att_light", {x=13,y=9}, 0.5)
        for i=1, #G.hand.cards do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                    return true
                    end
                }))
            end
        end
    end,
    function()
        display_anim({x=0,y=-40}, "ninehund_att_light", {x=-13,y=9}, 0.5)
        for i=#G.hand.cards, 1, -1 do
            if i % 2 == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        G.hand.cards[i]:damage_card(2);
                        G.ROOM.jiggle = 2
                        play_sound('ninehund_asriel_light', math.random(9,12)*0.1,0.2);
                    return true
                    end
                }))
            end
        end
    end,
    function()
        display_anim({x=20,y=0}, "ninehund_att_slash", {x=-8,y=12}, 0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
                for i=1, math.floor(#G.hand.cards/2) do
                    G.hand.cards[i]:damage_card(2);
                    G.ROOM.jiggle = 2
                end
                return true
            end
        }))
    end,
    function()
        display_anim({x=50,y=0}, "ninehund_att_slash", {x=8,y=12}, 0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.4,
            func = function()
                play_sound('ninehund_asriel_swipe', math.random(9,11)*0.1,0.5);
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
        display_anim({x=math.random(-100,100),y=0}, "ninehund_att_star", {x=8,y=8}, 0.1)
        G.ROOM.jiggle = 4
        for i=1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    play_sound('ninehund_asriel_hit', math.random(9,11)*0.1,0.5);
                    pseudorandom_element(G.hand.cards, pseudoseed('attack')):damage_card(2);
                    return true
                end
            }))
        end
    end,
}

SMODS.Blind	{
    key = 'asriel',
    loc_txt = {
        name = 'God of Hyperdeath',
        text = { 
            "It's the end, isn't it?"
        }
    },
    boss = {min = 8, max = 64, showdown = true},
    boss_colour = HEX("273133"),
    atlas = "asriel",
    pos = {x = 0, y = 0},
    vars = {},
    dollars = 20,
    no_debuff = true,
    mult = 2,
    remaining_hits = 6,
    set_blind = function(self)
        self.remaining_hits = 6
        self.starting = true
        self.ending = false
        self.finalatt = false
        local find = find_joker('j_ninehund_asrieljoker');
        if #find > 0 then
            for _, f in pairs(find) do
                SMODS.debuff_card(f,true,"asriel")
            end
        end
    end,
    drawn_to_hand = function(self)
        if self.starting then
            self.starting = false;
        elseif self.finalatt then
            self.finalatt = false;
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    play_sound('ninehund_asriel_goner', 1,0.5);
                    display_anim({x=0,y=0}, "ninehund_att_goner", {x=32,y=18}, 3, true)
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
                    display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
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
        local find = find_joker('j_ninehund_asrieljoker',true);
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
            if score >= G.GAME.blind.chips and self.remaining_hits > 1 then
                self.remaining_hits = self.remaining_hits - 1
                G.GAME.blind:juice_up(2,2)
                ease_hands_played(math.max(0, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands) - G.GAME.current_round.hands_left,true);
                ease_discard(math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards) - G.GAME.current_round.discards_left,true);
                ease_chips(0);
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if self.remaining_hits <= 1 then
                            self.ending = true
                            self.finalatt = true
                        end
                        play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                        display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 0)
                        return true
                    end
                })) 
                for o = 1, 20 do
                    G.E_MANAGER:add_event(Event({
                        trigger = "before",
                        delay = o*0.01,
                        func = function()
                            ease_background_colour({new_colour = hsvToRgb(((o/3)+(self.remaining_hits*3))/20,1,(20/o)/20,1), special_colour = hsvToRgb(((o/3)+(self.remaining_hits*6))/20,1,1,1), contrast = 2})
                            G.ROOM.jiggle = 20/o
                            return true
                        end
                    })) 
                end
                play_area_status_text(self.remaining_hits.." out of 6 left.", false, 2);
                refresh_deck();
            elseif self.remaining_hits <= 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.1,
                    blockable = true,
                    func = function()
                        if (to_big(G.GAME.chips) + to_big(score)) >= to_big(G.GAME.blind.chips) then
                            display_image({x=0,y=0}, "ninehund_whitescreen", {x = 0, y = 0, sx = 32, sy = 18}, 1)
                            play_sound('ninehund_und_explode', math.random(9,11)*0.1,0.5);
                            self.ending = false;
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