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

package DevBotMain;

use strict;
use warnings;

use lib '../lib';

use Cwd;
use DevBot::Bot;
use DevBot::Time;
use DevBot::Utils;
use DevBot::Config;
use Getopt::Long;

my ($interactive, 
	$commits, 
	$issues, 
	$channel_logging, 
	$tick, 
	$logging, 
	$log_dir, 
	$version, 
	$help);

# Get options
GetOptions('interactive|i'       => \$interactive,
		   'commits|c'           => \$commits,
		   'issues|g'            => \$issues,
		   'channel-logging|cl'  => \$channel_logging,
		   'update-interval|t=i' => \$tick,
		   'logging|l'           => \$logging,
		   'logdir|d=s'          => \$log_dir,
		   'version|v'           => \$version, 
		   'help|h'              => \$help);
			
# Decide what to do
DevBot::Utils::usage if $help;
DevBot::Utils::version if $version;

$DevBot::Bot::TICK = $tick if $tick;
$DevBot::Log::LOGGING = 1 if $logging;
$DevBot::Log::LOG_PATH = $log_dir if $log_dir;
$DevBot::Bot::INTERACTIVE = 1 if $interactive;
$DevBot::Bot::ANNOUNCE_COMMITS = 1 if $commits;
$DevBot::Bot::ANNOUNCE_ISSUE_UPDATES = 1 if $issues;
$DevBot::Bot::CHANNEL_LOGGING = 0 if $channel_logging;

print "Enabling logging...\n" if $logging;
print "Enabling interactivity...\n" if $interactive;
print "Enabling issue annoucements...\n" if $issues;
print "Enabling commit annoucements...\n" if $commits;
print "Disabling channel logging...\n" if $channel_logging;

printf("Setting issue update check interval to %d seconds\n", $tick) if $tick;

# Set the root dir
$DevBot::Utils::ROOT_DIR = substr(getcwd, 0, rindex(getcwd, '/'));

my $conf = DevBot::Config::get_config('irc');

my $irc_nick     = $conf->{IRC_NICK} || 'devbot';
my $irc_server   = $conf->{IRC_SERVER} || 'irc.freenode.net';
my $irc_port     = $conf->{IRC_PORT} || 6667;
my $irc_channels = [split(m/\s+/, $conf->{IRC_CHANNEL})];

die 'No IRC channel(s) provided in IRC config.' unless $irc_channels;

# Delete any time tracking files that may already exist.
delete_datetime_logs;

# Create bot
my $bot = DevBot::Bot->new(
		server      => $irc_server,
		port        => $irc_port,
		channels    => $irc_channels,
		nick        => $irc_nick,
		alt_nicks   => ['devbot_', 'devbot__'],
		username    => 'devbot',
		name        => 'Development Bot',
		charset     => 'utf-8',
		
		interactive => $interactive,
		tick        => $tick,
		commits     => $commits,
		issues      => $issues,
		logging     => ($channel_logging) ? 0 : 1
        );

# Run it
$bot->run;

# Get rid of the log
delete_datetime_log if $issues;

exit 0;
