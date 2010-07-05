#
#  $Id$
#  
#  devbot
#  http://dev.stuconnolly.com/svn/serveadmin/
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

package DevBot::Log;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(log_m);

our $VERSION = '1.0';

#
# Default log filename
#
our $LOG_FILE = 'devbot.log';

#
# Logs the supplied message.
#
sub log_m
{
	my $message = shift;
	
	my $log = sprintf('../logs/%s', _log_filename());
	
	open(LOG, '>>', $log) || die $!;
	
	print LOG "${message}\n";
	
	close(LOG);
}

#
# Returns the current log filename.
#
sub _log_filename
{
	my @day = gmtime(time);
	
	return sprintf('%02d-%02d-%04d-%s', $day[3], $day[4] + 1, $day[5] + 1900, $LOG_FILE);
}

1;
