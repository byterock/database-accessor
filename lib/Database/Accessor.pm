    
   {

        package 
           Database::Accessor::Roles::Common;

        use Moose::Role;
        with qw(Database::Accessor::Types);
        use MooseX::AlwaysCoerce;
        use namespace::autoclean;
     
       has [
        qw(da_compose_only
           da_no_effect
           da_raise_error_off
         )
        ] => (
          is          => 'rw',
          isa         => 'Bool',
          default     => 0,
          traits => ['ENV'],
        );
        
        has da_warning => (
            is  => 'rw',
            isa => 'Int',
            default     => 0,
            traits => ['ENV'],
        );
        
        has view => (
            is  => 'ro',
            isa => 'View',
            required => 1
        );

        has elements => (
            isa => 'ArrayRefofElements',
            is  => 'ro',
            traits  => ['Array'],
            handles => { element_count => 'count',
                         _get_element_by_name  => 'first',
                       },
            default => sub { [] },
        );
        has conditions => (
            isa => 'ArrayRefofConditions',
            is  => 'ro',
            traits  => ['Array'],
            handles => { condition_count => 'count', },
            default => sub { [] },
        );

        has links => (
            is  => 'ro',
            isa => 'ArrayRefofLinks',
            traits  => ['Array'],
            handles => { link_count => 'count', },
            default => sub { [] },
        );

        has gather => (
            is  => 'ro',
            isa => 'Gather|Undef',

        );
        sub gather_count{
            my $self = shift;
            return 1
              if $self->gather();
        }

        has sorts => (
            is  => 'ro',
            isa => 'ArrayRefofElements',
            traits  => ['Array'],
            handles => { sort_count => 'count', },
            default => sub { [] },
        );
       
       sub get_element_by_name {
           my $self = shift;
           my ($name) = @_;
           my $found = $self->_get_element_by_name(sub {$_->name eq $name});
           return $found;
       }
       
       1;
       
    }    
package Database::Accessor;

    use Moose;
    with qw(Database::Accessor::Types
            Database::Accessor::Roles::Common);
    use Moose::Util qw(does_role);
    use Database::Accessor::Constants;
    use MooseX::MetaDescription;
    use MooseX::AccessorsOnly;
    use MooseX::AlwaysCoerce;
    use MooseX::Constructor::AllErrors;
    use MooseX::Privacy;
    use MooseX::Attribute::ENV;
    use Scalar::Util qw(blessed);

    # use Carp;
    use Data::Dumper;
    use File::Spec;
    use namespace::autoclean;

    # ABSTRACT: CRUD Interface for any DB
    # Dist::Zilla: +PkgVersion

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
          map { File::Spec->catdir( $_, 'Database', 'Accessor', 'Driver' ) }
          @INC;

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
                $file =~ s{\.pm$}{};    # remove .pm extension
                $dir  =~ s/\\/\//gi;
                $dir =~ s/^.+Database\/Accessor\/Driver\///;

                my $_package =
                  join '::' => grep $_ => File::Spec->splitdir($dir);

                # # untaint that puppy!
                my ($package) =
                  $_package =~ /^([[:word:]]+(?:::[[:word:]]+)*)$/;

                my $classname = "";

                if ($package) {
                    $classname = join '::', 'Database', 'Accessor', 'Driver',
                      $package, $file;
                }
                else {
                    $classname = join '::', 'Database', 'Accessor', 'Driver',
                      $file;
                }

# eval qq{package                   # hide from PAUSE
# Database::Accessor::Driver::_firesafe;    # ensures that the TRD is present in the path
# require $classname;    # load the driver
# };

                eval "require $classname";

                if ($@) {
                    my $err = substr( $@, 0, index( $@, ' at ' ) );
                    my $advice =
"Database/Accessor/Driver/$file ($classname) may not be an Database Accessor Driver (DAD)!\n\n";
                    warn(
"\n\n Warning Load of Database/Accessor/Driver/$file.pm failed: \n   Error=$err \n $advice\n"
                    );
                    next;
                }
                else {
                    next
                      unless (
                        does_role(
                            $classname, 'Database::Accessor::Roles::Driver'
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

    has available_drivers => (
        isa         => 'ArrayRef',
        is          => 'rw',
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 },
        documentation =>
"Returns an ArrayRef of HasRefs the DADs that are installed. The keys in the HashRef are 'DAD=>DAD name,class=>the DB class,ver=>the DAD Version'"
    );

    has no_create => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Attempt to use create with no_create flag on!",
            not_in_DAD => 1
        }
    );

    has no_retrieve => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Attempt to use retrieve with no_retrieve flag on!",
            not_in_DAD => 1
        }
    );
    has no_update => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Attempt to use update with no_update flag on!",
            not_in_DAD => 1
        }
    );
    has no_delete => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Attempt to use delete with no_delete flag on!",
            not_in_DAD => 1
        }
    );
    has retrieve_only => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 }

    );

    has result => (
        is          => 'rw',
        isa         => 'Database::Accessor::Result|Undef',
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 }

    );
    # has [
        # qw(da_compose_only
           # da_no_effect
           # da_warning           
          # )
      # ] => (
        # is          => 'rw',
        # isa         => 'Bool',
        # default     => 0,
        # traits => ['ENV'],
      # );
      has [
        qw(all_elements_present
          )
      ] => (
        is          => 'rw',
        isa         => 'Bool',
        default     => 0,
        traits      => ['ENV', 'MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 }
      );


    has [
        qw(update_requires_condition
          delete_requires_condition
          )
      ] => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 1,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 }
      );

    has dynamic_conditions => (
        isa      => 'ArrayRefofConditions',
        traits   => ['Array','MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 },
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            reset_conditions        => 'clear',
            add_condition           => 'push',
            dynamic_condition_count => 'count',
        },
    );

    has dynamic_links => (
        isa      => 'ArrayRefofLinks',
        traits   => ['Array','MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 },
        is       => 'rw',
        default  => sub { [] },
        init_arg => undef,
        handles  => {
            reset_links        => 'clear',
            add_link           => 'push',
            dynamic_link_count => 'count',
        },
    );


    has dynamic_gather => (
        isa      => 'Gather|Undef',
        traits   => ['MooseX::MetaDescription::Meta::Trait'],
        description => { not_in_DAD => 1 },
        is       => 'rw',
    );

    sub add_gather {
      my $self = shift;
      my ($gather) = @_;
      $self->dynamic_gather($gather);
    }
    sub reset_gather {
      my $self = shift;
      $self->dynamic_gather(undef);
      
    }
    
    sub dynamic_gather_count{
       my $self = shift;
       return 1
         if $self->dynamic_gather();
    }
    
    # has dynamic_filters => (
        # isa      => 'ArrayRefofConditions',
        # traits   => ['Array','MooseX::MetaDescription::Meta::Trait'],
        # description => { not_in_DAD => 1 },
        # is       => 'rw',
        # default  => sub { [] },
        # init_arg => undef,
        # handles  => {
            # reset_filters        => 'clear',
            # add_filter           => 'push',
            # dynamic_filter_count => 'count',
        # },
    # );
    # has sorts => (
        # is      => 'ro',
        # isa     => 'ArrayRefofElements',
        # default => sub { [] },

    # );

    has dynamic_sorts => (
        isa         => 'ArrayRefofElements',
        traits      => [ 'Array', 'MooseX::MetaDescription::Meta::Trait' ],
        description => { not_in_DAD => 1 },
        is          => 'rw',
        default     => sub { [] },
        init_arg    => undef,
        handles     => {
            reset_sorts        => 'clear',
            add_sort           => 'push',
            dynamic_sort_count => 'count',
        },
    );
    
    has _parens_are_open => (
        traits  => ['Counter'],
        is      => 'rw',
        default => 0,
        isa     => 'Int',
        handles => {
            _inc_parens   => 'inc',
            _dec_parens   => 'dec',
            _reset_parens => 'reset'
        }
    );


    sub _create_or_update {
        my $self = shift;
        my ( $action, $conn, $container, $opt ) = @_;

        my $message =
            "Usage: Database::Accessor->"
          . lc($action)
          . "( Class , Hash-Ref||Class||Array-Ref of [Hash-ref||Class], Hash-Ref); ";

        if ( ref($container) eq "ARRAY" ) {

            die $message .= "The \$container Arry-Ref cannot be empty"
              if ( !scalar( @{$container} ) );

            my @bad =
              grep( !( ref($_) eq 'HASH' or blessed($_) ), @{$container} );
            die $message
              . " The \$container 'Array-Ref' must contain only Hash-refs or Classes"
              if ( scalar(@bad) );

        }
        else {

            die $message .=
"The \$container parameter must be either a Hash-Ref, a Class or an Array-ref of Hash-refs and or Classes"
              if ( !( ref($container) eq 'HASH' or blessed($container) ) );

            die $message .= "The \$container Hash-Ref cannot be empty"
              if ( ref($container) eq 'HASH' and !keys( %{$container} ) );

        }

        $self->_all_elements_present( $message, $container )
          if ( $self->all_elements_present );

        return $self->_execute( $action, $conn, $container, $opt );
    }
    sub create {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        die( $self->meta->get_attribute('no_create')->description->{message} )
          if ( $self->no_create() );
        return $self->_create_or_update( Database::Accessor::Constants::CREATE,
            $conn, $container, $opt );

    }

    sub update {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        die( $self->meta->get_attribute('no_update')->description->{message} )
          if ( $self->no_update() );

        $self->_need_condition( Database::Accessor::Constants::UPDATE,
            $self->update_requires_condition()
        );
        return $self->_create_or_update( Database::Accessor::Constants::UPDATE,
            $conn, $container, $opt );
    }

    sub retrieve {
        my $self = shift;
        my ( $conn, $opt ) = @_;
        die( $self->meta->get_attribute('no_retrieve')->description->{message} )
          if ( $self->no_retrieve() );
        my $container = {};
        return $self->_execute( Database::Accessor::Constants::RETRIEVE,
            $conn, $container, $opt );

    }

    sub delete {
        my $self = shift;
        my ( $conn, $opt ) = @_;
        die( $self->meta->get_attribute('no_delete')->description->{message} )
          if ( $self->no_delete() );
          
        $self->_need_condition( Database::Accessor::Constants::DELETE,
            $self->delete_requires_condition()
        );
        
        my $container = {};
        return $self->_execute( Database::Accessor::Constants::DELETE,
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
    
    
    sub _all_elements_present {
        my $self = shift;
        my ( $message, $container ) = @_;

        if ( ref($container) eq "ARRAY" ) {
            foreach my $sub_container ( @{$container} ) {
                $self->_all_elements_present($sub_container);
            }
        }
        else {
            foreach my $element ( $self->elements() ) {

                next
                  if ( !( $element->view )
                    and $element->view ne $self->view->name() )
                  ;    #ignore elements on other view (joins etc)

                if ( ref($container) eq 'HASH' ) {
                    die $message
                      . "The Hash-Ref \$container must have a "
                      . $element->name
                      . " key present!"
                      if ( !exists( $container->{ $element->name } ) );
                }
                else {
                    die $message
                      . "The Class \$container must have a "
                      . $element->name
                      . " attribute!"
                      if ( !( $container->can( $element->name ) ) );
                }
            }
        }
    }
    private_method check_options => sub {
        my $self = shift;
        my ($action,$opt) = @_;
        die "The Option param for $action must be a Hash-Ref"
           if (ref($opt) ne 'HASH');
           
        foreach my $key (keys(%{$opt})){
             die "The $key option param for $action must be a "
                 .Database::Accessor::Constants::OPTIONS->{$key}
                 ."-Ref not a "
                 . ref($opt->{$key})
             if(exists(Database::Accessor::Constants::OPTIONS->{$key})
                and ref($opt->{$key}) ne Database::Accessor::Constants::OPTIONS->{$key});
        }
    };

    private_method _check_view => sub {
        my $self = shift;
        my ($element) = @_;
 
        if (ref($element) eq 'Database::Accessor::Element'){
          unless ( $element->view() ) {
              $element->view( $self->view->name() );
              $element->view( $self->view()->alias() )
                if ( $self->view()->alias() );
          }
       }
       elsif (ref($element) eq 'Database::Accessor::Condition'){
           
           $self->_check_view($element->predicates->right);
            $self->_check_view($element->predicates->left);
       }
        else {
           return 
              unless(does_role($element,"Database::Accessor::Roles::Comparators"));
            map( $self->_check_view($_),@{$element->left})              
              if (ref($element->left) eq "ARRAY");
            map( $self->_check_view($_),@{$element->right})
               if (ref($element->right) eq "ARRAY");
            $self->_check_view($element->right);
            $self->_check_view($element->left);
        }

    };

    private_method get_dad_elements => sub {
        my $self = shift;
        my ($action,$opt) = @_;
        my @allowed;
        foreach my $element (@{$self->elements()} ) {
            if (ref($element) eq 'Database::Accessor::Param'){
                push(@allowed,$element)
                  if (  $action eq Database::Accessor::Constants::RETRIEVE);                 
                next;
            }
            if (ref($element) eq 'Database::Accessor::Param'){
                push(@allowed,$element)
                  if (  $action eq Database::Accessor::Constants::RETRIEVE);                 
                next;
            }
            next 
              if (exists($opt->{only_elements})
                  and !exists($opt->{only_elements}->{$element->name}));
             next
              if (
                $action eq Database::Accessor::Constants::CREATE
                and (  $element->only_retrieve
                    or $element->no_create )
              );

            next
              if (
                $action eq Database::Accessor::Constants::UPDATE
                and (  $element->only_retrieve
                    or $element->no_update )
              );

            next
              if (  $action eq Database::Accessor::Constants::RETRIEVE
                and $element->no_retrieve );

            next
              if (
                (  ref($element) eq 'Database::Accessor::Element'
                   and $element->view ne $self->view->name
                   and $self->view->alias
                   and $element->view ne $self->view->alias
                )
                and (  $action eq Database::Accessor::Constants::CREATE
                    or $action eq Database::Accessor::Constants::UPDATE )
              );
            push( @allowed, $element );
        }
        return \@allowed;
    };
    
    private_method _parentheses_check => sub {
        my $self = shift;
        my ($action) = @_;
        $self->_reset_parens();
        my @items;
        push( @items,
            @{ $self->conditions },
            @{ $self->dynamic_conditions },
            # @{ $self->links },
            # @{ $self->dynamic_links },
            @{ $self->sorts },
            @{ $self->dynamic_sorts },
            @{ $self->elements } );
        foreach my $link ((@{ $self->links },@{ $self->dynamic_links })){
            push(@items,$link->conditions); 
        }    
        if ( $self->gather() || $self->dynamic_gather()  ) {
            push(
                @items,
                (
                    @{ $self->gather->conditions }, @{ $self->gather->elements }, @{ $self->dynamic_gather->conditions }, @{ $self->dynamic_gather->elements }
                )
            );
        }
         
        foreach my $condition (@items) {
            if (ref($condition) eq 'ARRAY'){
                map( $self->_check_view($_),@{$condition});
                            }
            else {
               $self->_check_view($condition);
           }
        }

        die " Database::Accessor->"
          . lc($action)
          . " Unbalanced parentheses in your conditions and dynamic_conditions. Please check them!"
          if ( $self->_parens_are_open() );

    };


    private_method _execute => sub {
        my $self = shift;
        my ( $action, $conn,$container , $opt ) = @_;
        
        
        my $usage = "(\$connection,\$options); ";
        $usage = "(\$connection,\$container,\$options); "
          if ( $action eq Database::Accessor::Constants::CREATE 
            or $action eq Database::Accessor::Constants::UPDATE);
            
        die "Usage: Database::Accessor->"
          . lc($action)
          . $usage 
          . "You must supply a \$connection class"
             if ( !blessed($conn) );
        my $drivers = $self->_ldad();
        my $driver  = $drivers->{ ref($conn) };

        die " Database::Accessor->"
          . lc($action)
          ." No Database::Accessor::Driver loaded for "
          . ref($conn)
          . " Maybe you have to install a Database::Accessor::Driver::?? for it?"
          unless ($driver);

        $self->check_options($action, $opt )
          if ($opt);
          
        $self->_parentheses_check($action);
        my $gather = undef;
        if ($action eq Database::Accessor::Constants::RETRIEVE and ($self->gather() || $self->dynamic_gather()) ){
           my @elements;
           my @conditions;
           if ($self->gather()) {               
              push(@elements,@{$self->gather()->elements()});
              push(@conditions,@{$self->gather()->conditions});
           }
           if ($self->dynamic_gather()){
              push(@elements, @{$self->dynamic_gather()->elements()});
              push(@conditions,@{$self->dynamic_gather()->conditions});
           }
                     
           $gather = Database::Accessor::Gather->new({elements=>\@elements,
                                                      conditions=>\@conditions});
        }
        
        my $dad = $driver->new(
            {
                view               => $self->view,
                elements           => ($action ne Database::Accessor::Constants::DELETE) ? $self->get_dad_elements($action,$opt):[],
                conditions         => [@{$self->conditions},@{$self->dynamic_conditions}],
                links              => [@{$self->links},@{$self->dynamic_links}],
                gather             => $gather,
                sorts              => ($action eq Database::Accessor::Constants::RETRIEVE) ? [@{ $self->sorts }  ,@{ $self->dynamic_sorts   }] : [],
                da_compose_only    => $self->da_compose_only,
                da_no_effect       => $self->da_no_effect,
                da_warning         => $self->da_warning,
                da_raise_error_off => $self->da_raise_error_off,
                
            }
        );
        
        my $result = Database::Accessor::Result->new(
            { DAD => $driver, operation => $action } );
        $dad->execute( $result, $action, $conn, $container, $opt );
        $self->result($result);
        return 0
          if ( $result->is_error() );
        return 1;

    };

# DANote:  please fill in a new section for Options starting with DA_raw_query and include a blurb about the nameing convention
# DADNote: The DAD will have to check for any DA_ flags and take the apporate action

    1;

    { 
        package 
           Database::Accessor::Result;
        use Moose;
       
        has is_error => (
            is          => 'rw',
            isa         => 'Bool',
            default     => 0,
        );
        
        has error => (
            is       => 'rw',
            isa      => 'Str|Object|Undef',
        );
        
        has effected => (
            isa         => 'Int|Undef',
            is          => 'rw'
        );
        
        has set => (
            isa    => 'ArrayRef|Undef',
            is          => 'rw'
        );
        
        has query => (
            is       => 'rw',
            isa      => 'Str',
        );
        
        has params => (
            is       => 'rw',
            isa      => 'ArrayRef|ArrayRefofParams',
            traits  => ['Array'],
            handles => { param_count => 'count',
                         add_param   => 'push' },
            default => sub { [] },
        );
        
        has DAD => (
            is       => 'ro',
            isa      => 'Str',
        );
        
        has DB => (
            is       => 'rw',
            isa      => 'Str',
        );
        
        has operation =>( is       => 'ro',
                          isa      => 'Str',
        )
        
    }
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
           Database::Accessor::Roles::Element;
        use Moose::Role;
        use namespace::autoclean;


    has [
            qw(no_create
              no_retrieve
              no_update
              only_retrieve
              )
          ] => (
            is      => 'rw',
            isa     => 'Bool',
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
            isa      => 'Expression|Param|Element|Function|ArrayRefofParams|ArrayRefofElements|ArrayRefofExpressions',
            required => 1,
            coerce   => 1,
        );
        has right => (
            is => 'rw',
            isa =>
'Element|Param|Function|Expression|ArrayRefofParams|ArrayRefofElements|ArrayRefofExpressions',
            coerce   => 1,
        );

        has open_parentheses => (

            is      => 'rw',
            isa     => 'Bool',
            default => 0,
            alias   => [qw(open open_paren)]

        );

        has close_parentheses => (
            is      => 'rw',
            isa     => 'Bool',
            default => 0,
            alias   => [qw(close close_paren)]

        );

        1;
    }

    # {

        # package 
           # Database::Accessor::Roles::PredicateArray;
        # use Moose::Role;
        # use MooseX::Aliases;
        # use namespace::autoclean;

        # has predicates => (
            # traits  => ['Array'],
            # is      => 'rw',
            # isa     => 'ArrayRefofPredicates',
            # coerce  => 1,
            # alias   => 'conditions',
            # handles => { predicates_count => 'count', },
        # );
        # 1;
    # }
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
        with qw(Database::Accessor::Roles::Alias
                Database::Accessor::Roles::Element );

        has '+name' => ( required => 1 );

        has 'view' => (

            is    => 'rw',
            isa   => 'Str',
            alias => 'table'

        );

        has [
            qw(is_identity
              )
          ] => (
            is      => 'rw',
            isa     => 'Bool',
#            default => 0,
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
            isa     => 'Operator|Undef',
            default => undef
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
            isa   => 'Str|Undef|ArrayRef|Database::Accessor',
            alias => 'param',
        );

        1;
    }

    {

        package 
           Database::Accessor::Function;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::Comparators
                Database::Accessor::Roles::Element);

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
        with qw(Database::Accessor::Roles::Comparators
                Database::Accessor::Roles::Element
                );

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
        has predicates => (
            is      => 'rw',
            isa     => 'Predicate',
            coerce  => 1,
            alias   => 'conditions',
        );

        1;
    }
    {
       package 
           Database::Accessor::Gather;
        use Moose;
        extends 'Database::Accessor::Base';
       
        has elements => (
            isa => 'ArrayRefofElements',
            is  => 'rw',
            traits  => ['Array'],
            handles => { element_count => 'count',
                       },
            required=>1,
        );
        has conditions => (
            isa => 'ArrayRefofConditions',
            is  => 'rw',
            traits  => ['Array'],
            handles => { condition_count => 'count', },
            default => sub { [] },
        );
        1;
    }
    {

        package 
           Database::Accessor::Link;
        use Moose;
        extends 'Database::Accessor::Base';
       
               has conditions => (
            isa => 'ArrayRefofConditions',
            is  => 'ro',
            traits  => ['Array'],
            handles => { condition_count => 'count', },
            default => sub { [] },
        );

        1;
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
           Database::Accessor::Roles::Driver;

        use Moose::Role;
        with qw(Database::Accessor::Types
          Database::Accessor::Roles::Common);
        use namespace::autoclean;
        requires 'DB_Class';
        requires 'execute';

        has params => (
            is => 'rw',
            isa =>'ArrayRef|ArrayRefofParams',
            traits  => ['Array'],
            handles => { param_count => 'count',
                         add_param   => 'push' },
            default => sub { [] },
        );
        
        sub da_warn {
           my $self       = shift;
           my ($package, $filename, $line) = caller();
           my ($sub,$message) =  @_;
           warn("$package->$sub(), line:$line, $message");
           
        }
       # has [
        # qw(da_compose_only
           # da_no_effect
           # da_warning
          # )
        # ] => (
          # is          => 'ro',
          # isa         => 'Bool',
        # );
        
        # has view => (
            # is  => 'ro',
            # isa => 'View',
        # );

        # has elements => (
            # isa => 'ArrayRefofElements',
            # is  => 'ro',
            # traits  => ['Array'],
            # handles => { element_count => 'count', },
        # );
        # has conditions => (
            # isa => 'ArrayRefofConditions',
            # is  => 'ro',
        # );

        # has links => (
            # is  => 'ro',
            # isa => 'ArrayRefofLinks',
        # );

        # has gathers => (
            # is  => 'ro',
            # isa => 'ArrayRefofElements',

        # );
        # has filters => (
            # is  => 'ro',
            # isa => 'ArrayRefofConditions',
        # );

        # has sorts => (
            # is  => 'ro',
            # isa => 'ArrayRefofElements',

        # );
        # # has dynamic_elements => (
            # # isa     => 'ArrayRefofElements',
            # # is      => 'ro',
            # # default => sub { [] },
        # # );

        # has dynamic_conditions => (
            # is      => 'ro',
            # isa     => 'ArrayRefofConditions',
            # default => sub { [] },

        # );

        # has dynamic_links => (
            # is      => 'ro',
            # isa     => 'ArrayRefofLinks',
            # default => sub { [] },

        # );

        # has dynamic_gathers => (
            # is      => 'ro',
            # isa     => 'ArrayRefofElements',
            # default => sub { [] },

        # );
        # has dynamic_filters => (
            # is      => 'ro',
            # isa     => 'ArrayRefofConditions',
            # default => sub { [] },

        # );
        # has dynamic_sorts => (
            # is      => 'ro',
            # isa     => 'ArrayRefofElements',
            # default => sub { [] },

        # );
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
  Have a Key-Pair Non SQL DB and don't know how to get the data out.
  
  Well Database::Accessor is for you!

=head1 SEE ALSO

Database::Accessor::Manual
Database::Accessor::Tutorial
Database::Accessor::Driver::WritersGuide
Database::Accessor::Driver::SQL

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
                                 open_parentheses =>1,},
                     { condition      =>'AND',
                       left           =>{ name  =>'Last_name',
                                          view  =>'People'},
                       right          =>{ value =>'Doe'},
                       operator       => '=',
                       close_parentheses=> 1
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

Though it can be used directly it is best used within another abstracted class, as in below;

package SomeDB::Address;
use parent qw(Database::Accessor);

SomeDB::Address->new({
                view=>'address',
             elements=>[{name=> 'id'},
                        {name=> 'street'},
                        {name=> 'city'},
                        {name=> 'postal_code'},
                        {name=> 'region_id'},
                        {name=> 'country_id'},
                        {name=> 'time_zone_id'}]});
                        
1;


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

new


All four of the CRUD methods use the same API pattern

  $da->create($db, $container, $opt);
  $da->update($db, $container, $opt);
  $da->delete($db, $container, $opt);
  $da->retrieve($db, $container, $opt);

  $db 
  An instanated database object of some form, say a DBI handle ($dbh) or a MongoDB client ($client). 
  Whatever is pass in must be compatiable with an installed DAD.
  $container
  A HASH or ARRAY referance or a blessed class that is used to pass data into and out of the DAD. It is always returned from the underlying DAD.
  $ops
  A HASH referance of options that can be passed down to the DAD.  Varies by DAD.
  

create
  
  my $new_address = 
     $da->create($dbh, {street     => $street,
                        city       => $city,
                        postal_code=> $pc,
                        region_id  => $province}, $opt);
                     
This method will create a new record on the underlying DAD database.  It will attempt to match the 'KEYS' of the passed in hash ref with the 'elements' found on the DA.
The underlying DAD will return the original HASH or ARRAY ref with creation info the undelying DAD may add in.

retrieve

   $address_da->add_condition({left=>{name=>id},
                             right=>{value=>123}});
   my $address = $da->retrieve($dbh, {}, $opt);

This method will return the requested records from the underlying DAD.

update

   $address_da->add_condition({left=>{name=>id},
                             right=>{value=>123}});
   my $address = $da->retrieve($dbh, {city=>22,
                                      phone=>1234567890}, $opt);

This method will update the matching records in the underlying DAD with the passed in hash. 
delete


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
add_element

conditions
dynamic_conditions
add_condition

links
dynamic_links
add_link
Reteive

sorts
dynamic_sorts
add_sort

gathers
dynamic_gathers
add_gather

filters
dynamic_filters
add_filter

available_drivers
Delete
