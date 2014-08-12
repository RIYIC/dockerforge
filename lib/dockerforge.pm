package dockerforge;
use Dancer ':syntax';

our $VERSION = '0.1';

# API CONFIG
set content_type => 'application/json'; 
set serializer => 'JSON';

hook before => sub {

    my $route = shift;

    # todos menos a de creacion de usuario post#user
    unless($route->pattern =~ /\/user/ and $route->method eq 'post'){

        unless(vars->{user} = DFUser->load(_id => params->{user})){

            send_error("Not allowed", 403);

        }
    }
}

get '/' => sub {
    template 'index';
};


get 'queue/:job_id' => sub {

    vars->{user}->jobs(_id => params->{job_id})
}


# GET /dockers -> listar dockers
get '/dockers' => sub {

    vars->{user}->containers;

}

# GET /docker/:id -> obtener docker con id <id>
get '/docker/:id' => sub {

    vars->{user}->containers(Id => params->{id});
    
}


# POST /docker -> crear docker (ASINCRONA)
#  - returns status: 202 Accepted, Location: /queue/<job_id> (http://restcookbook.com/Resources/asynchroneous-operations/)
#  - GET /queue/:job_id : devolve o estado do traballo asincrono e os resultados que produxo se os hai
#  Se aconsella que se o traballo e de creacion devolva un status 303 (see also) e un Location: <url ao novo recurso creado>
post '/docker' => sub {
    my $job_id = vars->{user}->createJob(
        "createContainer", 
        params
    );

    status 202;

    header('Location', "/queue/$job_id")
}

# DELETE /docker/:id -> borra un container identificado polo id <id>
del '/docker/:id' => sub {

    my $job_id = vars->{user}->createJob(
        "deleteContainer",
        params,
    );

    status 202;
    header('Location', "/queue/$job_id");
}


# GET /images -> lista as imaxenes dispoñibles que ten UN DETERMINADO CLIENTE
get '/images' => sub {

    # collemos as imaxenes publicas do usuario de sistema, mais as imaxenes do cliente
    my $system_user = DFUser->load(UserId => '0');

    ($system_user->images(public => 1), vars->{user}->images);
}

# GET /image/:id -> obten os detalles da imaxen co id :id
get '/image/:id' => sub {

    vars->{user}->images(Name => params->{id})
}

# POST /image -> Crea a imaxen especificada e subea a todos os anfis (ou so aos do cliente) (ASINCRONA)
post '/image' => sub {

    my $job_id = vars->{user}->createJob(
        "createImage",
        params,
    );

    status 202;
    header('Location', "/queue/$job_id");

}

# DELETE /image/:id -> Borrar unha imaxen especificada
del '/image/:id' => sub {}


# GET /hosts -> lista os hosts dispoñibles
get '/hosts' => sub {}

# GET /host/:id -> obten os detalles dun determinado host
get '/host/:id' => sub {}

# POST /host -> Da de alta na bbdd un novo host (para un determinado cliente)
post '/host' => sub {}

# DELETE /host/:id -> Elimina da bbdd un host
del '/host/:id' => sub {}

true;
