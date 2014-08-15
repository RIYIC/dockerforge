use test_base;

use_ok(DFUser);
use_ok(DFImage);

my $u = DFUser->load(UserId => 'test') || DFUser->new(UserId => 'test')->save;
my $i ;

map {$_->remove} ($u->images);

my $dockerfile = <<EOF
FROM ubuntu:12.04
EOF
;

ok(
    (
        $u->buildImage(
            Id=>'mi_imagen',
            Dockerfile => $dockerfile,
        ) 
        and $i = ($u->images(Id => 'mi_imagen'))[0]
    ),

    "Image build and registered "
);



done_testing();
