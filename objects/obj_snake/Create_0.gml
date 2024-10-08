// velocidade de movimento em pixels/frame
spd = 1;

// Movimentação horizontal, positivo para direita e negativo para esquerda
hmv = spd;

// Movimentação vertical, positivo para cima e negativo para baixo
vmv = 0;

turn_index = -1;

// Tamanho do corpo do playes
body_size = 0;

body_arr = [self.id];

layer_bp = layer_get_id("BodyParts");

turned = false;
turn_array = [];


function rize_body()
{
	var _last_part = body_arr[body_size];
	
	var _new_part_x = _last_part.x + (-_last_part.hmv * (_last_part.sprite_width-15));
	var _new_part_y = _last_part.y + (-_last_part.vmv * (_last_part.sprite_width-15));
	var _new_body_part = instance_create_layer(_new_part_x, _new_part_y, layer_bp, obj_body);
	
	_new_body_part.turn_index = _last_part.turn_index;

	_new_body_part.hmv = _last_part.hmv;
	_new_body_part.vmv = _new_body_part.vmv;

	body_size ++;
	array_insert(body_arr, body_size, _new_body_part);
//	show_debug_message("body_arr: "+string(body_arr))
}

function move_body()
{
	var _i = body_size;
	while (_i > 0)
	{
		var _body_part = body_arr[_i];
		_i--;
		show_debug_message("_body_part: "+string(_body_part))
		show_debug_message("_body_part.turn_index: "+string(_body_part.turn_index))


		obj_game.move_part(_body_part);
		
		if turned
		{
			_body_part.turn_index ++;
		}
		
		if _i == 0
		{
			turned = false;
		}

		if _body_part.turn_index == -1
		{
			continue;
		}

		var _turn_info = turn_array[_body_part.turn_index];

		var _turn_vector = _turn_info[0];

		if _body_part.x == _turn_vector[0] &&
			_body_part.y == _turn_vector[1]
			{
				var _turn_direction = _turn_info[1];
				_body_part.hmv = _turn_direction[0];
				_body_part.vmv = _turn_direction[1];
				
				_body_part.turn_index --;
			}
	}
}

function register_turn()
{
	turned = true;
	
	var _turn_x = x;
	var _turn_y = y;
	var _turn_vector = [_turn_x, _turn_y];
	
	var _turn_hmv = hmv;
	var _turn_vmv = vmv;
	var _turn_direction = [_turn_hmv, _turn_vmv];
	
	var _turn_info = [_turn_vector, _turn_direction];
	
	array_insert(turn_array, 0, _turn_info);
}

rize_body();