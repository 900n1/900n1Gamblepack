--MAIN CODE, ALL FUNCTIONS AND ASSETS WILL BE PLACED HERE

if not ninehund then
	ninehund = {}
end

local mod_path = "" .. SMODS.current_mod.path
ninehund.path = mod_path

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

--custom colors lol!!
G.C.RAINBOW = {0,0,0,1}
G.C.VOID = {0,0,0,1}
local ninecolors = {
    rainbow = {0,0,0,1}
}

local loclolc = loc_colour
function loc_colour(_c, _default)
    if not G.ARGS.LOC_COLOURS then
        loclolc()
    end
    G.ARGS.LOC_COLOURS.rainbow = G.C.RAINBOW
    return loclolc(_c, _default)
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

    --WHY DOES IT WORK LIKE THIS
    ninecolors.rainbow = hsvToRgb(G.TIMERS.REAL*0.2,1,0.8,1)
    self.C.RAINBOW[1] = ninecolors.rainbow[1]
    self.C.RAINBOW[2] = ninecolors.rainbow[2]
    self.C.RAINBOW[3] = ninecolors.rainbow[3]

    self.C.VOID[1] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5))
    self.C.VOID[2] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5 + 2))
    self.C.VOID[3] = 0.2*(1+math.sin(self.TIMERS.REAL*1.5 + 4))

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


--ASSETS
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

--AND FINALLY:
--Load Library Files, shout out to yahiamice for where he got this code in his mod so i can finally separate my main lua file
local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[900n1] loading le " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err) 
	end
	f()
end