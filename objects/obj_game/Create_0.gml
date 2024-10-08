function move_part(_part)
{
	// Atualizar a posição da parte
	with (_part)
	{
		//show_debug_message("_part: "+string(_part));

		self.x += self.hmv;
		self.y += self.vmv;
		move_wrap(true, true, -32);
	}
}

function move_head() {
	var _h_input = -keyboard_check_pressed(ord("A")) + keyboard_check_pressed(ord("D"));
    var _y_input = -keyboard_check_pressed(ord("W")) + keyboard_check_pressed(ord("S"));

	with (obj_snake)
	{
	    // Definir movimento somente se o jogador alterar a direção
	    if (_h_input != 0 && hmv == 0)
		{
	        self.hmv = _h_input * self.spd;
	        self.vmv = 0; // Pausa o movimento vertical ao mover horizontalmente
			self.register_turn();
	    }

	    if (_y_input != 0 && self.vmv == 0)
		{
	        self.vmv = _y_input * self.spd;
	        self.hmv = 0; // Pausa o movimento horizontal ao mover verticalmente
			self.register_turn();
	    }
		obj_game.move_part(self);
		//show_debug_message("body_arr: "+string(body_arr))
		
		move_body();
	}
}

function create_new_food()
{
	var _food_x, _food_y;
	var _valid_position = false;
	
	// Continue gerando novas coordenadas até encontrar uma posição válida
	while (!_valid_position)
	{
		// Gera novas coordenadas aleatórias para a comida
		_food_x = irandom_range(0, room_width - 32);
		_food_y = irandom_range(0, room_height - 32);

		//show_debug_message(string(_food_x) + " " + string(_food_y))

		_valid_position = true; // Assume que a posição é válida inicialmente

		// Itera sobre todos os segmentos da cobra
		with (obj_snake)
		{
			if (x == _food_x && y == _food_y)
			{
				_valid_position = false; // Se houver um segmento na mesma posição, marca como inválida
				break; // Sai do loop para gerar novas coordenadas
			}
		}
	}

	// Cria a comida na nova posição válida
	instance_create_layer(_food_x, _food_y, "Foods", obj_food);
}


function check_eat_food()
{
	with (obj_snake)
	{
		if place_meeting(x, y, obj_food)
		{
			instance_destroy(obj_food);
			rize_body();
		}
	}

	if !instance_exists(obj_food)
	{
		create_new_food();
	}
}

