    package Database::Accessor;
    
    # ABSTRACT: CRUD Interface for any DB
    # Dist::Zilla: +PkgVersion
    use Moose;
    with qw(Database::Accessor::Types);
    use Moose::Util qw(does_role);
    use Database::Accessor::Constants;
    use MooseX::MetaDescription;
    use MooseX::AccessorsOnly;
    use MooseX::AlwaysCoerce;
    use MooseX::Constructor::AllErrors;

    # use Carp;
    use Data::Dumper;
    use File::Spec;
    use namespace::autoclean;


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
                
                my $_package=
                  join '::' => grep $_ => File::Spec->splitdir($dir);

                # # untaint that puppy!
                my ($package) =
                  $_package=~ /^([[:word:]]+(?:::[[:word:]]+)*)$/;

                my $classname = "";

                if ($package) {
                    $classname = join '::', 'Database', 'Accessor', 'DAD',
                      $package, $file;
                }
                else {
                    $classname = join '::', 'Database', 'Accessor', 'DAD',
                      $file;
                }
                
                # eval qq{package                   # hide from PAUSE
                          # Database::Accessor::DAD::_firesafe;    # ensures that the TRD is present in the path
                          # require $classname;    # load the driver
                # };

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

    has available_DADs =>(
        isa => 'HashRef'
        is  => 'ro'
    
    
    );
        
     

    has no_create => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use create with no_create flag on!",
            not_in_DAD=>1 }
    );

    has no_retrieve => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use retrieve with no_retrieve flag on!",
            not_in_DAD=>1 }
    );
    has no_update => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use update with no_update flag on!",
            not_in_DAD=>1 }
    );
    has no_delete => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { message => "Attempt to use delete with no_delete flag on!",
            not_in_DAD=>1 }
    );
    has retrieve_only => (
        is      => 'ro',
        isa     => 'Bool',
        default => 0,
        traits  => ['MooseX::MetaDescription::Meta::Trait'],
        description =>
          { not_in_DAD=>1 }

    );

  has [
    qw(update_requires_condition
      delete_requires_condition
      )
  ] => (
    is          => 'ro',
    isa         => 'Bool',
    default     => 1,
    traits  => ['MooseX::MetaDescription::Meta::Trait'],
    description => { not_in_DAD => 1 }
  );

    has view => (
        is       => 'ro',
        isa      => 'View',
        required => 1,
    );

    has elements => (
        isa     => 'ArrayRefofElements',
        traits  => ['Array'],
        is      => 'ro',
        default => sub { [] },
        handles => { element_count => 'count', },
    );

    has dynamic_elements => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
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
        default => sub { [] },
        handles => { condition_count => 'count', },
    );

    has dynamic_conditions => (
        isa      => 'ArrayRefofConditions',
        traits   => ['Array'],
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
        default => sub { [] },

    );

    has dynamic_gathers => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
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
        default => sub { [] },

    );
    has filters => (
        is      => 'ro',
        isa     => 'ArrayRefofConditions',
        default => sub { [] },

    );

    has dynamic_filters => (
        isa      => 'ArrayRefofConditions',
        traits   => ['Array'],
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
        default => sub { [] },

    );

    has dynamic_sorts => (
        isa      => 'ArrayRefofElements',
        traits   => ['Array'],
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
        warn("JSP ".Dumper($drivers));
        my $driver  = $drivers->{ ref($conn) };

        die "$type No Database::Accessor::Driver loaded for "
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
        return $container;

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

        $container;

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
    1;

    {
        package
           Database::Accessor::Base;
        use Moose;
        use MooseX::Aliases;
        use MooseX::Constructor::AllErrors;
        use MooseX::AlwaysCoerce;
        with qw(Database::Accessor::Types);
        use namespace::autoclean;
        # around BUILDARGS => sub {

        # my $orig  = shift;
        # my $class = shift;
        # use Data::Dumper;
        # warn(" args=".Dumper(\@_));
        # my $ops   = @_;

        # $ops->{to}= delete($ops->{view})
        # if(ref($class) eq 'Database::Accessor::Link');
        # warn("$orig $class args=".Dumper( $ops));

        # return $class->$orig($ops);

        # };
        has 'name' => (
            required => 0,
            is       => 'rw',
            isa      => 'Str'
        );

        1;

    }

    {

        package
           Database::Accessor::Roles::Alias;
        use Moose::Role;
        use namespace::autoclean;

        has 'alias' => (

            is  => 'rw',
            isa => 'Str',

        );

    }

    {

        package
           Database::Accessor::Roles::Comparators;

        use Moose::Role;
        use MooseX::Aliases;
        use namespace::autoclean;
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

        package
           Database::Accessor::Roles::PredicateArray;
        use Moose::Role;
        use MooseX::Aliases;
        use namespace::autoclean;


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

        package
           Database::Accessor::View;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::Alias);

        has '+name' => ( required => 1 );
    }
    {

        package
           Database::Accessor::Element;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::Alias );

        has '+name' => ( required => 1 );

        has 'view' => (

            is    => 'rw',
            isa   => 'Str',
            alias => 'table'

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

        package
           Database::Accessor::Predicate;
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

        package
          Database::Accessor::Param;
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

        package
          Database::Accessor::Function;
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

        package
          Database::Accessor::Expression;
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

        package
          Database::Accessor::Condition;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::PredicateArray);

        1;
    }
    {

        package
          Database::Accessor::Link;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::PredicateArray);

        has to => (
            is       => 'rw',
            isa      => 'View',
            required => 1,
            alias    => [qw( view to_view )],
        );

        has type => (
            is       => 'rw',
            isa      => 'Link',
            required => 1,
        );
        1;
    }

    {

        package
          Database::Accessor::Sort;
        use Moose;
        extends 'Database::Accessor::Element';
        use namespace::autoclean;

        has order => (
            is      => 'rw',
            isa     => 'Order',
            default => Database::Accessor::Constants::ASC
        );

        1;
    }
    {

        package
          Database::Accessor::Roles::DAD;

        use Moose::Role;
        with qw(Database::Accessor::Types);
        use namespace::autoclean;
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

    1;

__END__
=pod
 

=Abstract: CRUD Interface for any DB
  Need the same data from both Oracle and Mongo, 
  Need a good data tier for you app,
  Need a CRUD layer but don't need or want an ORM,
  Have a SQL DB and don't know SQL
  Have a Non-SQL DB and don't know SQL
  
  Well Database::Accessor is for you!

=head1 SYNOPSIS

 my $da = Database::Accssor->new({
        view     => { name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                     { name => 'last_name',
                       view => 'People' },
                     { name => 'user_id',
                       view => 'People' } ],
        conditions=>[{ left  => { name => 'First',
                                 view => 'People'},
                       right => { value    => 'Jane'},
                                 operator => '=',
                                 open_parenthes =>1,},
                     { condition      =>'AND',
                       left           =>{ name  =>'Last_name',
                                          view  =>'People'},
                       right          =>{ value =>'Doe'},
                       operator       => '=',
                       close_parenthes=> 1
                      }]
    });
  $da->add_condition({left      =>{name =>'country_id',
                                   view =>'People'},
                      right     =>{value=>22},
                      operator  =>'=',
                      condition =>'AND'});
 $da->rertieve($dbh,$container);
 $da->insert($mongo,$container);
 $da->add_condition({left           =>{name =>'country_id',
                                       view =>'People'},
                     right          =>{value=>22},
                     operator       =>'=',
                     condition      =>'AND'});
 $da->delete($dbh,$container);
 
The synopsis above only lists few ways you can use Database::Accessor.
 
=head1 DESCRIPTION

Database::Accessor, or DA for short, is a CRUD (Create, Retrieve, Update Delete) database interface for any type of database be it SQL, NON-SQL or even a flat file.

The heart of Accessor is an simple abstraction language that breaks down data structures into simple sets of hash-refs that are passed into a Database::Accessor::Driver that will process the action.

It is important to remember that Accessor is just an interface layer, a way to pass down your abstracted queries down to a Data Accessor Driver or DAD for short.

It is the DAD driver modules that do all of the work. Accessor just provides an interface and common API. All you the progammer provides is the abstracted version of you data.  In in theory you should be able to run the same DA against any type of DB and come back with the same results.  Assuming the same structure and data are in each.

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

The API, or Application Programming Interface, are the four CRUD functions provided by DA, and a Hash-ref, supplied by the programmer, that defines the data structure with DA's abstration language. 

The DA simply passes down a set of attributes that are then re-assembles and then dispatched by the DAD layer down to the DB layer whatever that may be. 

Usage Outline 
First DA is not an ORM, it knows nothing about the Data Base you are atempting to interact with. By itself it does nothing.  All it does it provides a set of attribures that are 
passed down to a DAD which will do the work.

Though it can be used directly it is best used within another abstracted class, say startoing with this class;

package SomeDB::Address;

use Database::Accessor;

sub new {
    my $class = shift;
    my $self = {};
    bless( $self, ( ref($class) || $class ) );
    return  Database::Accessor->new({
                view=>'address',
             elements=>[{name=> 'id'},
                        {name=> 'street'},
                        {name=> 'city'},
                        {name=> 'postal_code'},
                        {name=> 'region_id'},
                        {name=> 'country_id'},
                        {name=> 'time_zone_id'}]});
}


and then called by another script whith a sub like this one for a simple add;

sub add_address {
    my $self   = shift;
    my ($db,$street,$city,$pc,$province) = _@;
   
    my $address = SomeDB::Address->new();
    $address->create($db,{street     => $street,
                           city       => $city,
                           postal_code=> $pc,
                           region_id  => $province} );
    
}

or this one for an update;

sub update_address {
    my $self   = shift;
    my ($db,$address_id,$update_hash) = _@;
   
    my $address = SomeDB::Address->new();
    $address->add_condition({left=>{name=>id},
                             right=>{value=>$address_id}});
                             
    $address->update($db,$update_hash );
        
    
}

  

METHODS
All four of the CRUD methods use the same API pattern

  $da->create($db, $container, $opt);
  $da->update($db, $container, $opt);
  $da->delete($db, $container, $opt);
  $da->retrieve($db, $container, $opt);

  $db 
  An instanated database object of some form, say a DBI handle ($dbh) or a MongoDB client ($client). 
  Whatever is pass in must be compatiable with an installed DAD.
  $container
  A HASH referance that is used to pass data into and out of the DAD. 
  $ops
  A HASH referance of options that can be passed down to the DAD.
  

create
  
  
  my $new_address = 
     $da->create($dbh, {street     => $street,
                        city       => $city,
                        postal_code=> $pc,
                        region_id  => $province}, $opt);
                     
This method will create a new record on the underlying database matching the passed in hash-keys with the 'elements' found on the DA.
The underlying DAD will a HASH ref of the orignal data and any creation info the DAD may add in.

retrieve

   my $address = $da->retrieve($dbh, {}, $opt);

update

delete

add_condition
add_element
add_filter
add_gather
add_link
add_sort

no_create
no_retrieve
no_update
no_delete
retrieve_only
update_requires_condition
delete_requires_condition


view
elements
dynamic_elements

condtions
dynamic_condtions

links
dynamic_links

sorts
dynamic_sorts

gathers
dynamic_gathers

filters
dynamic_filters
