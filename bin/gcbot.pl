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

package GCBot;

use strict;
use warnings;

use lib '../lib';

use GCBot::Utils;
use Getopt::Long;
use Bot::BasicBot;

my ($version, $help);

# Get options
GetOptions('version|v' => \$version, 'help|h' => \$help);	
	
# Decide what to do
usage if $help;
version if $version;

# If we reach here, no options were provided
printf("Type '$0 -h' for usage.\n");

exit 0
