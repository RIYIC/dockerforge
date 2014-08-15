package DFBase;

use strict;
use Eixo::Base::Clase;
# use parent qw(Eixo::Base);
use MongoDB;

my $CLIENT;

has(
    _id => undef
);

sub to_hash {

    my $res = {};

    while(my ($key, $value) = each(%{$_[0]})){
        $res->{$key} = $value unless($key =~ /^\_/);
    }

    $res;
}


sub initialize {
    my $self = $_[0];

    my $class = ref($self);

    no strict 'refs';

    # Creamos accesors para as relacions
    my %has_one_relations = $self->HAS_ONE();
    while(my ($attribute, $obj_class) = each(%has_one_relations)){

        unless(defined(&{$class . '::' . $attribute})){

            *{$class . '::' . $attribute} = sub {

                my ($self, $obj)  = @_;

                if(defined($obj)){
                    
                    $self->{'_id_'.$obj_class} = $obj->_id;
                    
                    $self;
                }
                else{
                    $obj_class->load(_id => $self->{'_id_'.$obj_class});
                }   

            };
        }
    }

    my %has_many_relations = $self->HAS_MANY();

    while(my ($attribute, $obj_class) = each(%has_many_relations)){

        unless(defined(&{$class . '::' . $attribute})){

            # solo ten getter

            *{$class. '::' . $attribute} = sub {
                my ($self, %args) = @_;

                $obj_class->find(
                    ('_id_'.$class => $self->_id, %args)
                );

            }
        }
    }
}


sub HAS_ONE {}
sub HAS_MANY {}

# class methods
sub load {
    my ($class, %args) = @_;
    # my $cursor = &__collection($class)->find(\%args)->limit(1);

    # my $doc =  $cursor->next;
    # # print Dumper($doc);

    # my $e = ($doc)? $class->new(%$doc) : undef;
    # # print Dumper($e); use Data::Dumper;
    # return $e;
    
    my $doc = &__collection($class)->find_one(\%args);

    ($doc)? $class->new(%$doc) : undef;
}

sub find {

    my ($class, %args) = @_;

    my $cursor = &__collection($class)->find(\%args);

    map {$class->new(%$_)} $cursor->all;
}

sub save {

    my $self = $_[0];

    if($self->_id){

        &__collection(ref($self))->update(
            
            {_id => $self->_id},
            
            $self,

            {upsert => 1}

        );
    }
    else{

        my $oid = &__collection(ref($self))->insert($self, {upsert => 1});

        $self->_id($oid);
    }

    $self;

}


sub remove {

    my $self = $_[0];

    &__collection(ref($self))->remove({_id => $self->_id});

    $self = {};
}


sub __collection {
    my $class = $_[0];

    unless(defined($CLIENT)){
        $CLIENT = MongoDB::MongoClient->new(host => 'mongo', port => 27017);
    }

    my $pluralized_class = $class.'s';

    $CLIENT->get_database('dockerforge')->get_collection($pluralized_class);
}



1;