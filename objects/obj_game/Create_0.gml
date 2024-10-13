function main()
{
	// Definir o tamanho da room
	room_width = 1920;
	room_height = 1080;

	// Definir o tamanho da janela
	window_set_size(1280, 720);

	// Habilitar e configurar a view
	view_enabled = true;
	view_visible[0] = true;
	view_wview[0] = 1920; // Tamanho da view na room
	view_hview[0] = 1080;  // Tamanho da view na room
	view_wport[0] = 1920; // Tamanho da view na janela
	view_hport[0] = 1080;  // Tamanho da view na janela
	
	window_center();

	food_layer = layer_create(-1, "FoodLayer");
	snake_layer = layer_create(0, "SnakeLayer");
	body_layer = layer_create(1, "BodyLayer");
	
	heads_array = [spr_snake_green_head_32, spr_snake_yellow_head_32];
	blob_array = [spr_snake_green_blob_32, spr_snake_yellow_blob_32];
	foods_array = [spr_apple_alt_32, spr_apple_green_32, spr_apple_red_32, spr_easter_egg_32];
	obstacles_array = [spr_bomb_32, spr_oliebol_32];

//	show_debug_message("snake_layer: " + string(snake_layer));
//	show_debug_message("body_layer: " + string(body_layer));
//	show_debug_message("food_layer: " + string(food_layer));

	body_size = 0;
	body_array = [];

	new_turn_point = false;
	turn_array = [];

	snake_speed = 5;
	stop_tail = 0;
	
	game_set_speed((30 * snake_speed), gamespeed_fps);

	self.create_head();
	self.create_tail();
	self.create_food();
}

function add_part(_part_object)
{
//	show_debug_message("body_size: "+string(self.body_size))

	var _new_body_part = instance_create_layer(
			self.snake_tail.x,
			self.snake_tail.y,
			self.snake_layer,
			_part_object
		);

	_new_body_part.turn_index = self.snake_tail.turn_index;
	_new_body_part.hmv = self.snake_tail.hmv;
	_new_body_part.vmv = self.snake_tail.vmv;

	return _new_body_part
}

function move_head() {
	var _h_input = -keyboard_check_pressed(ord("A")) + keyboard_check_pressed(ord("D"));
    var _v_input = -keyboard_check_pressed(ord("W")) + keyboard_check_pressed(ord("S"));

	// Definir movimento somente se o jogador alterar a direção
	if (_h_input != 0 && snake_head.hmv == 0)
	{
	    self.snake_head.hmv = _h_input;
	    self.snake_head.vmv = 0; // Pausa o movimento vertical ao mover horizontalmente
		self.register_turn_point();
        self.snake_head.image_angle = 0;
		self.snake_head.image_xscale = _h_input;
	}

	if (_v_input != 0 && snake_head.vmv == 0)
	{
	    self.snake_head.vmv = _v_input;
	    self.snake_head.hmv = 0; // Pausa o movimento horizontal ao mover verticalmente
		self.register_turn_point();
        self.snake_head.image_angle = 270; // Ajusta o ângulo para a direção correta
		self.snake_head.image_xscale = _v_input;
	}
	self.move_part(snake_head);
}


function register_turn_point()
{
	var _turn_x = snake_head.x;
	var _turn_y = snake_head.y;
	var _turn_vector = [_turn_x, _turn_y];
	
	var _turn_hmv = snake_head.hmv;
	var _turn_vmv = snake_head.vmv;
	var _turn_direction = [_turn_hmv, _turn_vmv];
	
	var _turn_info = [_turn_vector, _turn_direction];
	
	array_insert(self.turn_array, 0, _turn_info);
	self.new_turn_point = true;
//	show_debug_message("Added turn_point: "+string(self.turn_array));
}


function move_part(_part)
{
	// Atualizar a posição da parte
	with (_part)
	{
		self.x += self.hmv;
		self.y += self.vmv;
		move_wrap(true, true, 20);
	}
}


function check_body_colision()
{
	var _x_offset, _y_offset;
	var _valid_position = false;
	var _pointers;

	_x_offset = self.snake_head.sprite_width / 2;
	_y_offset = self.snake_head.sprite_height / 2;

	if self.snake_head.hmv != 0
	{
		_pointers = [
			[self.snake_head.x + _x_offset * self.snake_head.hmv, self.snake_head.y + _y_offset],
			[self.snake_head.x + _x_offset * self.snake_head.hmv, self.snake_head.y - _y_offset]
		];
	}

	if self.snake_head.vmv != 0
	{
		_pointers = [
			[self.snake_head.x + _x_offset, self.snake_head.y + _y_offset * self.snake_head.vmv],
			[self.snake_head.x - _x_offset, self.snake_head.y + _y_offset * self.snake_head.vmv]
		];
		
	}

	for (var _i = 2; _i < array_length(self.body_array); _i++) {
		var _part = self.body_array[_i];
		if (point_in_triangle(
				_part.x, _part.y,
				self.snake_head.x, self.snake_head.y,
				_pointers[0][0], _pointers[0][1],
				_pointers[1][0], _pointers[1][1]
			))
			{
				show_debug_message("Entrou")
                // Se houver colisão, finalize o jogo
                game_over(); // Chame a função para encerrar o jogo
			}
	}
}

function game_over()
{
	draw_sprite(spr_snake_green_xx, 1, room_width / 2, room_height / 2);
	self.snake_head.alive = false;
}


function move_body()
{
	var _index = self.body_size;
	while _index > 0
	{
		var _part = self.body_array[_index];
		self.check_turn_point(_part);
		self.move_part(_part);
		_index --;
	}
}

function move_tail()
{
	if self.stop_tail <= 0
	{ 
		self.move_part(self.snake_tail);
		self.stop_tail = 0;
	}
	
	if self.stop_tail > 0
	{ self.stop_tail --; }

	var _turned = self.check_turn_point(self.snake_tail);
	if _turned
	{
		array_pop(self.turn_array);
//		show_debug_message("Added turn: "+string(self.turn_array));

	}
	
	self.new_turn_point = false;
}

function change_food_position()
{
	// TODO: Precisa ser melhorado esse trecho, tem margem para erro no tamanho da cabeça
	var _food_x, _food_y, _food_x_offset, _food_y_offset;
	var _valid_position = false;
	
	// Continue gerando novas coordenadas até encontrar uma posição válida
	while (!_valid_position)
	{
		// Gera novas coordenadas aleatórias para a comida
		_food_x_offset = self.food.sprite_width / 2;
		_food_x = irandom_range(_food_x_offset, room_width - _food_x_offset);
		_food_y_offset = self.food.sprite_height / 2;
		_food_y = irandom_range(_food_y_offset, room_height - _food_y_offset);

		//show_debug_message(string(_food_x) + " " + string(_food_y))

		// Itera sobre todos os segmentos da cobra
		_valid_position = !bool(collision_rectangle(
				_food_x - _food_x_offset,
				_food_y - _food_y_offset,
				_food_x + _food_x_offset,
				_food_y + _food_y_offset,
				self.body_array,
				true,
				true
			)
		)
	}
	self.food.x = _food_x;
	self.food.y = _food_y;
}

function check_part_colision(_part, _colliding_with)
{
	with _part
	{
		return place_meeting(x, y, _colliding_with)
	}
}


function check_food_colision()
{
	if check_part_colision(self.snake_head, self.food)
	{
		self.change_food_position();
		self.grow_body();
		self.food.sprite_index = random_get_array(self.foods_array);
	}
}

function grow_body()
{
//	show_debug_message("body_arr: "+string(body_array));
	var _new_part = self.add_part(obj_body);
	_new_part.sprite_index = random_get_array(self.blob_array);
	self.body_size ++;
	array_insert(self.body_array, self.body_size, _new_part);
	self.stop_tail += _new_part.sprite_width;
//	show_debug_message("body_arr: "+string(body_array));
}

function check_turn_point(_part)
{
//	show_debug_message("Checando turn point")

//	show_debug_message("### ----------------------------------------------- ###")
//	show_debug_message("self.new_turn_point: "+string(self.new_turn_point))
//	show_debug_message("_part: "+string(_part.id))
	
//	show_debug_message("_part.turn_index: "+string(_part.turn_index));
	_part.turn_index += real(self.new_turn_point);
//	show_debug_message("_part.turn_index: "+string(_part.turn_index));

	if (_part.turn_index == -1)
	{ return false; }

//	show_debug_message("self.turn_array: "+string(self.turn_array));
	var _turn_info = self.turn_array[real(_part.turn_index)];
	var _turn_vector = _turn_info[0];
//	show_debug_message(_turn_vector);

	if (_part.x == _turn_vector[0] && _part.y == _turn_vector[1])
	{
		var _turn_direction = _turn_info[1];
		_part.hmv = _turn_direction[0];
		_part.vmv = _turn_direction[1];

		_part.turn_index --;
		return true;
	}
	return false;
}


function refresh_room()
{
	draw_clear(c_black);
}


function random_get_array(_array)
{
	return _array[random(array_length(_array))];
}


function create_head()
{
	snake_head = instance_create_layer(room_width / 2, room_height / 2, self.snake_layer, obj_body);
	snake_head.hmv = 1;
	array_insert(self.body_array, 0, snake_head);
	snake_head.sprite_index = spr_snake_yellow_head_32;
	snake_head.alive = true;
//	show_debug_message("snake_head.id: " + string(self.snake_head.id));
//	object_set_sprite(obj_head, spr_snake_yellow_head_32);
}


function create_tail()
{
	snake_tail = instance_create_layer(self.snake_head.x, self.snake_head.y, self.body_layer, obj_body);
	snake_tail.hmv = self.snake_head.hmv;
	array_insert(self.body_array, 1, snake_tail);
	self.stop_tail += self.snake_tail.sprite_width;
//	show_debug_message("snake_tail.id: " + string(snake_tail.id));
	snake_tail.sprite_index = spr_snake_yellow_blob_32;
}


function create_food()
{
	food = instance_create_layer(0, 0, self.food_layer, obj_food);
	self.change_food_position();
}


main();