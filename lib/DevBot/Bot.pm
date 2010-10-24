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
use DevBot::Daemon;
use DevBot::Command;
use Bot::BasicBot;

use base 'Bot::BasicBot';

our $VERSION = '1.00';

#
# Constructor.
#
sub new
{
	my ($this, %args) = @_;
	
	$args{interactive} ||= 0;
	$args{tick_int}    ||= 300;
	$args{daemon_host} ||= 'localhost';
	$args{daemon_port} ||= 1987;
	$args{commits}     ||= 0;
	$args{issues}      ||= 0;
	$args{logging}     ||= 0; 
	$args{message}     ||= 0;
	$args{commit_key}  ||= undef;
	$args{message_key} ||= undef;
		
	return $this->SUPER::new(%args);
}

#
# Overriden connected. If required, spawn a new process to listen for source commits.
#
sub connected
{
	my $self = shift;
			
	# If we're listening for commits, start the HTTP daemon in another process to listen for connections
	if ($self->{commits}) {
		printf("Starting commit HTTP daemon listening on %s:%d\n", $self->{daemon_host}, $self->{daemon_port});
		
		$self->forkit(run       => \&_listen_for_commits,
					  channel   => $self->{channels}[0],
					  arguments => [$self]);		
	}
	
	return undef;
}

#
# Overriden said. Called whenever someone says something in the channel.
#
sub said 
{
    my ($self, $e) = @_;

	my $addressed = ($e->{address} && length($e->{address}));

	_log($e->{channel}, $e->{who}, $e->{body}) if (!$addressed && $self->{logging});
	
	if ($self->{interactive}) {
		
		# See if we were asked something
		if ($addressed) {
					
			my $result = DevBot::Command->new($e->{body}, $e->{channel})->parse;

			foreach (@{$result->{data}})
			{
				if (defined($result->{public}) && $result->{public} == 1) {
					$self->say(channel => $self->{channels}[0], body => $_);
				}
				else {
					$self->say(who => $e->{who}, channel => 'msg', body => $_);
				}
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
	my ($self, $e) = @_;

	_log($e->{channel}, '* ' . $e->{who}, $e->{body}) if $self->{logging};
    
	return undef;
}

#
# Overriden chanjoin. Called whenever someone joins the channel.
#
sub chanjoin 
{
	my ($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s joined %s', $e->{who}, $e->{channel})) if $self->{logging};

	return undef;
}

#
# Overriden chanpart. Called whenever someone leaves the channel. 
#
sub chanpart 
{
	my ($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel})) if $self->{logging};

	return undef;
}

#
# Overriden chanquit. Called whenever someone leaves the channel. 
#
sub chanquit 
{
	my ($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel})) if $self->{logging};

	return undef;
}

#
# Overriden topic. Called whenever the channel's topic is changed.
#
sub topic 
{
	my ($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('Topic for %s is now %s', $e->{channel}, $e->{topic})) if $self->{logging};

	return undef;
}

#
# Overriden nick_change. Called whenever someone's nick changes.
#
sub nick_change 
{	
	my ($self, $old, $new) = @_;
	
	foreach ($self->_channels_for_nick($new)) 
	{
		_log($_, '', sprintf('%s is now known as %s', $old, $new)) if $self->{logging};
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
		$self->chanpart({who => $nick, channel => $channel}) if $self->{logging};
	}
}

#
# Overriden kicked. Called whenever some is kicked from the channel.
#
sub kicked 
{
	my ($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s was kicked by %s: %s', $e->{nick}, $e->{who}, $e->{reason})) if $self->{logging};
	
	return undef;
}

#
# Called every so often to perform background processes.
#
sub tick 
{	
	my $self = shift;
	
	return 0 unless $self->{issues};
								
	$self->forkit(channel => $self->{channels}[0], run => \&_check_for_updated_issues); 
	
	return $self->{tick_int};
}

#
# Overriden help. Tell whoever asked about ourself.
#
sub help 
{	
	return "I am an interactive development bot. See http://dev.stuconnolly.com/svn/devbot/trunk/README or ask 'commands'";
}

#
# Checks for any updated issues since the last check and announces them to the channel.
#
sub _check_for_updated_issues
{								
	foreach (DevBot::Issues::get_updated_issues)
	{		
		if (($_->{id} > 0) && ($_->{url})) {
			printf("( %s ): %s by %s\n", $_->{url}, $_->{title}, $_->{author});
		}
		else {
			printf("%s by %s\n", $_->{title}, $_->{author});
		}
	}
}

#
# Starts listening for commits by starting the HTTP daemon in the background.
#
sub _listen_for_commits
{			
	my $self = $_[1];
		
	DevBot::Daemon->new($self->{daemon_host}, $self->{daemon_port}, $self->{commit_key}, $self->{message_key}, $self->{message})->run();
}

#
# Returns the channels for the supplied nick.
#
sub _channels_for_nick 
{
    my ($self, $nick) = @_;

    return grep {$self->{channel_data}{$_}{$nick}} keys(%{$self->{channel_data}});
}

#
# Logs the supplied arguments to the database.
#
sub _log
{
	my ($channel, $who, $line) = @_;
	    
	DevBot::DB::query('INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES (?, ?, ?, ?, ?)', $channel, gmt_date, $who, time, $line);
}

1;
