package Module::Install::ProvidesClass;

use strict;
use warnings;
use Module::Install::Base;


BEGIN {
  our @ISA = qw(Module::Install::Base);
  our $ISCORE  = 1;
  our $VERSION = '0.000001_99';
}

sub _get_no_index {
  my ($self) = @_;

  my $meta;
  {
    # dump_meta does stupid munging/defaults of the Meta values >_<
    no warnings 'redefine';
    local *YAML::Tiny::Dump = sub {
      $meta = shift;
    };
    $self->admin->dump_meta;
  }
  return $meta->{no_index} || { };
}

sub _get_dir {
  $_[0]->_top->{base};
}

sub auto_provides_class {
  my ($self, @keywords) = @_;

  return $self unless $self->is_admin;

  @keywords = ('class','role') unless @keywords;

  require Class::Discover;

  my $no_index = $self->_get_no_index;

  my $dir = $self->_get_dir;

  my $classes = Class::Discover->discover_classes({
    no_index => $no_index,
    dir => $dir,
    keywords => \@keywords
  });

  for (@$classes) {
    my ($class,$info) = each (%$_);
    delete $info->{type};
    $self->provides( $class => $info ) 
  }
}

1;

=head1 NAME

Module::Install::ProvidesClass - provides detection in META.yml for 'class' keyword

=head1 SYNOPSIS

 use inc::Module::Install 0.79;

 all_from 'lib/My/Module/Which/Uses/MooseXDeclare';

 auto_provides_class;
 WriteAll;

=head1 DESCRIPTION

This class is designed to populate the C<provides> field of META.yml files so
that the CPAN indexer will pay attention to the existance of your classes,
rather than blithely ignoring them.

The version parsing is basically the same as what M::I's C<< ->version_form >>
does, so should hopefully work as well as it does.

Currently we only support 'class' as the keyword to look for. This will
certainly need changing to be configurable since MooseX::Declare allows C<role>
as a keyword to create role classes.

This module attempts to be author side only, hopefully it does it correctly, bu
Module::Install is scary at times.

=head1 SEE ALSO

L<MooseX::Declare> for the main reason for this module to exist.

=head1 AUTHOR

Ash Berlin C<< <ash@cpan.org> >>

=head1 LICENSE 

Licensed under the same terms as Perl itself.

