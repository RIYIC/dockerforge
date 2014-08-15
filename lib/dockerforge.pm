package dockerforge;
use strict;

use Dancer ':syntax';
use DFUser;

our $VERSION = '0.1';

# API CONFIG
set content_type => 'application/json'; 
set serializer => 'JSON';

hook before => sub {

    my $route = shift;

    # todos menos a de creacion de usuario post#user
    unless($route->pattern =~ /\/user/ and $route->method eq 'post'){

        unless(vars->{user} = DFUser->load(UserId => params->{user})){
            error "User ".params->{user}." not found!";
            send_error("Not allowed", 403);

        }
    }
};


get '/' => sub {
    template 'index';
};


get 'queue/:job_id' => sub {

    [vars->{user}->jobs(_id => params->{job_id})]->[0]->to_hash;
};


# GET /containers -> listar dockers
get '/containers' => sub {

    [map {$_->to_hash} vars->{user}->containers];

};

# GET /container/:id -> obtener docker con id <id>
get '/container/:id' => sub {

    [vars->{user}->containers(Id => params->{id})]->[0]->to_hash;
    
};


# POST /container -> crear docker (ASINCRONA)
#  - returns status: 202 Accepted, Location: /queue/<job_id> (http://restcookbook.com/Resources/asynchroneous-operations/)
#  - GET /queue/:job_id : devolve o estado do traballo asincrono e os resultados que produxo se os hai
#  Se aconsella que se o traballo e de creacion devolva un status 303 (see also) e un Location: <url ao novo recurso creado>
post '/container' => sub {
    my $job_id = vars->{user}->createJob(
        "createContainer", 
        params
    );

    status 202;

    header('Location', "/queue/$job_id")
};

# DELETE /docker/:id -> borra un container identificado polo id <id>
del '/container/:id' => sub {

    my $job_id = vars->{user}->createJob(
        "deleteContainer",
        params,
    );

    status 202;
    header('Location', "/queue/$job_id");
};


# GET /images -> lista as imaxenes dispoñibles que ten UN DETERMINADO CLIENTE
get '/images' => sub {

    # collemos as imaxenes publicas do usuario de sistema, mais as imaxenes do cliente
    my $system_user = DFUser->load(UserId => '0');

    ($system_user->images(public => 1), vars->{user}->images);
};

# GET /image/:id -> obten os detalles da imaxen co id :id
get '/image/:id' => sub {

    [vars->{user}->images(Name => params->{id})]->[0]->to_hash
};

# POST /image -> Crea a imaxen especificada e subea a todos os anfis (ou so aos do cliente) (ASINCRONA)
post '/image' => sub {

    my $job_id = vars->{user}->createJob(
        "createImage",
        params,
    );

    status 202;
    header('Location', "/queue/$job_id");

};

# DELETE /image/:id -> Borrar unha imaxen especificada
del '/image/:id' => sub {
    my $job_id = vars->{user}->createJob(
        "deleteImage",
        params
    );

    status 202;
    header('Location', "/queue/$job_id");

};


# GET /hosts -> lista os hosts dispoñibles
get '/hosts' => sub {         

    [map {$_->to_hash} (vars->{user}->hosts)]
};

# GET /host/:id -> obten os detalles dun determinado host
get '/host/:id' => sub {
    [vars->{user}->hosts(Hostname => params->{id})]->[0]->to_hash
};

# POST /host -> Da de alta na bbdd un novo host (para un determinado cliente)
post '/host' => sub {};

# DELETE /host/:id -> Elimina da bbdd un host
del '/host/:id' => sub {};

true;
