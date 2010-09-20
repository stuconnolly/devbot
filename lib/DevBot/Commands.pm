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

package DevBot::Commands;

use strict;
use warnings;

use DevBot::DB;
use DevBot::Config;
use DevBot::Issues;
use DevBot::Queries;

our $VERSION = 1.00;

#
# Commands command.
#
sub commands
{
	my $channel = shift;
		
	my @messages = ();
	
	foreach (command_list())
	{
		push(@messages, sprintf("%s %s", $_->{usage}, $_->{description}));
	}
	
	return @messages;
}

#
# History command.
#
sub command_history
{
	my ($channel, $history) = @_;
	
	return undef if (!$history);
	
	# Cap history at 20 entries
	$history = 20 if ($history > 20); 
				
	my $result = DevBot::DB::query($DevBot::Queries::HISTORY_QUERY, $channel, $history);
	
	my @messages = (sprintf("Last %d messages in %s:", $history, $channel));
	
	while (my @row = $result->fetchrow_array)
	{
		push(@messages, sprintf("[%s] <%s> %s\n", $row[0], $row[1], $row[2]));
	}
	
	return @messages;
}

#
# Issue command.
#
sub command_issue
{
	my ($channel, $issue_id) = @_;
	
	return undef if (!$issue_id);
		
	my @messages = (sprintf("Issue %d: %s", $issue_id, DevBot::Project::create_issue_url($issue_id, 0)));
	
	return @messages;
}

#
# Returns the available commands.
#
sub command_list
{	
	return ({
				'usage'       => 'commands',
				'description' => 'List available commands (this message)',
				'regex'       => '^commands$',
				'method'      => \&DevBot::Commands::commands
			},
			{
				'usage'       => 'history <num>',
				'description' => 'Display the <num> most recent messages',
				'regex'       => '^history\s([0-9]+)$', 
				'method'      => \&DevBot::Commands::command_history
			},
	     	{
				'usage'       => 'issue <num> (i<num>)',
				'description' => 'Return the URL for issue <num>',
				'regex'       => '[i|issue\s]([0-9]+)$', 
				'method'      => \&DevBot::Commands::command_issue
			});
}

1;
