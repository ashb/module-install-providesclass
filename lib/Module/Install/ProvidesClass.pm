package Module::Install::ProvidesClass;

use strict;
use warnings;
use Module::Install::Base;

use File::Find::Rule;
use File::Find::Rule::Perl;
use PPI;
use File::Temp;
use ExtUtils::MM_Unix;

BEGIN {
  our @ISA = qw(Module::Install::Base);
  our $ISCORE  = 1;
  our $VERSION = '1.000000';
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
  my ($self) = @_;

  return $self unless $self->is_admin;

  my $no_index = $self->_get_no_index;

  my $dir = $self->_get_dir;

  my $rule = File::Find::Rule->new;
  my @files = $rule->no_index({
      directory => [ map { "$dir/$_" } @{$no_index->{directory} || []} ],
      file => [ map { "$dir/$_" } @{$no_index->{file} || []} ],
  } )->perl_module
     ->in($dir);

  for (@files) {
    my $file = $_;
    s/^\Q$dir\/\E//;
    $self->_search_for_classes_in_file($file, $_)
  }
   
  return $self;
}

sub _search_for_classes_in_file {
  my ($self, $file, $short_file) = @_;

  my $doc = PPI::Document->new($file);

  for ($doc->children) {

    # Tokens can't have children
    next if $_->isa('PPI::Token');
    $self->_search_for_classes_in_node($_, "", $short_file)
  }
}

sub _search_for_classes_in_node {
  my ($self, $node, $class_prefix, $file) = @_;

  my $nodes = $node->find(sub {
      $_[1]->isa('PPI::Token::Word') && $_[1]->content eq 'class' || undef
  });
  return $self unless $nodes;

  for my $n (@$nodes) {
    $n= $n->next_token;
    # Skip over whitespace
    $n = $n->next_token while ($n && !$n->significant);

    next unless $n && $n->isa('PPI::Token::Word');

    my $class = $class_prefix . $n->content;

    # Now look for the '{'
    $n = $n->next_token while ($n && $n->content ne '{' );

    unless ($n) {
      warn "Unable to find '{' after 'class' somewhere in $file\n";
      return;
    }

    $self->provides( $class => { file => $file });

    # $n was the '{' token, its parent is the block/constructor for the 'hash'
    $n = $n->parent;
  
    for ($n->children) {

      # Tokens can't have children
      next if $_->isa('PPI::Token');
      $self->_search_for_classes_in_node($_, "${class}::", $file)
    }

    # I dont fancy duplicating the effort of parsing version numbers. So write
    # the stuff inside {} to a tmp file and use EUMM to get the version number
    # from it.
    my $fh = File::Temp->new;
    $fh->print($n->content);
    $fh->close;
    my $ver = ExtUtils::MM_Unix->parse_version($fh);

    $self->provides->{$class}{version} = $ver if defined $ver && $ver ne "undef";

    # Remove the block from the parent, so that we dont get confused by 
    # versions of sub-classes
    $n->parent->remove_child($n);
  }

  return $self;
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

=head1 SEE ALSO

L<MooseX::Declare>

=head1 AUTHOR

Ash Berlin C<< <ash@cpan.org> >>

=head1 LICENSE 

Licensed under the same terms as Perl itself.

