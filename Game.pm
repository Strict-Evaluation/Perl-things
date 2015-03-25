use strict;
use warnings;
package Game;
use Consts;
use Console;
use Objects;
use Map;
use Names;

sub display_game{
	my $game = $_[0];
	Console::clear_display();
	Map::draw_map($game->{"map"});
	Objects::draw_objects($game->{"objects"});
}

my $char_inputs = {
	l=>sub{
		Objects::walk($_[0]->{"objects"}->[0], Consts::RIGHT, 1.0);
	},
	k=>sub{
		Objects::walk($_[0]->{"objects"}->[0], Consts::UP, 1.0);
	},
	j=>sub{
		Objects::walk($_[0]->{"objects"}->[0], Consts::DOWN, 1.0);
	},
	h=>sub{
		Objects::walk($_[0]->{"objects"}->[0], Consts::LEFT, 1.0);
	},
	a=>sub{
		$_[0]->{"objects"}->[0]->{"speed"}+=1.0;
	},
	s=>sub{
		$_[0]->{"objects"}->[0]->{"speed"}-=1.0;
	},
	q=>sub{
		$_[0]->{"continue"} = 0;
	},
};

sub handle_input{
	my $game = $_[0];
	my $input = $_[1];
	my $decision = $char_inputs->{$input};
	if ($decision){
		$decision->($game);
	}
}

my @object_symbols = ("a".."z", "A".."Z");
my $map_width = 40;
my $map_height = 12;
sub new_game{
	my $game = {
		continue=>1,
		turn=>0,
		objects=>[],
		map=>[[]],
		object_creator=>sub{
			my $id = 0; #create a new closure, there's probably a better way...
			return sub{
				return [map {
					Objects::new_object(int(rand($map_width)), int(rand($map_height)),
						$object_symbols[int(rand($#object_symbols+1))], 
						Names::random_name(3), Consts::RIGHT, 0.0, $id++);
					} (1..$_[0])];
			};
		}->(),
		map_creator=>sub{
			return Map::new_map($_[0], $_[1], sub{
				my $m = $_[0];
				for (my $x = 0; $x < $_[1]; $x++){
					for (my $y = 0; $y < $_[2]; $y++){
						$m->[$x][$y]->{"symbol"} = '.';
					}
				}
				return $m;
			});
		},
	};
	$game->{"map"} = $game->{"map_creator"}->($map_width, $map_height);
	#$game->{"objects"} = $game->{"object_creator"}->(5);
	add_object($game);
	return $game;
}

sub add_object{
	my $game = $_[0];
	$game->{"objects"} = $game->{"object_creator"}->(1);
	return $game->{"objects"}->[$#{$game->{"objects"}}];
}

sub add_player{
	
}

sub step_game{
	my $game = $_[0];
	for my $object (@{$game->{"objects"}}){
		Objects::step_object($object);
	}
	return $game->{"continue"};
}

sub run_game{
	my $game = $_[0];
	Console::start_display();
	while (1){
		display_game($game);
		handle_input($game, Console::get_char());
		last unless step_game($game);
	}
	Console::end_display();
}

1;
