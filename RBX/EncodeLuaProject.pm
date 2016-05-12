#!/usr/bin/env perl
package RBX::EncodeLuaProject;
use base 'Exporter';
use strict;
use warnings;

use feature 'say';

use File::Slurper qw/ read_text read_dir /;
use Data::Dumper;

use RBX::RBXMXEncoder;

our @EXPORT = qw/

/;



sub format_script {
	my ($name, $text) = @_;

	return {
			class => "Script",
			properties => {
				Disabled => [ bool => 'false' ],
				Name => [ string => $name ],
				LinkedSource => [ Content => '<null></null>' ],
				Source => [ ProtectedString => '<![CDATA[' . $text . ']]>' ],
			},
		}
}

sub format_module_script {
	my ($name, $text) = @_;

	return {
			class => "ModuleScript",
			properties => {
				Name => [ string => $name ],
				LinkedSource => [ Content => '<null></null>' ],
				Source => [ ProtectedString => '<![CDATA[' . $text . ']]>' ],
			},
		}
}

sub format_folder {
	my ($name) = @_;
	return {
			class => "Folder",
			properties => {
				Name => [ string => $name ],
			}
		}
}


sub encode_file {
	my ($path) = @_;
	if ($path =~ /([^\/]+)\.lua\Z/) {
		my $name = $1;
		if ($name eq 'main') {
			return format_script($name, read_text($path));
		} else {
			return format_module_script($name, read_text($path));
		}
	} else {
		die "unknown file type to encode for rbxmx: $path";
	}
}

sub encode_directory {
	my ($path) = @_;
	my @files = read_dir($path);

	my $item = format_folder($path =~ s/\A.*\/(.+)\Z/$1/r);
	$item->{children} = [ map { -f "$path/$_" ? encode_file("$path/$_") : encode_directory("$path/$_") } grep { -f or -d } grep /\A[^\.]/, @files ];

	return $item
}

sub encode_rbxmx_lua_project {

	my @items;
	for my $path (@_) {
		if (-f $path) {
			push @items, encode_file($path);
		} elsif (-d $path) {
			push @items, encode_directory($path);
		} else {
			...
		}
	}
	return encode_rbxmx_model(@items)
}

sub main {
	die "filepath required" unless @_;

	print encode_rbxmx_lua_project(@_);
}

caller or main(@ARGV)
