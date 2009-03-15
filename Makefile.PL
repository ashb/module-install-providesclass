use inc::Module::Install 0.79;

use warnings;

perl_version '5.008008';
all_from 'lib/Module/Install/MooseXDeclare.pm';

requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl';
requires 'PPI';
requires 'inc::Module::Install' => 0.79;

WriteAll;
