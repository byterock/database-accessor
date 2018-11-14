    
   {

        package 
           Database::Accessor::Roles::Common;

        use Moose::Role;
        with qw(Database::Accessor::Types);
        use MooseX::AlwaysCoerce;
        use MooseX::Enumeration;
        use namespace::autoclean;
   
        has da_result_set => (
            traits    => ["Enumeration"],
            is        => "rw",
            enum      => [qw/ ArrayRef HashRef Class JSON /],
            handles   => 1,
            default   => 'ArrayRef'
        );
      
        has da_result_class => (
            is  => 'rw',
            isa => 'Str|Undef',
            default     => undef,
        );         has da_key_case => (
            traits    => ["Enumeration"],
            is        => "rw",
            enum      => [qw/ Native Lower Upper /],
            handles   => 1,
            default   => 'Lower'
        );  
       has [
        qw(da_compose_only
           da_no_effect
           da_raise_error_off
           da_suppress_view_name
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
                         _get_element_by_lookup => 'first'
                       },
            required=>1,
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
            isa => 'ArrayRefofParams',
            traits  => ['Array'],
            handles => { sort_count => 'count', },
            default => sub { [] },
            documentation => "sort"
        );
       
       sub get_element_by_name {
           my $self = shift;
           my ($name) = @_;
           my $found = $self->_get_element_by_name(sub { if (!defined($_->name)) {return 0} $_->name eq $name});
           return $found;
       }
       
       sub get_element_by_lookup {
           my $self = shift;
           my ($lookup) = @_;
           my $found = $self->_get_element_by_lookup(sub { if (ref($_) ne 'Database::Accessor::Element' or !defined($_->_lookup_name)) {return 0} $_->_lookup_name eq $lookup});
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
    use Carp 'confess';
    use Data::Dumper;
    $Data::Dumper::Terse = 1;
    use File::Spec;
    use namespace::autoclean;
    
    # ABSTRACT: CRUD Interface for any DB
    # Dist::Zilla: +PkgVersion

    around BUILDARGS => sub {
        my $orig  = shift;
        my $class = shift;
        my $ops   = shift(@_);
        my ($package, $filename, $line, $subroutine) = caller(3);
        if ( $ops->{retrieve_only} ) {
            $ops->{no_create}   = 1;
            $ops->{no_retrieve} = 0;
            $ops->{no_update}   = 1;
            $ops->{no_delete}   = 1;
        }
       # return $class->$orig($ops);
        my $instance;        eval{ $instance = $class->$orig($ops)};
        if ($@) {                        if (exists($ENV{'DA_ALL_ERRORS'}) and $ENV{'DA_ALL_ERRORS'} ){
                die $@;
            }
            else {
                my @errors;
                my $error_msg;
                my $error;
                if ($@->missing()) {
                    foreach my $error ($@->missing()){
                        # warn(Dumper($error->attribute->documentation));
                        push(@errors,sprintf('%s%s'
                                              ,($error->attribute->documentation) ?  $error->attribute->documentation."->" : ""
                                             ,$error->attribute->name())); 
                    }
                    
                    $error = "The following Attribute"
                             .$class->_is_are_msg(scalar(@errors))
                             ."required: ("
                             .join(",",@errors)
                             .")\n";
                }
                if ($@->invalid()) {
                    @errors= ();
                    foreach my $error ($@->invalid()){
                      push(@errors, sprintf("'%s%s' Constraint: %s"
                                           ,($error->attribute->documentation) ?  $error->attribute->documentation."->" : ""
                                           ,$error->attribute->name
                                           ,$error->attribute->type_constraint->get_message($error->data) 
                                           ));
                    }
                    $error .= "The followling Attribute"
                             .$class->_did_do_msg(scalar(@errors))
                             ." not pass validation: \n"
                             .join("\n",@errors)
                             ;
                    
                    
                }
               
                my $misc = "Database::Accessor new Error:\n"
                    . $error
                    . "\nWith constructor hash:\n"
                    . Dumper($ops);
                my $die = MooseX::Constructor::AllErrors::Error::Constructor->new(
                     caller => [$package, $filename, $line, $subroutine ],
                 );
                $die->add_error(MooseX::Constructor::AllErrors::Error::Misc->new({message =>$misc}));
                die $die;
            }
         }
         else {
             return $instance;
         }
    };

sub _is_are_msg {
    my $self = shift;
    my ($count) = @_;
    return "s are "
      if ($count >1);
    return " is "
}    
    
sub _did_do_msg {
    my $self = shift;
    my ($count) = @_;
    return "s do "
      if ($count >1);
    return " did "
}   
    # sub _new_misc_error {
        # my $self = shift;
        # my ($error,$line,$filename) = @_;
            # my $misc = MooseX::Constructor::AllErrors::Error::Misc->new({message =>"Database::Accessor New Error: "
                    # . $error->message
                    # . " at Line "
                    # . $line
                    # . " file: "
                    # . $filename});

        # return $misc;    # }
    
    sub BUILD {
        my $self = shift;
        my $dad  = {};
        map( { $self->_loadDADClassesFromDir( $_, $dad ) }
          grep { -d $_ }
          map { File::Spec->catdir( $_, 'Database', 'Accessor', 'Driver' ) }
          @INC
        );

        if ( $self->retrieve_only ) {
            foreach my $flag (qw(no_create no_update no_delete)) {
                my $field = $self->meta->get_attribute($flag);
                $field->description->{message} =
                  "No Create, Update or Delete with retrieve_only flag on";
            }
        }

        my @items;
        push( @items,
            @{ $self->conditions },
            @{ $self->sorts },
             @{ $self->elements } );

        foreach my $link (@{ $self->links }){
              push(@items,$link->conditions);
        } 
       
        push(@items,(@{ $self->gather->conditions }, @{ $self->gather->elements }))
          if ( $self->gather());
        push(@items,@{ $self->gather->view_elements })
            if ($self->gather() and $self->gather->view_elements);

        $self->_elements_check(\@items,"new","static");       
        my %saved = %$self;
        tie(
            %$self,
            "MooseX::AccessorsOnly",
            sub {
                my ( $who, $how, $what ) = @_;
                confess
"Database::Accessor Error: Attempt to access '$what' directly at $who!";
            }
        );
        %$self = %saved;
        
    }

    sub _loadDADClassesFromDir {
        my $self = shift;
        my ( $path, $dad ) = @_;
        # $dad = {}
        # if ( ref($dad) ne 'HASH' );
        opendir( DIR, $path ) or die "Database::Accessor BUILD Error: Unable to open $path: $! during load of DADs";

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
"Database/Accessor/Driver/$file ($classname) may not be an Database::Accessor::Driver (DAD)!\n\n";
                    warn(
"\n\n Database::Accessor BUILD Warning: Load of Database/Accessor/Driver/$file.pm failed: \n   Error=$err \n $advice\n"
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

    has only_elements => (
        isa         => 'HashRef',
        traits      => ['Hash','MooseX::MetaDescription::Meta::Trait'],
        is          => 'rw',
        description => { not_in_DAD => 1 },
        default => sub { {} },
        handles   => {
            only_elements_is_empty => 'is_empty',
            only_elements_exists   => 'exists'
        },
    );
    has no_create => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Database::Accessor create  Error: Attempt to use create with no_create flag on!",
            not_in_DAD => 1
        }
    );

    has no_retrieve => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Database::Accessor retrieve Error: Attempt to use retrieve with no_retrieve flag on!",
            not_in_DAD => 1
        }
    );
    has no_update => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Database::Accessor update Error: Attempt to use update with no_update flag on!",
            not_in_DAD => 1
        }
    );
    has no_delete => (
        is          => 'ro',
        isa         => 'Bool',
        default     => 0,
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        description => {
            message    => "Database::Accessor delete Error: Attempt to use delete with no_delete flag on!",
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

    has _identity_index => (
        is          => 'rw',
        isa         => 'Int|Undef',
        default     => undef,
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

    has default_condition => (
        is          => 'rw',
        isa         => 'Operator',
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        default     => Database::Accessor::Constants::AND(),
        description => { not_in_DAD => 1 }

    );



    has default_operator => (
        is          => 'rw',
        isa         => 'Operator',
        traits      => ['MooseX::MetaDescription::Meta::Trait'],
        default     => '=',
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
       # trigger   => \&_check_elements_present
    );

    # sub _check_elements_present {
        # my ( $self, $child ) = @_;
        # my @check_elements;
                # if (ref($child) eq 'Database::Accessor::Gather'){
           # push( @check_elements, @{$child->view_elements})
             # if($child->view_elements);
        # }
        # foreach my $element (@check_elements){
            # next 
              # unless(ref($element) eq 'Database::Accessor::Element');
 
            # die( "Gather view_element "
                 # .$element->name()
                 # ." in not in the elements array! Only elements from that array can be added" )
              # unless ($self->get_element_by_name($element->name()));
        # }
    # }    
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
    
    has dynamic_sorts => (
        isa         => 'ArrayRefofParams',
        default  => sub { [] },
        traits      => [ 'Array', 'MooseX::MetaDescription::Meta::Trait' ],
        description => { not_in_DAD => 1 },
        is          => 'rw',
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


    has _add_condition => (
        traits  => ['Counter'],
        is      => 'rw',
        default => 0,
        isa     => 'Int',
        handles => {
            _inc_conditions   => 'inc',
            _dec_conditions   => 'dec',
            _reset_conditions => 'reset'
        }
    );
    sub _clean_up_container {
        my $self = shift;
        my ($message,$container) = @_;
        my @new_container = ();
        foreach my $row (@{$container}){
            my $new_row = {};
            foreach my $key (keys(%{$row})){
                my $field = $self->get_element_by_name($key);
                next
                  if ( !$field );
                next
                  if (($field->view) 
                       and ($field->view ne $self->view()->name())); 
                   # if ((($field->view) 
                    # and ($field->view ne $self->view()->name()) 
                         # or ($self->view()->alias() and ($field->view ne $self->view()->alias()))));
                $new_row->{$key} = $row->{$key};
            }
            push(@new_container,$new_row);        }
        confess($message .= "The \$container must have at least 1 element with the view="
                     .$self->view()->name()
                     ."!")
              if ( !scalar( @new_container ) );
        return \@new_container;
    }
    
    sub _create_or_update {
        my $self = shift;
        my ( $action, $conn, $container, $opt ) = @_;
        my $new_container;
        
        my $message =
            "Database::Accessor "
          . lc($action)
          ."( \$db 'Class', \$container 'Hash-Ref||Class||Array-Ref of [Hash-ref||Class]', \$options 'Hash-Ref');"
          . " Error: Incorrect Usage: ";

        if ( ref($container) eq "ARRAY" ) {

            confess($message .= "The \$container Arry-Ref cannot be empty")
              if ( !scalar( @{$container} ) );

            my @bad = grep( !( ref($_) eq 'HASH' or blessed($_) ), @{$container} );
             
            if (scalar(@bad)){
                my $count = scalar(@bad);
                $message .= " The \$container 'Array-Ref' must contain only Hash-refs or Classes. Scalar value";
                $message .= ($count <=1 ) ? " " : "s ";
                $message .=  join(',',@bad);
                $message .= ($count <= 1) ? " is" : " are";
                $message .= " not allowed in ="
                            . Dumper($container);
                confess( $message);
            }
            $new_container = $self->_clean_up_container($message,$container);
        }
        else {

            confess( $message .=
"The \$container parameter must be either a Hash-Ref, a Class or an Array-ref of Hash-refs and or Classes . \$container="
. Dumper($container) )
              if ( !( ref($container) eq 'HASH' or blessed($container) ) );

            confess( $message .= "The \$container Hash-Ref cannot be empty")
              if ( ref($container) eq 'HASH' and !keys( %{$container} ) );
              
            $new_container = shift(@{$self->_clean_up_container($message,[$container])});
        }
        
       
        $self->_all_elements_present( $message, $new_container )
          if ( $self->all_elements_present );
        return $self->_execute( $action, $conn, $new_container, $opt );
    }
    sub create {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        confess( $self->meta->get_attribute('no_create')->description->{message} )
          if ( $self->no_create() );
        return $self->_create_or_update( Database::Accessor::Constants::CREATE,
            $conn, $container, $opt );

    }

    sub update {
        my $self = shift;
        my ( $conn, $container, $opt ) = @_;

        confess( $self->meta->get_attribute('no_update')->description->{message} )
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

        confess( $self->meta->get_attribute('no_retrieve')->description->{message} )
          if ( $self->no_retrieve() );
          
        confess( "Database::Accessor retrieve Error: You must supply a da_result_class when da_result_set is Class!" )
          if ( $self->da_result_set() eq 'Class' and !$self->da_result_class() );
          
        if ($self->da_result_class()){
            eval "require ".$self->da_result_class();
            if ($@) {
                $@ =~ s /locate/locate the da_result_class file /;
                confess( $@ );
                            }        }
        my $container = {};
        return $self->_execute( Database::Accessor::Constants::RETRIEVE,
            $conn, $container, $opt );

    }

    sub delete {
        my $self = shift;
        my ( $conn, $opt ) = @_;
        confess( $self->meta->get_attribute('no_delete')->description->{message} )
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
        confess("Database::Accessor $action Error: Attempt to $action without a condition!")
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
                    confess($message
                      . "The Hash-Ref \$container must have a "
                      . $element->name
                      . " key present!")
                      if ( !exists( $container->{ $element->name } ) );
                }
                else {
                    confess($message
                      . "The Class \$container must have a "
                      . $element->name
                      . " attribute!")
                      if ( !( $container->can( $element->name ) ) );
                }
            }
        }
    }
    private_method check_options => sub {
        my $self = shift;
        my ($action,$opt) = @_;
        confess( "Database::Accessor $action Error: The Option param for $action must be a Hash-Ref")
           if (ref($opt) ne 'HASH');
           
        foreach my $key (keys(%{$opt})){
             confess( "Database::Accessor $action Error: The $key option param for $action must be a "
                 .Database::Accessor::Constants::OPTIONS->{$key}
                 ."-Ref not a "
                 . ref($opt->{$key}))
             if(exists(Database::Accessor::Constants::OPTIONS->{$key})
                and ref($opt->{$key}) ne Database::Accessor::Constants::OPTIONS->{$key});
        }
    };

    private_method _check_parentheses => sub {
        my $self = shift;
        my ($element) = @_;
        $self->_inc_parens()
             if ( $element->open_parentheses() );
           $self->_dec_parens()
             if ( $element->close_parentheses() );    };
    
    private_method _check_element => sub {
        my $self = shift;
        
        # warn("JSP _parens_are_open=".$self->_parens_are_open());
        my ($element,$action,$type) = @_;
        if (ref($element) eq 'Database::Accessor::Element'){
          unless ( $element->view() ) {
            $element->view( $self->view->name() );
          }
          $element->_lookup_name();
          # warn("DA _check_element 2 ".Dumper($element));
          # warn("DA _check_element 3 name=".$element->name()); 
          # warn("$type DA _check_element 4 name=".$element->_lookup_name()); 
          confess( "Database::Accessor $type Error: element {name=>"
                .$element->name()
                .", view=>"
                .$element->view()
                ."} not in the elements array! Only elements from that array can be added" )
            if (($type eq 'dynamic' and !$self->get_element_by_lookup($element->_lookup_name())));

        }
        elsif (ref($element) eq 'Database::Accessor::If'){
            foreach my $sub_element (@{$element->ifs()}){
                $self->_check_element($sub_element,$action,$type);
            }
        }
        elsif (ref($element) eq 'Database::Accessor::If::Then'){
            $self->_check_element($element->right,$action,$type);
            $self->_check_element($element->left,$action,$type);
            $self->_check_element($element->then,$action,$type);
            $element->condition(uc($element->condition))
              if ($element->condition() );
            $element->operator(uc($element->operator))
              if ($element->operator() );

        }
        elsif (ref($element) eq 'Database::Accessor::Condition'){
           $element->predicates->operator($self->default_operator())
             if ( !$element->predicates->operator() );
           $element->predicates->operator(uc( $element->predicates->operator));
           $element->predicates->condition($self->default_condition())
             if ( $self->_add_condition>=2 and !$element->predicates->condition() );
           $element->predicates->condition(undef)
             if ( $self->_add_condition<=1  );
           $element->predicates->condition(uc( $element->predicates->condition))
             if ($element->predicates->condition() );
           $self->_check_parentheses($element->predicates);
           $self->_check_element($element->predicates->right,$action,$type);
           $self->_check_element($element->predicates->left,$action,$type);
       }
       elsif (ref($element) eq 'ARRAY'){
           
           foreach my $sub_element (@{$element}){
               $self->_check_element($sub_element,$action,$type);
            }       }
       else {
           return 
              unless(does_role($element,"Database::Accessor::Roles::Comparators"));
         
            $self->_check_parentheses($element);            $self->_check_element($element->right,$action,$type);
            $self->_check_element($element->left,$action,$type);
       }

    };

    private_method get_dad_elements => sub {
        my $self = shift;
        my ($action,$gather) = @_;
        $self->_identity_index(-1);
        my @allowed;
        my @elements = @{$self->elements()};
        
        @elements = @{$gather->view_elements()}
          if (ref($gather) and $gather->view_elements() and $gather->view_count());

        for (my $index=0; $index < scalar(@elements); $index++) {
            my $element = $self->elements()->[$index];
            $element = $gather->view_elements()->[$index]
               if (ref($gather) and $gather->view_elements() and $gather->view_count());
               
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
              if (!$self->only_elements_is_empty() 
                  and (!$self->only_elements_exists($element->name) 
                  and !($element->alias() 
                  and $self->only_elements_exists($element->alias) )));
               
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
            
            if ( ref($element) eq 'Database::Accessor::Element' and $element->identity() ){
                if ($self->_identity_index() >=0 ){
                    confess("Database::Accessor "
                        . lc($action)
                        . " More than one element has the 'identity' attribute set. Please check your elements!");
                }
                else {                    
                    $self->_identity_index($index);                }
                            }
        }
        
        return \@allowed;
    };
    
    # private_method _elements_check => sub {
        # my $self = shift;
        # my ($action) = @_;
        # $self->_reset_parens();
        # $self->_reset_conditions(); 
        # my @items;
        # push( @items,
            # @{ $self->conditions },
            # @{ $self->dynamic_conditions },
            # @{ $self->sorts },
            # @{ $self->dynamic_sorts },
            # @{ $self->elements } );

         # foreach my $link ((@{ $self->links },@{ $self->dynamic_links })){
            # # my $view = $link->to;
            # # $self->_check_element($link->conditions,0,$view->name);
           # push(@items,$link->conditions);        # } 
       
        # push(@items,(@{ $self->gather->conditions }, @{ $self->gather->elements }))
          # if ( $self->gather());
        # push(@items,@{ $self->gather->view_elements })
           # if ($self->gather() and $self->gather->view_elements);
        # push(@items,(@{ $self->dynamic_gather->conditions }, @{ $self->dynamic_gather->elements }))
          # if ( $self->dynamic_gather());
        # push(@items,@{ $self->dynamic_gather->view_elements })
           # if ($self->dynamic_gather() and $self->dynamic_gather->view_elements);
        
            private_method _elements_check => sub {
        my $self = shift;
        my ($items,$action,$type) = @_;
        
        foreach my $item (@{$items}) {
            # warn("$type item=".Dumper($item));
            $self->_inc_conditions()
              if (ref($item) eq 'Database::Accessor::Condition');
              
                          if (ref($item) eq 'ARRAY'){
                
                                 $self->_reset_conditions();
                   # if ($type ne 'static');
                foreach my $condition (@{$item}){
                    
                    # warn("condition=".Dumper($condition));
                  $self->_inc_conditions()
                     if (ref($condition) eq 'Database::Accessor::Condition');
                  $self->_check_element($condition,$action,$type);
                }            }
            else {
               $self->_check_element($item,$action,$type);
           }
        }

        confess("Database::Accessor "
          . lc($action)
          . " Effor: Unbalanced parentheses in your "
          . $type
          ." attributes. Please check them!")
          if ( $self->_parens_are_open() );
        $self->_reset_conditions();

    };


    private_method _execute => sub {
        my $self = shift;
        my ( $action, $conn,$new_container, $opt ) = @_;
        
      
     
        my $usage = "(\$connection,\$options); ";
        $usage = "(\$connection,\$container,\$options); "
          if ( $action eq Database::Accessor::Constants::CREATE 
            or $action eq Database::Accessor::Constants::UPDATE);
            
        confess("Database::Accessor "
          . lc($action)
          . $usage 
          . "You must supply a \$connection class")
             if ( !blessed($conn) );
        my $drivers = $self->_ldad();
        my $driver  = $drivers->{ ref($conn) };

        confess("Database::Accessor "
          . lc($action)
          ." No Database::Accessor::Driver loaded for "
          . ref($conn)
          . " Maybe you have to install a Database::Accessor::Driver::?? for it?")
          unless ($driver);

        $self->check_options($action, $opt )
          if ($opt);
           
        $self->_reset_parens();
        $self->_reset_conditions(); 
        my @items;
        push( @items,
             @{ $self->dynamic_conditions },
             @{ $self->dynamic_sorts },
           );
        foreach my $link (@{ $self->dynamic_links }){
            push(@items,$link->conditions);
        } 
       
               
        push(@items,( @{ $self->dynamic_gather->elements }))
          if ( $self->dynamic_gather());
        push(@items,@{ $self->dynamic_gather->view_elements })
           if ($self->dynamic_gather() and $self->dynamic_gather->view_elements);
        push(@items,@{ $self->dynamic_gather->conditions })
           if ($self->dynamic_gather() and $self->dynamic_gather->conditions);
           
           #warn("items=".Dumper(\@items));
        $self->_elements_check(\@items,$action,"dynamic");
        

        my $gather = undef;
        if ($action eq Database::Accessor::Constants::RETRIEVE and ($self->gather() || $self->dynamic_gather()) ){
           
           my @elements;
           my @conditions;
           my @view_elements;
           if ($self->gather()) {               
              push(@elements,@{$self->gather()->elements()});
              push(@conditions,@{$self->gather()->conditions});
              push(@view_elements,@{$self->gather()->view_elements})
                if ($self->gather()->view_elements());
           }
           if ($self->dynamic_gather()){
              push(@elements, @{$self->dynamic_gather()->elements()});
              push(@conditions,@{$self->dynamic_gather()->conditions});
              push(@view_elements,@{$self->dynamic_gather()->view_elements})
                if ($self->dynamic_gather()->view_elements());
           }
           
           $gather = Database::Accessor::Gather->new({elements=>\@elements,
                                                      conditions=>\@conditions});
            $gather->view_elements(\@view_elements)
              if (@view_elements);
        }
       
        my $dad = $driver->new(
            {
                view               => $self->view,
                elements           => $self->get_dad_elements($action,$gather),
                conditions         => [@{$self->conditions},@{$self->dynamic_conditions}],
                links              => [@{$self->links},@{$self->dynamic_links}],
                gather             => $gather,
                sorts              => [@{ $self->sorts }  ,@{ $self->dynamic_sorts   }],
                da_compose_only    => $self->da_compose_only,
                da_no_effect       => $self->da_no_effect,
                da_warning         => $self->da_warning,
                da_raise_error_off => $self->da_raise_error_off,
                da_suppress_view_name=> $self->da_suppress_view_name,
                da_result_set        => $self->da_result_set,
                da_key_case          => $self->da_key_case,
                da_result_class      => $self->da_result_class,
                identity_index       => $self->_identity_index,
            }
        );
        my $result = Database::Accessor::Result->new(
            { DAD => $driver, operation => $action, in_container=>$new_container } );
        $dad->execute( $result, $action, $conn, $new_container, $opt );
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
       
               has [ qw(in_container
                 processed_container)
            ] => (
            isa    => 'ArrayRef|HashRef|Undef',
            is          => 'rw'
        );
        
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
        with (qw(Database::Accessor::Roles::Alias));
        use namespace::autoclean;


    has [
            qw(no_create
              no_retrieve
              no_update
              only_retrieve
              descending
              )
          ] => (
            is      => 'rw',
            isa     => 'Bool',
          );
          
        has '_lookup_name' => (
            is  => 'ro',
            isa => 'Str',
            lazy=>1,
            builder=>"_builder_lookup_name",
            init_arg => 'only_on_link',
        );

       sub _builder_lookup_name {
            my $self = shift;
            return $self->view.$self->name;
        }

 }
 
    {

        package 
           Database::Accessor::Roles::Comparators;
        use Moose::Role;
        use MooseX::Aliases;
        use namespace::autoclean;
        has left => (
            is       => 'rw',
            isa      => 'If|Expression|Param|Element|Function|ArrayRefofParams|ArrayRefofElements|ArrayRefofExpressions',
            required => 1,
            coerce   => 1,
        );
        has right => (
            is => 'rw',
            isa =>
'If|Element|Param|Function|Expression|ArrayRefofParams|ArrayRefofElements|ArrayRefofExpressions',
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

    {

        package 
           Database::Accessor::View;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::Alias);

        has '+name' => ( required => 1,
                         documentation => "view" );
                         
        has '+alias' => (documentation => 'view');
    }
    {

        package 
           Database::Accessor::Element;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(
                Database::Accessor::Roles::Element );
        has '+name' => ( required => 1);

        has 'view' => (

            is    => 'rw',
            isa   => 'Str',
            alias => 'table'

        );

        has 'identity' => (
            is    => 'rw',
            isa   => 'HashRef',
        );

        # has 'aggregate' => (
            # is  => 'rw',
            # isa => 'Aggregate',
        # );

        has 'predicate' => (
            is  => 'rw',
            isa => 'Predicate',
        );


        1;
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
            documentation => "conditions"
        );
        has condition => (
            is      => 'rw',
            isa     => 'Operator|Undef',
            default => undef,
            documentation => "conditions"
        );
        has '+left' => (documentation => 'conditions');
        has '+right' => (documentation => 'conditions');
        # has '+'
        1;
    }

    {

        package 
           Database::Accessor::Param;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw(Database::Accessor::Roles::Element);
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
                Database::Accessor::Roles::Element
                );

        has 'function' => (
            isa      => 'Str',
            is       => 'rw',
            required => 1,
        );

        1;
    }

    {
        package 
           Database::Accessor::If;
        use Moose;
        extends 'Database::Accessor::Base';
        with qw( Database::Accessor::Roles::Element
                );
        has '+name' => ( required => 0 );
        has 'ifs' => (
            isa         => 'ArrayRefofThens',
            is           => 'ro',
            required => 1,
            traits  => ['Array'],
            handles => { get_if => 'get',
                         if_count=> 'count' },
        );

        1;
    }
    {

        package 
           Database::Accessor::If::Then;
        use Moose;
        extends 'Database::Accessor::Predicate';
        has '+left' => ( required => 0 );
        has '+name' => ( required => 0 );
        
                has 'then' => (
            isa      => 'Expression|Param|Element|Function|If',
            is       => 'rw',
            alias => 'else'
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
            documentation => "condition"
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
            documentation => "gather"
        );
        has view_elements => (
            isa => 'ArrayRefofGroupElements',
            is  => 'rw',
            traits  => ['Array'],
            handles => { view_count => 'count',
                       },
            documentation => "gather"
        );
        has conditions => (
            isa => 'ArrayRefofConditions',
            is  => 'rw',
            traits  => ['Array'],
            handles => { condition_count => 'count', },
            default => sub { [] },
            documentation => "gather"
        );
        1;
    }
   
    {

    package 
        Database::Accessor::Link;
    use Moose;
    extends 'Database::Accessor::Base';

    sub _check_elements {
        my $self = shift;
        my ( $ops, $view_name ) = @_;
        if ( exists( $ops->{name} ) ) {
            
            $ops->{view} = $view_name
               unless($ops->{view});
            $ops->{only_on_link} = $ops->{view}.$ops->{name};
        }
        else {
            $self->_check_elements( $ops->{right}, $view_name)
              if exists( $ops->{right} );
            $self->_check_elements( $ops->{left}, $view_name )
              if exists( $ops->{left} );
        }
    }
    around BUILDARGS => sub {
        my $orig  = shift;
        my $class = shift;
        my $ops   = shift(@_);
        use Data::Dumper;
      
        my $lookup_view = $ops->{to}->{name};
        my $view_name = $ops->{to}->{name};
        $view_name = $ops->{to}->{alias}
          if ( exists( $ops->{to}->{alias} ) );
        if (exists( $ops->{conditions} )){
            foreach my $condition ( @{ $ops->{conditions} } ) {
               $class->_check_elements( $condition->{left},  $view_name );
               $class->_check_elements( $condition->{right}, $view_name);
            }
        }
      # warn("ops $class=".Dumper($ops));
        return $class->$orig($ops);
    };
    has conditions => (
        isa     => 'LinkArrayRefofConditions',
        required=> 1,
        is      => 'ro',
        traits  => ['Array'],
        handles => { condition_count => 'count', },
        # default => sub { [] },
        documentation => "links"
    );

    has to => (
        is       => 'rw',
        isa      => 'View',
        required => 1,
        alias    => [qw( view to_view )],
        documentation => "links"
    );

    has type => (
        is       => 'rw',
        isa      => 'Link',
        required => 1,
        documentation => "links"
    );
    1;
}

    # {

        # package 
           # Database::Accessor::Sort;
        # use Moose;
        # extends 'Database::Accessor::Element';
        # use namespace::autoclean;

        # has order => (
            # is      => 'rw',
            # isa     => 'Order',
            # default => Database::Accessor::Constants::ASC
        # );

        # 1;
    # }
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
        
        has identity_index => (
            is      => 'ro',
            isa     => 'Int',
            default => -1,
        );        
        sub da_warn {
           my $self       = shift;
           my ($package, $filename, $line) = caller();
           my ($sub,$message) =  @_;
           warn("$package->$sub(), line:$line, $message");
           
        }
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
Database::Accessor::Driver::DBI

=head1 SYNOPSIS

 my $da = Database::Accssor->new({
        view     => { name  => 'People'},
        elements => [{ name => 'first_name',
                       view =>'People' },
                     { name => 'last_name',
                       view => 'People' },
                     { name => 'user_id',
                       view => 'People' } ],
        conditions=>[{ left  => { name => 'First',
                                 view => 'People'},
                       right => { value    => 'Jane'},
                       operator => '=',
                       open_parentheses =>1,},
                     { left  =>{ name  =>'Last_name',
                                 view  =>'People'},
                       right =>{ value =>'Doe'},
                       operator  => '=',
                       condition =>'AND',
                       close_parentheses => 1
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

Database::Accessor, or DA for short, is a CRUD (Create, Retrieve, Update Delete)
 database interface for any type of database be it SQL, NON-SQL or even a flat 
 file.

The heart of Accessor is an simple abstraction language that breaks down data 
structures into simple sets of hash-refs that are passed into a 
Database::Accessor::Driver that will process the action.

It is important to remember that Accessor is just an interface layer, a way to 
pass down your abstracted queries to a Data Accessor Driver or DAD for short.

It is the DAD driver modules that do all of the work. Accessor just provides an 
interface and common API. All you the progammer provides is the abstracted 
version of you data.  In in theory you should be able to run the same DA 
against any type of DB and come back with the same results.  Assuming the same 
structure and data are in each.

Architecture of a Accessor Application

                      +-+   +------- -+     +-----+    +-----------+
+-------------+       | |---| DAD DBI |-----| DBI |----| Oracle DB |
| Perl        |  +-+  | |   `---------+     +-----+    +-----------+
| script      |  |A|  |D|   +-----------+   +-------------+
| using       |--|P|--|A|---| DAD Mongo |---| Mongo Engine|
| DA          |  |I|  | |   +-----------+   +-------------+
| Abstraction |  +-+  | |   +---------------+
+-------------+       | |---| Other drivers |-->>
                      +-+   +---------------+

The API, or Application Programming Interface, are the four CRUD functions 
provided by DA, and a Hash-ref, supplied by the programmer, that defines the 
data structure with DA's abstration language. 

The DA simply passes down a set of attributes that are then re-assembles and 
then dispatched by the DAD layer down to the DB layer whatever that may be. 

Usage Outline 
First DA is not an ORM, it knows nothing about the Data Base you are atempting 
to interact with. By itself it does nothing.  All it does it provides a set of 
attribures that are  passed down to a DAD which will do the work.

Though it can be used directly it is best used within another abstracted class, 
as in below;

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
  An instanated database object of some form, say a DBI handle ($dbh) or a 
  MongoDB client ($client).  Whatever is pass in must be compatiable with an
  installed DAD.
  $container
  A HASH or ARRAY referance or a blessed class that is used to pass data into 
  and out of the DAD. It is always returned from the underlying DAD.
  $ops
  A HASH referance of options that can be passed down to the DAD.  Varies by DAD.
  

create
  
  my $new_address = 
     $da->create($dbh, {street     => $street,
                        city       => $city,
                        postal_code=> $pc,
                        region_id  => $province}, $opt);
                     
This method will create a new record on the underlying DAD database.  
It will attempt to match the 'KEYS' of the passed in hash ref with the 
'elements' found on the DA.  The underlying DAD will return the original HASH or
ARRAY ref with creation info the undelying DAD may add in.

retrieve

   $address_da->add_condition({left=>{name=>id},
                               right=>{value=>123}
                              });
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
