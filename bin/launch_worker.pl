use strict;
use Dancer;
use Worker;

Worker->new()->run(
	threads => 1,
);

