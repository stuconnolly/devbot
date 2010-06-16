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

package DevBot::Time;

use strict;
use warnings;

use DateTime;
use DateTime::Format::W3CDTF;

use base 'Exporter';

our @EXPORT = qw(get_current_datetime);

our $VERSION = '1.0';

#
# Returns the current datetime in W3C format.
#
sub get_current_datetime
{
	my $w3c = DateTime::Format::W3CDTF->new;

	my $time = $w3c->format_datetime(DateTime->now);

	# Remove the Timezone 'Z'
	$time =~ s/Z//g;
	
	return $time;
}

1;
