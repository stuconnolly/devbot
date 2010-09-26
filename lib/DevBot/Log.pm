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

use File::Spec;
use DevBot::Utils;

use base 'Exporter';

use vars qw($LOGGING $LOG_PATH);

our @EXPORT = qw(log_m);

our $VERSION = '1.00';

#
# By default don't enable logging.
#
our $LOGGING = 0;

#
# Default log path is '../logs'.
#
our $LOG_PATH = '';

#
# Log files
#
use constant ISSUE_LOG_FILE    => 'devbot-issues.log';
use constant REVISION_LOG_FILE => 'devbot-revisions.log';

#
# Logs the supplied message. The second argument should be either 'i' or 'r' to indicate which log, 
# issues or revisions.
#
sub log_m
{
	return undef unless $LOGGING;
	
	my ($message, $log) = @_;
			
	open(LOG, '>>', log_path($log)) || die $!;
	
	my @day = localtime(time);

	$message = sprintf("[%02d-%02d-%04d %02d:%02d:%02d] %s\n", $day[3], $day[4] + 1, $day[5] + 1900, $day[2], $day[1], $day[0], $message);
	
	print LOG $message;
	
	close(LOG);
}

#
# Returns the path of the supplied log file.
#
sub log_path
{
	my $log = shift;
	
	return File::Spec->catfile((length($LOG_PATH)) ? ($LOG_PATH) : ($DevBot::Utils::ROOT_DIR, 'logs'), _log_filename($log));
}

#
# Returns the current log filename.
#
sub _log_filename
{
	my $log = shift;
	
	my @day = localtime(time);
	
	return sprintf('%02d-%02d-%04d-%s', $day[3], $day[4] + 1, $day[5] + 1900, ($log eq 'i') ? ISSUE_LOG_FILE : REVISION_LOG_FILE);
}

1;
