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

package GCBot::Utils;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(usage version);

our $VERSION = '1.0';

use constant VERSION => '1.0';

#
# Prints gcbot's usage
#
sub usage 
{
	print << "EOF";
Usage: perl $0 [options]

Possible options are:
      
  --version (-v)      Print gcbot version
  --help    (-h)      Print this help message

EOF

	exit 0;
}

#
# Prints gcbot's version
#
sub version
{
	printf("gcbot version %0.1f\n", VERSION);
	
	exit 0
}

1;
