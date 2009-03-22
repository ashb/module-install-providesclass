use inc::Module::Install 0.79;

use warnings;

perl_version '5.008008';
all_from 'lib/Module/Install/ProvidesClass.pm';

requires 'ExtUtils::MM_Unix' => '6.48'; # For pulling out version number
requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl' => '1.05';
requires 'PPI';
requires 'inc::Module::Install' => 0.79;

test_requires 'Test::Differences';

auto_provides;
jsonmeta;

WriteAll;
