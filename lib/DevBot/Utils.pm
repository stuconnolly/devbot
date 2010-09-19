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

package DevBot::Utils;

use strict;
use warnings;

use vars qw($ROOT_DIR);

our $VERSION = 1.0;

use constant VERSION => 1.0;

#
# devbot rootdir
#
our $ROOT_DIR = '';

#
# Prints devbot's usage
#
sub usage 
{
	print << "EOF";
Usage: perl $0 [options]

Possible options are:
  
  --interactive     (-i)      Enable bot interactivity
  --notify          (-n)      Enable the annoucement of source commits
  --issues          (-g)      Enable the annoucement of issue updates
  --channel-logging (-cl)     Disable channel logging
  --update-interval (-t)      Specify the interval at which issue updates are checked (in seconds)
  --logging         (-l)      Enable logging
  --logdir          (-d)      Specify a different log directory (must be an absolute path)
  --version         (-v)      Print devbot version
  --help            (-h)      Print this help message

EOF

	exit 0;
}

#
# Prints devbot's version
#
sub version
{
	printf("devbot version %0.1f\n", VERSION);
	
	exit 0
}

1;
