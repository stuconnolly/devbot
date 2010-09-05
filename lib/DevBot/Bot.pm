#! /usr/bin/perl

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

package DevBot::Bot;

use strict;
use warnings;

use DevBot::DB;
use DevBot::Time;
use DevBot::Issues;
use DevBot::Command;
use Bot::BasicBot;

use vars qw($INTERACTIVE $TICK $ANNOUNCE_ISSUE_UPDATES $CHANNEL_LOGGING);

use base 'Bot::BasicBot';

our $VERSION = 1.00;

#
# By default the bot is not interactive
#
our $INTERACTIVE = 0;

#
# Default tick is every 5 minutes
#
our $TICK = 300;

#
# By default don't announce issue changes
#
our $ANNOUNCE_ISSUE_UPDATES = 0;

#
# By default enable channel logging
#
our $CHANNEL_LOGGING = 1;

#
# Overriden said. Called whenever someone says something in the channel.
#
sub said 
{
    my($self, $e) = @_;

	if ($CHANNEL_LOGGING) {
		_log($e->{channel}, $e->{who}, $e->{body});
	}
	
	if ($INTERATIVE) {
		# See if we were asked something
		if (length($e->{address})) {
			my $issue_id = 0; 

			($e->{body} =~ /^i([0-9]+)$/) && ($issue_id = $1);

			if ($issue_id) {
				$self->say(who     => $e->{who},
						   channel => $e->{channel}, 
						   body    => $issue_id,
						   address => 1);
			}
		}
	}

    return undef;
}

#
# Overriden emoted.
#
sub emoted 
{
	my($self, $e) = @_;

	_log($e->{channel}, '* ' . $e->{who}, $e->{body});
    
	return undef;
}

#
# Overriden chanjoin. Called whenever someone joins the channel.
#
sub chanjoin 
{
	my($self, $e) = @_;

	if ($CHANNEL_LOGGING) {
		_log($e->{channel}, '', sprintf('%s joined %s', $e->{who}, $e->{channel}));
	}

	return undef;
}

#
# Overriden chanpart. Called whenever someone leaves the channel. 
#
sub chanpart 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel}));

	return undef;
}

#
# Overriden chanquit. Called whenever someone leaves the channel. 
#
sub chanquit 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel}));

	return undef;
}

#
# Overriden topic. Called whenever the channel's topic is changed.
#
sub topic 
{
	my($self, $e) = @_;
	
	if ($CHANNEL_LOGGING) {
		_log($e->{channel}, '', sprintf('Topic for %s is now %s', $e->{channel}, $e->{topic}));
	}

	return undef;
}

#
# Overriden nick_change. Called whenever someone's nick changes.
#
sub nick_change 
{	
	my($self, $old, $new) = @_;
	
	foreach ($self->_channels_for_nick($new)) 
	{
		_log($_, '', sprintf('%s is now known as %s', $old, $new));
	}

	return undef;
}

#
# Overriden userquit. Called whenever someone leaves the channel.
#
sub userquit 
{
	my ($self, $e) = @_;

	my $nick = $e->{who};

	foreach my $channel ($self->_channels_for_nick($nick)) 
	{
		$self->chanpart({who => $nick, channel => $channel});
	}
}

#
# Overriden kicked. Called whenever some is kicked from the channel.
#
sub kicked 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s was kicked by %s: %s', $e->{nick}, $e->{who}, $e->{reason}));
	
	return undef;
}

#
# Called every so often to perform background processes.
#
sub tick 
{	
	my $self = shift;
	
	return 0 if !$ANNOUNCE_ISSUE_UPDATES;
				
	$self->forkit(channel => $self->{channels}[0], 
				  run     => \&_check_for_updated_issues);
	
	return $TICK;
}

#
# Overriden help. Tell whoever asked about ourself.
#
sub help 
{	
	return 'I am an interactive development bot. See http://dev.stuconnolly.com/svn/devbot/trunk/README';
}

#
# Checks for any updated issues since the last check and announces them to the channel.
#
sub _check_for_updated_issues
{				
	for my $update (get_updated_issues)
	{		
		if (($update->{id} > 0) && ($update->{url})) {
			printf("( %s ): %s by %s\n", $update->{url}, $update->{title}, $update->{author});
		}
		else {
			printf("%s by %s\n", $update->{title}, $update->{author});
		}
	}
}

#
# Returns the channels for the supplied nick.
#
sub _channels_for_nick 
{
    my($self, $nick) = @_;

    return grep {$self->{channel_data}{$_}{$nick}} keys(%{$self->{channel_data}});
}

#
# Logs the supplied arguments to the database.
#
sub _log
{
	my($channel, $who, $line) = @_;
	    
	query('INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES (?, ?, ?, ?, ?)', $channel, gmt_date, $who, time, $line);
}

1;
