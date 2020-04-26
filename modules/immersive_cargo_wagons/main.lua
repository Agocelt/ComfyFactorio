local Global = require 'utils.global'
local Event = require 'utils.event'
local Functions = require "modules.immersive_cargo_wagons.functions"
local Public = {}

local math_round = math.round

local icw = {}
Global.register(
    icw,
    function(tbl)
        icw = tbl
    end
)

function Public.reset_tables()
	for k, v in pairs(icw) do icw[k] = nil end
	icw.doors = {}
	icw.wagons = {}
	icw.trains = {}
	icw.players = {}
	icw.surfaces = {}
end

local function on_entity_died(event)
	local entity = event.entity
	if not entity and not entity.valid then return end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_player_mined_entity(event)
	local entity = event.entity
	if not entity and not entity.valid then return end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_robot_mined_entity(event)
	local entity = event.entity
	if not entity and not entity.valid then return end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_built_entity(event)
	local created_entity = event.created_entity
	Functions.create_wagon(icw, created_entity)	
	Functions.add_wagon_entity_count(icw, created_entity)
end

local function on_robot_built_entity(event)
	local created_entity = event.created_entity
	Functions.create_wagon(icw, created_entity)
	Functions.add_wagon_entity_count(icw, created_entity)		
end

local function on_player_driving_changed_state(event)
	local player = game.players[event.player_index]
	Functions.use_cargo_wagon_door(icw, player, event.entity)
end

local function on_player_created(event)
	local player = game.players[event.player_index]
	player.insert({name = "cargo-wagon", count = 5})
	player.insert({name = "artillery-wagon", count = 5})
	player.insert({name = "fluid-wagon", count = 5})
	player.insert({name = "locomotive", count = 5})
	player.insert({name = "rail", count = 100})
end

local function on_tick()
	Functions.item_transfer(icw)
	if not icw.rebuild_tick then return end
	if icw.rebuild_tick ~= game.tick then return end
	Functions.reconstruct_all_trains(icw)
	icw.rebuild_tick = nil
end

local function on_init()
	Public.reset_tables()
end

function Public.get_table()
	return icw
end

Event.on_init(on_init)
Event.add(defines.events.on_tick, on_tick)
Event.add(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
Event.add(defines.events.on_player_created, on_player_created)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
Event.add(defines.events.on_robot_mined_entity, on_robot_mined_entity)


return Public