use Test::More;
use strict;
use warnings;

# the order is important
use dockerforge;
use Dancer::Test;

# route_exists [GET => '/'], 'a route handler is defined for /';
# response_status_is ['GET' => '/'], 500, 'response status is 403 because user is not authorized /';


foreach my $entity (qw(
    users
    images
    containers
    hosts)){

    foreach my $action (qw(GET POST DELETE)){

        if(grep {$_ eq $action} (qw(GET DELETE PATCH))){
            route_exists [$action => "/v1/$entity/:id"], "a route handler is defined for $action => /v1/$entity/:id";
        }

        if(grep {$_ eq $action} (qw(GET POST))){
            route_exists [$action => "/v1/$entity"], "a route handler is defined for $action => /v1/$entity";            
        }
    }
}


done_testing();