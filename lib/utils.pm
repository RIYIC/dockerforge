package utils;

use strict;


sub random_key {
    join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..16
}

1;