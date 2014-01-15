#  
#  devbot
#  https://github.com/stuconnolly/devbot
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

use Carp;
use DateTime;
use DateTime::Format::W3CDTF;

our $VERSION = '1.00';

#
# devbot's temporary datetime tracking file
#
our $TIME_TRACKING_FILE = "/tmp/devbot.tmp.$$";

#
# Gets the last updated datetime time from the tracking file or uses 
# the current datetime if it doesn't exist.
#
sub get_last_updated_datetime
{
	my $datetime;
	
	# If the tracking file doesn't exist use the current datetime
	if (-s $TIME_TRACKING_FILE) {
		
		open(my $file, $TIME_TRACKING_FILE) || croak $!;
		
		chomp($datetime = <$file>);
		
		close($file);		
	}
	else {
		$datetime = _get_current_datetime();
		
		write_datetime($datetime);
	}
	
	return $datetime;
}

#
# Writes the supplied datetime to the time tracking temp file.
#
sub write_datetime
{
	my $datetime = shift;
	
	open(my $file, '>', $TIME_TRACKING_FILE) || croak $!;
	
	print $file "${datetime}\n";

	close($file);
}

#
# Deletes the datetime log if it exists.
#
sub delete_datetime_log
{
	if (-e $TIME_TRACKING_FILE) {
		unlink($TIME_TRACKING_FILE) || carp "Could not delete time tracking file '${TIME_TRACKING_FILE}': $!";
	}
}

#
# Returns the current GMT date in format YYYY-MM-DD.
#
sub gmt_date 
{
	my @day = gmtime(time);
    
	return sprintf('%04d-%02d-%02d', $day[5] + 1900, $day[4] + 1, $day[3]);
}

#
# Returns the current datetime in W3C format.
#
sub _get_current_datetime
{
	my $w3c = DateTime::Format::W3CDTF->new;
		
	my $time = $w3c->format_datetime(DateTime->now);
	
	$time =~ s/Z//g;
	
	return $time;
}

#
# Deletes any (devbot.tmp.xx) time tracking files found in /tmp.
#
sub _delete_datetime_logs
{
	opendir(my $tmp_dir, '/tmp') || croak "Could not open dir /tmp: $!";
	
	my @files = grep(/devbot\.tmp\.[0-9]$/, readdir($tmp_dir));
	
	closedir($tmp_dir);
	
	foreach (@files) { unlink || carp "Could not delete time tracking file '$_': $!"; }
}

1;
