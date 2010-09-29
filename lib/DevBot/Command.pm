#
#  $Id$
#  
#  devbot
#  http://dev.stuconnolly.com/svn/devbot/
#
#  Copyright (c) 2010 Stuart Connolly. All rights reserved.
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package DevBot::Command;

use strict;
use warnings;

use DevBot::Commands;

our $VERSION = '1.00';

#
# Constructor.
#
sub new
{
	my ($this, $command, $channel) = @_;
	
	my $class = ref($this) || $this;
				
	my $self = {
		_command => $command,
		_channel =>	$channel
	};
	
	bless($self, $class);
	
	return $self;
}

sub AUTOLOAD;

#
# Parses the supplied command and returns the result of the matched rule/function.
#
sub parse
{
	my $self = shift;
	
	return undef if (!length($self->{_command}));
	
	my @result;
	my @commands = DevBot::Commands::command_list();
		
	foreach (@commands)
	{				
		my @args = ($self->{_channel});
		
		if ($self->{_command} =~ /$_->{regex}/i) {
			
			# Capture all args
			push(@args, ($self->{_command} =~ /$_->{regex}/gi));

			if (@args > 1) {														
				@result = $_->{method}->(@args);
				last;			
			}
		}
	}
	
	return @result;	
}

1;
