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

our $VERSION = 1.00;

#
# Initializer.
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
# Parses the supplied command.
#
sub parse
{
	my $self = shift;
	
	return undef if (!length($self->{_command}));
	
	my @result;
	my @commands = $self->_load_commands();
		
	foreach (@commands)
	{				
		my @args = ($self->{_channel});
		
		if ($self->{_command} =~ /$_->{regex}/i) {
			
			# Capture all args
			push(@args, ($self->{_command} =~ /$_->{regex}/gi));

			if (@args > 1) {														
				@result = $_->{method}->(@args);			
			}
		}
	}
	
	return @result;	
}

#
# Returns the available commands.
#
sub _load_commands
{
	my $self = shift;
	
	return ({
				'regex'  => '^history\s([0-9]+)$', 
				'method' => \&DevBot::Commands::command_history
			},
	     	{
				'regex'  => '[i|issue\s]([0-9]+)$', 
				'method' => \&DevBot::Commands::command_issue
			});
}

1;
