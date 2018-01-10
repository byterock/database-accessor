{

    package Database::Accessor;
    use lib qw(D:\GitHub\database-accessor\lib);

    BEGIN {
        $Database::Accessor::VERSION = "0.01";
    }

    use Data::Dumper;
    use File::Spec;
    use Moose;
    with qw(Database::Accessor::Types);
    use Moose::Util qw(does_role);

    sub BUILD {
        my $self = shift;
        map    { $self->_loadDADClassesFromDir($_) }
          grep { -d $_ }
          map  { File::Spec->catdir( $_, 'Database', 'Accessor', 'DAD' ) } @INC;

    }

    sub _loadDADClassesFromDir {
        my $self = shift;
        my ( $path, $dad ) = @_;
        $dad = {}
          if ( ref($dad) ne 'HASH' );
        opendir( DIR, $path ) or die "Unable to open $path: $!";

        my @files = grep { !/^\.{1,2}$/ } readdir(DIR);

        # Close the directory.
        closedir(DIR);

        @files = map { $path . '/' . $_ } @files;

        for (@files) {

            # If the file is a directory
            if ( -d $_ ) {
                $self->_loadDADClassesFromDir( $_, $dad );

                # using a new directory we just found.
            }
            elsif (/.pm$/) {    #we only care about pm files
                my ( $volume, $dir, $file ) = File::Spec->splitpath($_);
                $file =~ s{\.pm$}{};                      # remove .pm extension
                $dir  =~ s/\\/\//gi;
                $dir  =~ s/^.+Database\/Accessor\/DAD\///;
                my $_package =
                  join '::' => grep $_ => File::Spec->splitdir($dir);

                # # untaint that puppy!
                my ($package) =
                  $_package =~ /^([[:word:]]+(?:::[[:word:]]+)*)$/;

                my $classname = "";

                if ($package) {
                    $classname = join '::', 'Database', 'Accessor', 'DAD',
                      $package, $file;
                }
                else {
                    $classname = join '::', 'Database', 'Accessor', 'DAD',
                      $file;
                }
                eval "require $classname";

                if ($@) {
                    my $err = $@;
                    my $advice =
"Database/Accessor/DAD/$file ($classname) may not be an Database Accessor Driver (DAD)!\n\n";
                    warn(
"\n\n Load of Database/Accessor/DAD/$file.pm failed: \n   Error=$err \n $advice\n"
                    );
                    next;
                }
                else {
                    next
                      unless (
                        does_role(
                            $classname, 'Database::Accessor::Roles::DAD'
                        )
                      );    #now only loads this class
                    $dad->{ $classname->DB_Class } = $classname;
                }

            }

        }
        $self->_ldad($dad)
          if ( keys($dad) )

    }

    has _ldad => (
        isa => 'HashRef',
        is  => 'rw',
    );

    has view => (
        is     => 'rw',
        isa    => 'View',
        coerce => 1,
    );

    has elements => (
        isa    => 'ArrayRefofElements',
        coerce => 1,
        is     => 'rw',
    );

    has conditions => (
        is      => 'rw',
        isa     => 'ArrayRefofPredicates',
        coerce  => 1,
        default => sub { [] },

    );

    sub retrieve {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        my $drivers = $self->_ldad();
        my $driver  = $drivers->{ ref($conn) };

        die "No Database::Accessor::Driver loaded for "
          . ref($conn)
          . " Maybe you have to install a Database::Accessor::DAD::?? for it?"
          unless ($driver);

        my $dad = $driver->new(
            {
                View     => $self->view,
                Elements => $self->elements
            }
        );

        return $dad->Execute( "retrieve", $conn, $container, $opt );
    }

}

{

    package Database::Accessor::Roles::Base;

    BEGIN {
        $Database::Accessor::Roles::DAD::VERSION = "0.01";
    }

    use Moose::Role;
    has 'name' => (

        required => 1,
        is       => 'rw',
        isa      => 'Str'

    );

    has 'alias' => (

        is  => 'rw',
        isa => 'Str'

    );

    1;

}

{
    package 
           Database::Accessor::View;
    use Moose;
    with qw(Database::Accessor::Roles::Base);

}
{
    package 
           Database::Accessor::Element;
    use Moose;
    with qw(Database::Accessor::Roles::Base);
}

{
    package 
           Database::Accessor::Predicate;
    use Moose;
    with qw(Database::Accessor::Roles::Base);

    

    has operator => (
        is      => 'rw',
        isa     => 'Str',
        default => '='
    );

    has left => (
        is       => 'rw',
        isa      => 'Element',
        required => 1,
        coerce   => 1,
    );

    has right => (
        is       => 'rw',
        isa      => 'Element',
        required => 1,
        coerce   => 1,
    );

    # has open_parenthes => (
    # is  => 'rw',
    # isa => 'Int',
    # default => 0,
    # alias    => [qw(open open_paren)]

    # );

    # has close_parenthes => (
    # is  => 'rw',
    # isa => 'Int',
    # default => 0,
    # alias    => [qw(close close_paren)]

    # );

    1;
}
{
    package Database::Accessor::Roles::DAD;

    BEGIN {
        $Database::Accessor::Roles::DAD::VERSION = "0.01";
    }

    use Moose::Role;
    requires 'DB_Class';
    requires 'Execute';

    has View => (
        is  => 'ro',
        isa => 'Object',
    );

    has Elements => (
        isa => 'ArrayRef',
        is  => 'ro',
    );
    has Conditions => (
        isa => 'ArrayRef',
        is  => 'ro',
    );
    1;

}


# __PACKAGE__->meta->make_immutable;
1;

