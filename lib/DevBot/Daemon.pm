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

package DevBot::Daemon;

use strict;
use warnings;

use HTTP::Daemon;
use HTTP::Status;

our @EXPORT = qw(run);

our $VERSION = 1.0;

#
# Constructor.
#
sub new
{
	my ($this, $host, $port) = @_;
	
	my $class = ref($this) || $this;
				
	my $self = {
		_host => $host,
		_port => $port
	};
	
	bless($self, $class);
	
	return $self;
}

#
# Start listening for commit notifications.
#
sub run
{
	my $self = shift;
	
	my $daemon = HTTP::Daemon->new(
					Blocing   => 0,
					LocalAddr => $self->{_host},
					LocalPort => $self->{_port}
					);
			
	if ($daemon) {
		while (my $connection = $daemon->accept)
		{
			while (my $request = $connection->get_request) 
			{
				my $method = $request->method;
				my $path   = $request->uri->path;
				
				if (($method eq 'GET') && ($path eq '/')) {
					
					# Display commit log
					#$connection->send_file_response();
				}
				elsif (($method eq 'POST') && ($path eq '/commit')) {
					
				}
				else {
					$connection->send_error(RC_FORBIDDEN);
				}
			}

			$connection->close;
			undef($connection);
		}
	}
}

1;