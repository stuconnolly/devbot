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

our @EXPORT = qw(get_last_updated_datetime get_current_datetime delete_datetime_log);

our $VERSION = '1.0';

#
# devbot's temporary date/time tracking file
#
our $TIME_TRACKING_FILE = '/tmp/devbot.tmp';

#
# Gets the last updated datetime time from the tracking file or uses 
# the current datetime if it doesn't exist.
#
sub get_last_updated_datetime
{
	my $datetime = undef;
	
	# If the tracking file doesn't exist use the current datetime
	if (-s $TIME_TRACKING_FILE) {
		
		open(FILE, "<${TIME_TRACKING_FILE}") || die $!;
		
		chomp($datetime = <FILE>);
		
		close(FILE);
		
		_write_datetime(get_current_datetime());
	}
	else {
		$datetime = get_current_datetime();
		
		_write_datetime($datetime);
	}
	
	return $datetime;
}

#
# Returns the current datetime in W3C format.
#
sub get_current_datetime
{
	my $w3c = DateTime::Format::W3CDTF->new;

	my $time = $w3c->format_datetime(DateTime->now);

	$time =~ s/Z//g;
	
	return $time;
}

#
# Deletes the datetime log.
#
sub delete_datetime_log
{
	unlink($TIME_TRACKING_FILE) || die $!;
}

#
# Writes the supplied datetime to the time tracking temp file.
#
sub _write_datetime
{
	my $datetime = shift;
	
	open(FILE, ">$TIME_TRACKING_FILE") || die $!;
	
	print FILE "${datetime}\n";

	close(FILE);
}

1;
