{

    package Database::Accessor;
    use lib qw(D:\GitHub\database-accessor\lib);

    use Moose;
    with qw(Database::Accessor::Types);
    use MooseX::Constructor::AllErrors;
    use Moose::Util qw(does_role);
    use Database::Accessor::Constants;
    use MooseX::MetaDescription;
    use MooseX::AccessorsOnly;
    use MooseX::AlwaysCoerce;
    use Carp;
    use Data::Dumper;
    use File::Spec;

    BEGIN {
        $Database::Accessor::VERSION = "0.01";
    }

    around BUILDARGS => sub {
        my $orig  = shift;
        my $class = shift;
        my $ops   = shift(@_);

        if ( $ops->{retrieve_only} ) {
            $ops->{no_create}   = 1;
            $ops->{no_retrieve} = 0;
            $ops->{no_update}   = 1;
            $ops->{no_delete}   = 1;
        }
        return $class->$orig($ops);
    };

    sub BUILD {
        my $self = shift;
        my $dad  = {};
        map { $self->_loadDADClassesFromDir( $_, $dad ) }
          grep { -d $_ }
          map { File::Spec->catdir( $_, 'Database', 'Accessor', 'DAD' ) } @INC;

        if ( $self->retrieve_only ) {
            foreach my $flag (qw(no_create no_update no_delete)) {
                my $field = $self->meta->get_attribute($flag);
                $field->description->{message} =
                  "No Create, Update or Delete with retrieve_only flag on";
            }
        }

        my %saved = %$self;
        tie(
            %$self,
            "MooseX::AccessorsOnly",
            sub {
                my ( $who, $how, $what ) = @_;
                die
"Attempt to access Database::Accessor::$what directly at $who!";
            }
        );
        %$self = %saved;
    }

    sub _loadDADClassesFromDir {
        my $self = shift;
        my ( $path, $dad ) = @_;

        # $dad = {}
        # if ( ref($dad) ne 'HASH' );
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
                    my $err = substr( $@, 0, index( $@, ' at ' ) );
                    my $advice =
"Database/Accessor/DAD/$file ($classname) may not be an Database Accessor Driver (DAD)!\n\n";
                    warn(
"\n\n Warning Load of Database/Accessor/DAD/$file.pm failed: \n   Error=$err \n $advice\n"
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
          if ( keys($dad) );

    }

    has _ldad => (
        isa => 'HashRef',
        is  => 'rw',
    );

    has no_create => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use create with no_create flag on!" }
    );

    has no_retrieve => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use retrieve with no_retrieve flag on!" }
    );
    has no_update => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use update with no_update flag on!" }
    );
    has no_delete => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use delete with no_delete flag on!" }
    );
    has retrieve_only => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,

    );

    has [
        qw(update_requires_condition
          delete_requires_condition
          )
    ] => ( is => 'ro', isa => 'Bool', default => 1 );

    has view => (
        is       => 'ro',
        isa      => 'View',
        #coerce   => 1,
        required => 1,
    );

    has elements => (
        isa     => 'ArrayRefofElements',
        traits  => ['Array'],
        #coerce  => 1,
        is      => 'ro',
        default => sub { [] },
        handles => { element_count => 'count', },
    );

    has dynamic_elements => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_element           => 'push',
            dynamic_element_count => 'count',
        },
    );

    has conditions => (
        is      => 'ro',
        isa     => 'ArrayRefofConditions',
        traits  => ['Array'],
        #coerce  => 1,
        default => sub { [] },
        handles => { condition_count => 'count', },
    );

    has dynamic_conditions => (
        isa      => 'ArrayRefofConditions',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_condition           => 'push',
            dynamic_condition_count => 'count',
        },
    );

    has dynamic_links => (
        isa      => 'ArrayRefofLinks',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_link           => 'push',
            dynamic_link_count => 'count',
        },
    );
    has links => (
        is      => 'ro',
        isa     => 'ArrayRefofLinks',
        #coerce  => 1,
        default => sub { [] },

    );

    has dynamic_gathers => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_gather           => 'push',
            dynamic_gather_count => 'count',
        },
    );
    has gathers => (
        is      => 'ro',
        isa     => 'ArrayRefofElements',
        #coerce  => 1,
        default => sub { [] },

    );
    has filters => (
        is      => 'ro',
        isa     => 'ArrayRefofConditions',
        #coerce  => 1,
        default => sub { [] },

    );

    has dynamic_filters => (
        isa      => 'ArrayRefofConditions',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_filter           => 'push',
            dynamic_filter_count => 'count',
        },
    );
    has sorts => (
        is      => 'ro',
        isa     => 'ArrayRefofElements',
        #coerce  => 1,
        default => sub { [] },

    );

    has dynamic_sorts => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
        #coerce   => 1,
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            add_sort           => 'push',
            dynamic_sort_count => 'count',
        },
    );

    sub _execute {
        my $self = shift;
        my ( $type, $conn, $container, $opt ) = @_;
        my $drivers = $self->_ldad();
        my $driver  = $drivers->{ ref($conn) };

        die "No Database::Accessor::Driver loaded for "
          . ref($conn)
          . " Maybe you have to install a Database::Accessor::DAD::?? for it?"
          unless ($driver);
        my $dad = $driver->new(
            {
                view               => $self->view,
                elements           => $self->elements,
                dynamic_elements   => $self->dynamic_elements,
                conditions         => $self->conditions,
                dynamic_conditions => $self->dynamic_conditions,
                links              => $self->links,
                dynamic_links      => $self->dynamic_links,
                gathers            => $self->gathers,
                dynamic_gathers    => $self->dynamic_gathers,
                filters            => $self->filters,
                dynamic_filters    => $self->dynamic_filters,
                sorts              => $self->sorts,
                dynamic_sorts      => $self->dynamic_sorts,
            }
        );
        $dad->execute( $type, $conn, $container, $opt );

    }

    sub create {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        die( $self->meta->get_attribute('no_create')->description->{message} )
          if ( $self->no_create() );

        $self->_execute( Database::Accessor::Constants::CREATE,
            $conn, $container, $opt );
    }

    sub retrieve {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;
        die( $self->meta->get_attribute('no_retrieve')->description->{message} )
          if ( $self->no_retrieve() );
        $self->_execute( Database::Accessor::Constants::RETRIEVE,
            $conn, $container, $opt );

        return ref($container);

    }

    sub update {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        die( $self->meta->get_attribute('no_update')->description->{message} )
          if ( $self->no_update() );

        $self->_need_condition( Database::Accessor::Constants::UPDATE,
            $self->update_requires_condition()
        );

        $self->_execute( Database::Accessor::Constants::UPDATE,
            $conn, $container, $opt );
    }

    sub delete {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;
        die( $self->meta->get_attribute('no_delete')->description->{message} )
          if ( $self->no_delete() );
        $self->_need_condition( Database::Accessor::Constants::DELETE,
            $self->delete_requires_condition()
        );

        $self->_execute( Database::Accessor::Constants::DELETE,
            $conn, $container, $opt );
    }

    sub _need_condition {
        my $self = shift;
        my ( $action, $required ) = @_;
        my $is_required = $required || 0;

        die "Attempt to $action without condition"
          if (
            $is_required
            and
            ( $self->condition_count() + $self->dynamic_condition_count() <= 0 )
          );
    }
}



{

    package Database::Accessor::Base;
    use Moose;
    use MooseX::Constructor::AllErrors;
    use MooseX::Aliases;
    with qw(Database::Accessor::Types
             );
    
     has 'name' => (

        required => 0,
        is       => 'rw',
        isa      => 'Str'

    );
    
    1;

}



{

    package Database::Accessor::Roles::Alias;

    BEGIN {
        $Database::Accessor::Roles::Alias = "0.01";
    }

    use Moose::Role;

    has 'alias' => (

        is  => 'rw',
        isa => 'Str',

    );

}

{

    package Database::Accessor::Roles::Comparators;

    use Moose::Role;
    use MooseX::Aliases;
    
 BEGIN {
        $Database::Accessor::Roles::Comparators = "0.01";
    }
    has left => (
        is       => 'rw',
        isa      => 'Element',
        required => 1,
        coerce   => 1,
    );

    has right => (
        is => 'rw',
        isa =>
'Element|Param|Function|Expression|ArrayRefofParams|ArrayRefofElements|ArrayRefofExpressions',
        required => 1,
        coerce   => 1,
    );

    has open_parenthes => (

        is      => 'rw',
        isa     => 'Bool',
        default => 0,
        alias   => [qw(open open_paren)]

    );

    has close_parenthes => (
        is      => 'rw',
        isa     => 'Bool',
        default => 0,
        alias   => [qw(close close_paren)]

    );

    1;
}

{

    package Database::Accessor::Roles::PredicateArray;

    BEGIN {
        $Database::Accessor::Roles::PredicateArray = "0.01";
    }

    use Moose::Role;
    use MooseX::Aliases;

    has predicates => (
        traits  => ['Array'],
        is      => 'rw',
        isa     => 'ArrayRefofPredicates',
        coerce  => 1,
        alias   => 'conditions',
        handles => { predicates_count => 'count', },
    );
    1;
}
{

    package Database::Accessor::View;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::Alias);
    has '+name' => ( required => 1 );
}
{

    package Database::Accessor::Element;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::Alias );
  
    has '+name' => ( required => 1 );

    has 'view' => (

        is  => 'rw',
        isa => 'Str',
        alias=>'table'

    );

    has 'is_identity' => (
        is  => 'rw',
        isa => 'bool',
    );

    has 'aggregate' => (
        is  => 'rw',
        isa => 'Aggregate',
    );

    has 'predicate' => (
        is  => 'rw',
        isa => 'Predicate',
    );

}

{

    package Database::Accessor::Predicate;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::Comparators);

    has operator => (
        is      => 'rw',
        isa     => 'Operator',
        default => '='
    );
    has condition => (
        is      => 'rw',
        isa     => 'Operator',
        default => '='

    );
    1;
}

{

    package Database::Accessor::Param;
    use Moose;
    extends 'Database::Accessor::Base';

    has value => (
        is    => 'rw',
        isa   => 'Str|Undef|ArrayRef',
        alias => 'param',
    );

    1;
}

{

    package Database::Accessor::Function;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::Comparators);

    has 'function' => (
        isa      => 'Str',
        is       => 'rw',
        required => 1,
    );

    1;
}

{

    package Database::Accessor::Expression;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::Comparators);

    has 'expression' => (
        isa      => 'NumericOperator',
        is       => 'rw',
        required => 1,
    );

    1;
}
{

    package Database::Accessor::Condition;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::PredicateArray);

    1;
}
{

    package Database::Accessor::Link;
    use Moose;
    extends 'Database::Accessor::Base';
    with qw(Database::Accessor::Roles::PredicateArray);

    has to => (
        is       => 'rw',
        isa      => 'View',
        required => 1,
        alias    => [qw( to_view view)],
        coerce   => 1,
    );

    has type => (
        is       => 'rw',
        isa      => 'Link',
        required => 1,
    );
    1;
}

{

    package Database::Accessor::Sort;
    use Moose;
    extends Database::Accessor::Element;

    has order => (
        is      => 'rw',
        isa     => 'Order',
        default => Database::Accessor::Constants::ASC
    );

    1;
}
{

    package Database::Accessor::Roles::DAD;

    BEGIN {
        $Database::Accessor::Roles::DAD::VERSION = "0.01";
    }

    use Moose::Role;
    with qw(Database::Accessor::Types);
    requires 'DB_Class';
    requires 'execute';

    has view => (
        is  => 'ro',
        isa => 'View',
    );

    has elements => (
        isa => 'ArrayRefofElements',
        is  => 'ro',
    );
    has conditions => (
        isa => 'ArrayRefofConditions',
        is  => 'ro',
    );

    has links => (
        is  => 'ro',
        isa => 'ArrayRefofLinks',
    );

    has gathers => (
        is  => 'ro',
        isa => 'ArrayRefofElements',

    );
    has filters => (
        is  => 'ro',
        isa => 'ArrayRefofConditions',
    );

    has sorts => (
        is  => 'ro',
        isa => 'ArrayRefofElements',

    );
    has dynamic_elements => (
        isa     => 'ArrayRefofElements',
        is      => 'ro',
        default => sub { [] },
    );

    has dynamic_conditions => (
        is      => 'ro',
        isa     => 'ArrayRefofConditions',
        default => sub { [] },

    );

    has dynamic_links => (
        is      => 'ro',
        isa     => 'ArrayRefofLinks',
        default => sub { [] },

    );

    has dynamic_gathers => (
        is      => 'ro',
        isa     => 'ArrayRefofElements',
        default => sub { [] },

    );
    has dynamic_filters => (
        is      => 'ro',
        isa     => 'ArrayRefofConditions',
        default => sub { [] },

    );
    has dynamic_sorts => (
        is      => 'ro',
        isa     => 'ArrayRefofElements',
        default => sub { [] },

    );
    1;

}

# __PACKAGE__->meta->make_immutable;
1;

=pod
 
=head1 NAME 
Database::Accessor

Need the same data from both Oracle and Mongo, 
Need a good data tier for you app,
Need a CRUD layer but don't need or want an ORM,
Have a SQL DB and don't know SQL
Have a Non-SQL DB and dont' know SQL

Well Database::Accessor is for you!

=head1 VERSION
 
Version 0.03
 
=head1 SYNOPSIS

my $da = Database::Accssor->new({        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        conditions=>[{left           =>{name =>'First',
                                                      view =>'People'},
                                    right          =>{value=>'Jane'},
                                    operator       =>'=',
                                    open_parenthes =>1,
                                   },
                                   {condition      =>'AND',
                                    left           =>{name=>'Last_name',
                                                      view=>'People'},
                                    right          =>{ value=>'Doe'},
                                    operator       =>'=',
                                    close_parenthes=>1
                                    }
                                    ]
                                    
                     ,
  });
  
  $da->add_condition({left           =>{name =>'country_id',
                                                      view =>'People'},
                                    right          =>{value=>22},
                                    operator       =>'=',
                                    condition      =>'AND',
                                   });
 $da->rertrive($dbh,$container);
 $da->insert($mongo,$container);
 $da->add_condition({left           =>{name =>'country_id',
                                                      view =>'People'},
                                    right          =>{value=>22},
                                    operator       =>'=',
                                    condition      =>'AND',
                                   });
 $da->delete($dbh,$container);
 
 The synopsis above only lists few ways you can use Database::Accessor.
 
=head1 DESCRIPTION

Database::Accessor, or Accessor for short or DA, is a CRUD (Create, Retrieve, Update Delete) database interface for any type of database be it SQL, NON-SQL or even a flat file.
The heart of Accessor is an abstrtion of table and data structions into simple sets of hash-refs that are passed into
7 static and 7 dynaic attibutes.

It is important to remember that Accessor is just an interface layer, a way to pass down your abstracted queries down to a Data Accessor Driver DAD.

It is the DAD driver modules that do all of the work. Accessor just provides an interface and common API. All you the progammer provieds is the abstracted vderiosn 

of you data pass it into Accessor and in theory run the same quiery against any type of DB as long as the structure is compatiable and the Database Accessor Driver has been written.

Architecture of a Accessor Application

                      +-+   +------- -+     +-----+    +-----------+
+-------------+       | |---| DAD SQL |-----| DBI |----| Oracle DB | 
| Perl        |  +-+  | |   `---------+     +-----+    +-----------+
| script      |  |A|  |D|   +-----------+   +-------------+
| using       |--|P|--|A|---| DAD Mongo |---| Mongo Engine|
| DA          |  |I|  | |   +-----------+   +-------------+
| Abstraction |  +-+  | |   +---------------+
+-------------+       | |---| Other drivers |-->>
                      +-+   +---------------+

The API, or Application Programming Interface, defines the call interface and variables for Perl scripts to use. The API is implemented by the Perl DBI extension.

The DBI "dispatches" the method calls to the appropriate driver for actual execution. The DBI is also responsible for the dynamic loading of drivers, error checking and handling, providing default implementations for methods, and many other non-database specific duties.

Each driver contains implementations of the DBI methods using the private interface functions of the corresponding database engine. Only authors of sophisticated/multi-database applications or generic library functions need be concerned with drivers.
Notation and Conventions
