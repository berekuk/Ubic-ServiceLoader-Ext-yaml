package Ubic::ServiceLoader::Ext::yaml;

# ABSTRACT: loader for yaml configs

=head1 SYNOPSIS

    # in /etc/ubic/service/my.yaml file:
    module: Ubic::Service::SimpleDaemon
    options:
        bin: sleep 100
        stdout: /var/log/my/stdout.log
        stderr: /var/log/my/stderr.log

=cut

use strict;
use warnings;

use parent qw( Ubic::ServiceLoader::Base );

use YAML::Tiny;

sub new {
    my $class = shift;
    return bless {} => $class;
}

sub load {
    my $self = shift;
    my ($file) = @_;

    my $config = YAML::Tiny->read($file);
    unless ($config) {
        die YAML::Tiny->errstr;
    }
    $config = $config->[0];

    my $module = delete $config->{module} || 'Ubic::Service::SimpleDaemon';
    my $options = delete $config->{options};
    if (keys %$config) {
        die "Unknown parameter ".join(', ', keys %$config)." in file $file";
    }

    $module =~ /^[\w:]+$/ or die "Invalid module name '$module'";
    eval "require $module"; # TODO - Class::Load?
    if ($@) {
        die $@;
    }

    my @options = ();
    @options = ($options) if $options; # some modules can have zero options, I guess
    return $module->new(@options);
}

1;
