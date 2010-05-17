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
use DevBot::Utils;
use Bot::BasicBot;

use base 'Bot::BasicBot';

our $VERSION = '1.0';

#
# Overriden said. Called when someone says something in the channel.
#
sub said 
{
    my($self, $e) = @_;

    _log($e->{channel}, $e->{who}, $e->{body});

    return undef;
}

#
#
#
sub emoted 
{
	my($self, $e) = @_;

	_log($e->{channel}, '* ' . $e->{who}, $e->{body});
    
	return undef;
}

#
#
#
sub chanjoin 
{
	my($self, $e) = @_;

	_log($e->{channel}, '', sprintf('%s joined %s', $e->{who}, $e->{channel}));

	return undef;
}

#
#
#
sub chanquit 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel}));
	
	return undef;
}

#
#
#
sub chanpart 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s left %s', $e->{who}, $e->{channel}));

	return undef;
}

#
#
#
sub topic 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('Topic for %s is now %s', $e->{channel}, $e->{topic}));

	return undef;
}

#
#
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
#
#
sub kicked 
{
	my($self, $e) = @_;
	
	_log($e->{channel}, '', sprintf('%s was kicked by %s: %s', $e->{nick}, $e->{who}, $e->{reason}));
	
	return undef;
}

#
# Overriden help.
#
sub help 
{	
	return 'This is a passive Google Code IRC bot. See http://dev.stuconnolly.com/svn/devbot/trunk/README';
}

#
#
#
sub _channels_for_nick 
{
    my($self, $nick) = shift;

    return grep {$self->{channel_data}{$_}{$nick}} keys(%{$self->{channel_data}});
}

#
# Logs the supplied arguments to the database.
#
sub _log
{
	my($channel, $who, $line) = @_;
	    
	query('INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES (?, ?, ?, ?, ?)', $channel, gmt_today, $who, time, $line);
}

1;
