package dockerforge;
use strict;

use Dancer ':syntax';
use DFUser;
use MIME::Base64;
use Data::Dumper;

our $VERSION = '0.1';

# API CONFIG
set content_type => 'application/json'; 
set serializer => 'JSON';

# api version 1
prefix '/v1';

hook before => sub {

    my $route = shift || return 1;

    # todos menos a de creacion de usuario post#user
    unless(
        (request->path =~ /\/errors\/\d+/) or 
        (request->path eq '/users' and request->method eq 'post')
     
        ){

        # autenticar usuario
        # my ($scheme, $auth) = (header("Authorization") =~ /(.+)\s(.+)/)
        # podemos tratar de usar un token para autenticar, ou unha cookie, 
        # pero sempre primeiro habera que facer un login co user e pass

        # https://auth0.com/blog/2014/01/07/angularjs-authentication-with-cookies-vs-token/

        my ($auth) = (request->headers->authorization =~ /Basic\s+(.+)/);

        my ($user, $password) = split(':', decode_base64($auth));

        unless(vars->{user} = DFUser->load(_id => $user)){

            error "User ".($user || '')." not found!";
            # redirect("/errors/402");
            request->path_info(prefix.'/errors/403');

        }
        # # autenticar
        # unless(bcrypt(password) eq (vars->{user}->password){
        #     send_error("Not Authorized", 403);
        # }

    }
};


any "/errors/:errno" => sub {
    send_error("Not Authorized", params->{errno});
  
};

post '/users' => sub {

    my $user = DFUser->new(%{params()});

    $user->save();

    my $res = $user->to_hash;

    $res->{_id} = $user->_id->value;

    $res;
};


# GET /containers -> listar dockers
get '/containers' => sub {

    [map {$_->to_hash} vars->{user}->containers];

};

# GET /container/:id -> obtener docker con id <id>
get '/containers/:id' => sub {

    [vars->{user}->containers(Id => params->{id})]->[0]->to_hash;
    
};


# POST /container -> crear docker (ASINCRONA)
#  - returns status: 202 Accepted, Location: /queue/<job_id> (http://restcookbook.com/Resources/asynchroneous-operations/)
#  - GET /queue/:job_id : devolve o estado do traballo asincrono e os resultados que produxo se os hai
#  Se aconsella que se o traballo e de creacion devolva un status 303 (see also) e un Location: <url ao novo recurso creado>
post '/containers' => sub {
    my $params = params;
    my $job_id = vars->{user}->createJob(
        "createContainer", 
        $params
    );

    status 202;

    header('Location', prefix."/queue/$job_id")
};

# DELETE /docker/:id -> borra un container identificado polo id <id>
del '/containers/:id' => sub {

    my $params = params();

    my $job_id = vars->{user}->createJob(
        "deleteContainer",
        $params,
    );

    status 202;
    header('Location', prefix."/queue/$job_id");
};


# GET /images -> lista as imaxenes dispoñibles que ten UN DETERMINADO CLIENTE
get '/images' => sub {

    # collemos as imaxenes publicas do usuario de sistema, mais as imaxenes do cliente
    my $system_user = DFUser->load(UserId => '0');

    ($system_user->images(public => 1), vars->{user}->images);
};

# GET /image/:id -> obten os detalles da imaxen co id :id
get '/images/:id' => sub {

    [vars->{user}->images(Name => params->{id})]->[0]->to_hash
};

# POST /image -> Crea a imaxen especificada e subea a todos os anfis (ou so aos do cliente) (ASINCRONA)
post '/images' => sub {

    my $params = params;

    my $job_id = vars->{user}->createJob(
        "createImage",
        $params,
    );

    status 202;
    header('Location', prefix."/queue/$job_id");

};

# DELETE /image/:id -> Borrar unha imaxen especificada
del '/images/:id' => sub {
    my $params = params;
    my $job_id = vars->{user}->createJob(
        "deleteImage",
        $params
    );

    status 202;
    header('Location', prefix."/queue/$job_id");

};


# GET /hosts -> lista os hosts dispoñibles
get '/hosts' => sub {         

    [map {$_->to_hash} (vars->{user}->hosts)]
};

# GET /host/:id -> obten os detalles dun determinado host
get '/hosts/:id' => sub {
    [vars->{user}->hosts(Hostname => params->{id})]->[0]->to_hash
};

# POST /host -> Da de alta na bbdd un novo host (para un determinado cliente)
post '/hosts' => sub {};

# DELETE /host/:id -> Elimina da bbdd un host
del '/hosts/:id' => sub {};

# GET job with id job_id
get '/queue/:job_id' => sub {

    [vars->{user}->jobs(_id => params->{job_id})]->[0]->to_hash;

    # my $job = [vars->{user}->jobs(_id => params->{job_id})]->[0];

    # if($job->done){
    #     if($job->task eq 'createContainer'){

    #         status 303;
    #         header('Location', prefix."/containers/".$job->results->Id);
    #     }
    #     elsif($job->task eq 'createImage'){
    #         status 303;
    #         header('Location', prefix."/images/".$job->results->Id);

    #     }
    # }

    # $job->to_hash;
};



true;
