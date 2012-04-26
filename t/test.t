#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Test::More 0.95;
use Test::Fatal;

use Ubic::ServiceLoader::Ext::yaml;

my $loader = Ubic::ServiceLoader::Ext::yaml->new;

{
    my $service = $loader->load('t/data/bar.yaml');
    ok $service->isa('Ubic::Service::SimpleDaemon'), 'load service';
    is $service->{bin}, 'sleep 200', 'pass options to constructor';
    is $service->{env}{FOO}, '5', 'second-level option';
}

{
    my $service = $loader->load('t/data/default-module.yaml');
    ok $service->isa('Ubic::Service::SimpleDaemon'), 'SimpleDaemon is a default module for yaml configs';
}

like(
    exception {
        $loader->load('t/data/invalid.yaml')
    },
    qr/Unknown parameter/,
    "attempt to load config with unknown section fails"
);

like(
    exception {
        $loader->load('t/data/invalid2.yaml')
    },
    qr/Unknown parameter/,
    "attempt to load config with unknown root-level option"
);

like(
    exception {
        $loader->load('t/data/invalid3.yaml')
    },
    qr/YAML::Tiny failed to classify line /,
    "attempt to load config with syntax error"
);

done_testing;
