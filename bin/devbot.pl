#! /usr/bin/perl

#
#  $Id$
#  
#  gcbot
#  http://dev.stuconnolly.com/svn/gcbot/
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

package DevBotMain;

use strict;
use warnings;

use lib '../lib';

use GCBot::Bot;
use GCBot::Utils;
use GCBot::Config;
use Getopt::Long;

my ($version, $help);

# Get options
GetOptions('version|v' => \$version, 'help|h' => \$help);	
	
# Decide what to do
usage if $help;
version if $version;

my $conf = get_config('irc');

my $irc_nick    = $conf->{IRC_NICK} || 'devbot';
my $irc_server  = $conf->{IRC_SERVER} || 'irc.freenode.net';
my $irc_port    = $conf->{IRC_PORT} || 6667;
my $irc_channel = $conf->{IRC_CHANNEL};

die 'No IRC channel provided in IRC config.' unless $irc_channel;

# Create bot
my $bot = GCBot::Bot->new(
        server       => $irc_server,
        port         => $irc_port,
        channels     => [$irc_channel],
        nick         => $irc_nick,
        alt_nicks    => ['gcbot_', 'gcbot__'],
        username     => 'gcbot',
        name         => 'Google Code IRC bot',
        charset      => 'utf-8',
 		quit_message => 'Later'
        );

# Run it
$bot->run();

exit 0
