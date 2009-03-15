use inc::Module::Install 0.79;

use warnings;

perl_version '5.008008';
all_from 'lib/Module/Install/ProvidesClass.pm';

requires 'ExtUtils::MM_Unix'; # For pulling out version number
requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl';
requires 'File::Temp';
requires 'PPI';
requires 'inc::Module::Install' => 0.79;

jsonmeta;

WriteAll;
