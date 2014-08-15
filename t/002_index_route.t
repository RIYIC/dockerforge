use Test::More;
use strict;
use warnings;

# the order is important
use dockerforge;
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 403, 'response status is 403 because user is not authorized /';


foreach my $entity (qw(
    user
    image
    container
    host)){

    foreach my $action (qw(GET POST DELETE)){
        
        if($action eq 'GET'){
            route_exists [$action => "/$entity/:id"], "a route handler is defined for $action => /$entity/:id";
            route_exists [$action => '/'.$entity.'s'], "a route handler is defined for $action => /$entity".'s';
        }
        elsif($action eq 'DELETE'){
            route_exists [$action => "/$entity/:id"], "a route handler is defined for $action => /$entity/:id";  
        }
        else{

            route_exists [$action => "/$entity"], "a route handler is defined for $action => /$entity";
        }
    }
}


done_testing();