-- markov melodies
--
-- a druid skript for monome crow that generates two sequences based on markov chains
-- lllllll.co @sbaio


-- transformation matrix
tmx_cv1 = {
	-- same, up, down
  	{0.6, 0.2, 0.1}, -- smae
  	{0.3, 0.4, 0.3}, -- up
  	{0.1, 0.7, 0.2}  -- down
}

tmx_beat1 = {
	-- beat, pause
	{0.6, 0.4}, -- beat
	{0.8, 0.2}  -- pause
}

tmx_cv2 = {
	-- same, up, down
  	{0.2, 0.5, 0.3}, -- smae
  	{0.1, 0.4, 0.5}, -- up
  	{0.3, 0.7, 0.0}  -- down
}

tmx_beat2 = {
	-- beat, pause
	{0.1, 0.9}, -- beat
	{0.5, 0.5}  -- pause
}


-- scales

local CONFIG = {
	SCALES = {
		["chromatic"] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		["major pentatonic"] = {0, 2, 4, 7, 9, 12},
		["minor pentatonic"] = {0, 3, 5, 7, 10, 12},
		["major"] = {0, 2, 4, 5, 7, 9, 11, 12},
		["minor"] = {0, 2, 3, 5, 7, 8, 10, 12}
	}
}

-- initial settings
scale = CONFIG.SCALES["minor pentatonic"]

octave = 0
octave_range = 2

state1 = 1
beat_state1 = 1
note1 = 12

state2 = 1
beat_state2 = 1
note2 = 14

speed = 140
steps = 160



local helpers = {}
local step, get_next_state, get_next_beat_state


helpers.quantize = function(scale, note)
	local note_round = math.floor(note) % 12
	if note_round <= 0 then
		return scale[1]
	end

	for i, scale_note in ipairs(scale) do
		if note_round < scale_note then
			return scale[i - 1]
		elseif note_round == scale_note then
			return scale_note
		end
	end
end

helpers.bpm_to_sec = function(bpm)
	return 60 / bpm / 4
end

helpers.note_to_volt = function(note)
  return note / 12
end


get_next_cv_state = function(probs)
	local state1 = probs[1]
	local state2 = probs[1] + probs[2]
	local state3 = probs[1] + probs[2] + probs[3]

	local next_state_id = math.random()

	local next_state = 1
	if next_state_id <= state1 then
		next_state = 1
	elseif next_state_id <= state2 then
		next_state = 2
	else
		next_state = 3
	end

	return next_state
end


get_next_beat_state = function(probs)
	local state1 = probs[1]
	local state2 = probs[1] + probs[2]

	local next_beat_id = math.random()

	local next_beat = 1
	if next_beat_id <= state1 then
		next_beat = 1
	elseif next_beat_id <= state2 then
		next_beat = 2
	end

	return next_beat
end


function get_cv_and_beat(current_note, probs_cv, probs_beat)
	local new_note_state = get_next_cv_state(probs_cv)
	local new_note = current_note
	if new_note_state == 2 then
		new_note = current_note + 1
	elseif new_note_state == 3 then
		new_note = current_note - 1
	end
	local note_quantized = helpers.quantize(scale, new_note)
	local cv = helpers.note_to_volt(
		-- initial octave
		(octave * 12) +
		-- octave range
		(math.random(octave_range) * 12) +
		-- note
		note_quantized
	)

	local new_beat_state = get_next_beat_state(probs_beat)

	return cv, new_note, new_note_state, new_beat_state == 1, new_beat_state
end

set_bpm = function(bpm_new)
	clock.time = helpers.bpm_to_sec(bpm_new)
end

start = function(bpm, steps)
	speed = bpm
	clock = metro.init{
    	event = step,
    	time = helpers.bpm_to_sec(bpm),
    	count = steps
  	}

  	clock:start()
end

stop = function()
	clock:stop()
end


step = function()
	cv1, note1, state1, beat1, beat_state1 = get_cv_and_beat(note1, tmx_cv1[state1], tmx_beat1[beat_state1])
  	output[4].volts = cv1
  	if beat1 == true then
  		output[3]()
  	end

  	cv2, note2, state2, beat2, beat_state2 = get_cv_and_beat(note2, tmx_cv2[state2], tmx_beat2[beat_state2])
  	output[2].volts = cv2
  	if beat2 == true then
  		output[1]()
  	end

  	print(cv1, beat1 and "X" or "O", cv2, beat2 and "X" or "O")
end

input[1].change = function()
	step()
end


function init()
	output[1].action = { to(5,0), to(0, 0.25) }
	output[3].action = { to(5,0), to(0, 0.25) }
	input[1].mode('change',1.0,0.1,'rising')
end