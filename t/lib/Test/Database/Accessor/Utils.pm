#!/usr/bin/perl
package Test::Database::Accessor::Utils;
use lib ('..\..\..\..\lib');

use Test::Deep;
use Test::More;
use Data::Dumper;
use strict;
use warnings;

sub deep_element {
    my ( $in, $da, $dad, $type ) = @_;


    foreach my $index ( 0 .. scalar( @{$in} - 1 ) ) {
        if (exists($in->[$index]->{function})){
            bless( $in->[$index], "Database::Accessor::Function" );
        }
        else {
            bless( $in->[$index], "Database::Accessor::Element" );
        }
        cmp_deeply(
            $da->[$index],
            methods( %{ $in->[$index] } ),
            "DA $type $index correct"
        );
        cmp_deeply(
            $dad->[$index],
            methods( %{ $in->[$index] } ),
            "DAD $type $index correct"
        );
    }
}

sub deep_predicate {
    my ( $in, $da, $dad, $type,$skip_one ) = @_;
    my $start = 0;
    $start = 1
      if ($skip_one);
    foreach my $index ( $start .. ( scalar( @{$in} - 1 ) ) ) {
        my $predicate = $in->[$index];
        
        bless( $predicate, "Database::Accessor::Predicate" );
        # warn("Perdicate=".Dumper($predicate));
        bless_element( $predicate->{left} );
        $predicate->{left}->_lookup_name()
          if (ref($predicate->{left}) eq "Database::Accessor::Element" );
        bless_element( $predicate->{right} );
        $predicate->{right}->_lookup_name()
          if (ref($predicate->{right}) eq "Database::Accessor::Element" );

        my @preticates;
        my @dad_preticates;
        if ( ref($da) eq "ARRAY" ) {
            @preticates     = @{$da};
            @dad_preticates = @{$dad};
        }
        else {
            push( @preticates,     $da );
            push( @dad_preticates, $dad );
        }

        foreach
          my $index2 ( 0 .. ( scalar(@{$in}) - 1 ) )
        {
            cmp_deeply(
                $preticates[$index]->predicates,
                methods( %{$predicate} ),
                "DA $type $index2->predicates $index correct"
            );
            cmp_deeply(
                $dad_preticates[$index]->predicates,
                methods( %{$predicate} ),
                "DAD $type $index2->predicates $index correct"
            );

        }
    }
}

sub deep_links {
    my ( $in_hash, $da, $dad, $static ) = @_;

    my @links;

    if ( ref( $in_hash->{links} ) eq "ARRAY" ) {
        @links = @{ $in_hash->{links} };

    }
    else {
        push( @links, $in_hash->{links} );
    }

    foreach my $index ( 0 .. ( scalar(@links) - 1 ) ) {
        my $in = $links[$index];

        if ($static) {
            ok( ref( $da->links()->[$index] ) eq "Database::Accessor::Link",
                "Da Link $index is a Link" );
            ok( ref( $dad->links()->[$index] ) eq "Database::Accessor::Link",
                "Dad Link $index is a Link" );
        }
        else {
           ok(
                ref( $da->dynamic_links()->[$index] ) eq
                  "Database::Accessor::Link",
                "Da dynamic_link $index is a Link"
            );
            
           ok(
                ref( $dad->links()->[$da->link_count()+$index] ) eq
                  "Database::Accessor::Link",
                "Dad link $index is a Link"
            );

        }

        bless( $in->{to}, "Database::Accessor::View" );

        if ($static) {
            cmp_deeply(
                $da->links()->[$index]->to,
                methods( %{ $in->{to} } ),
                "DA Link View $index correct"
            );
            cmp_deeply(
                $dad->links()->[$index]->to,
                methods( %{ $in->{to} } ),
                "DAD Link View $index correct"
            );
            

            
              Test::Database::Accessor::Utils::deep_predicate( $in->{conditions},
                $da->links()->[$index]->conditions,
                , $dad->links()->[$index]->conditions, 'Link' );
            
        }
        else {
            cmp_deeply(
                $da->dynamic_links()->[$index]->to,
                methods( %{ $in->{to} } ),
                "DA dynamic Link View $index correct"
            );
            cmp_deeply(
                $dad->links()->[$da->link_count()+$index]->to,
                methods( %{ $in->{to} } ),
                "DAD Link View $index correct"
            );

            Test::Database::Accessor::Utils::deep_predicate(
                $in->{conditions}, $da->dynamic_links()->[$index]->conditions,
                , $dad->links()->[$da->link_count()+$index]->conditions,
                'Dynamic Link'
            );
        }

    }
}

sub bless_element {
    my ($in) = shift;
    if ( exists( $in->{value} ) ) {
        bless( $in, "Database::Accessor::Param" );
    }
    else {
        bless( $in, "Database::Accessor::Element" );
    }
    return;
}

1;
