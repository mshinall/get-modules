#!/usr/bin/perl -w
#
# https://github.com/mshinall
#
# Use CPAN shell to automatically download dependencies listed in the given
# perl scripts
#

require 5.010_000;

use strict;
use CPAN;

my $VERSION = "1.00";

if(scalar(@ARGV) <= 0) {
    print("Usage: dependencies.pl FILE [FILE ...]\n");
    exit(1);
}

my @files = @ARGV;
my @excludes = (
    "strict",
    "warnings",
    "vars",
    "\\d",
    );

print("Checking the following files for dependencies: \n\t" . join("\n\t", @files) . "\n\n");
my %modules = (
    'CPAN' => '1',
    'YAML' => '1',
    );
    
my $module = "";
#print("Excluding the following dependencies:\n\t" . join("\n\t", @excludes) . "\n\n");
foreach my $file (@files)
{
    my $input;
    open($input, "${file}");
    while(<$input>)
    {
        /^\s*(use|require)\s+([\w:.]+)/ && do
        {
            $module = $2;
            my $excluded = 0;
            foreach my $exclude (@excludes)
            {
                $module =~ /^$exclude\b/ && do { $excluded++; };
            }
            if($excluded <= 0) { $modules{$module} = "1"; }
        }

    }
}

print("Found the following dependencies: \n\t" . join("\n\t", keys(%modules)) . "\n\n");

#always install pre-reqs
$ENV{'PERL_MM_USE_DEFAULT'} = 1;

print("Setting CPAN session options...\n");
CPAN::Shell->o('conf', 'connect_to_internet_ok', '1');
CPAN::Shell->o('conf', 'halt_on_failure', '0');
CPAN::Shell->o('conf', 'prerequisites_policy', 'follow');
#CPAN::Shell->o('conf', 'commit');

print("\nInstalling modules...\n");
foreach my $module (keys(%modules))
{
    eval("use ${module}");
    if($@) {
        print("Module '${module}' is not installed.\n");    
        print("Attempting to install module '${module}'...\n");
        CPAN::Shell->install($module);
    } else {
        print("Module '${module}' is already installed.\n");
    }
}

print("\nDone.\n");
    
1;
