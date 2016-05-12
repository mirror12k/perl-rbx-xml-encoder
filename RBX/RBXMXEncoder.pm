package RBX::RBXMXEncoder;
use base 'Exporter';
use strict;
use warnings;

use feature 'say';

use Data::Dumper;


our @EXPORT = qw/
encode_rbxmx_model
/;


=pod


a packaged for creation of .rbxmx formatted strings from data
made because i still haven't figured out the .rbxl file format, .obj looks terrifying, and .rbxmx is just so simple


format of objects expected to be encoded:
{
class => "SomeClassName",
properties => { Name => [ 'string', 'some random name'], },
children => []
}

=cut



sub encode_rbxmx_preamble {
'<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
'
}

sub encode_rbxmx_postamble {
'</roblox>
'
}

sub encode_rbxmx_model {

	my $data = encode_rbxmx_preamble;
	$data .= encode_rbxmx_item($_) for @_;
	$data .= encode_rbxmx_postamble;

	return $data
}


sub encode_rbxmx_item {
	my ($item) = @_;

	return "<Item class=\"$item->{class}\"><Properties>" .
		(join '', map "<$item->{properties}{$_}[0] name=\"$_\">$item->{properties}{$_}[1]</$item->{properties}{$_}[0]>", keys $item->{properties}) .
		"</Properties>" .
		(join '', map encode_rbxmx_item($_), @{$item->{children} // []}) .
		"</Item>"
}


