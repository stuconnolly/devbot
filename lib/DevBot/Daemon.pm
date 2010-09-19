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
use DevBot::Commit;

our $VERSION = 1.0;

#
# Constructor.
#
sub new
{
	my ($this, $host, $port, $channel, $key) = @_;
	
	my $class = ref($this) || $this;
				
	my $self = {
		_host    => $host,
		_port    => $port,
		_channel => $channel,
		_key     => $key
	};
	
	bless($self, $class);
	
	return $self;
}

#
# Starts listening for commit notifications by initialising and starting the HTTP daemon.
#
sub start
{
	my $self = shift;
	
	my $daemon = HTTP::Daemon->new(
					ReuseAddr => 1,
					Listen    => 20,
					Proto     => 'tcp',
					LocalAddr => $self->{_host},
					LocalPort => $self->{_port}
					) || warn 'Failed to create HTTP daemon';
	
	while (my $connection = $daemon->accept)
	{	
		# Create a new thread to handle the connection
		#threads->create({'context' => 'list'}, \&_handle_connection, $self, $connection)->detach;
		
		while (my $request = $connection->get_request) 
		{
			my $method = $request->method;
			my $path   = $request->uri->path;

			if (($method eq 'POST') && ($path eq '/commit')) {
				my $commit = DevBot::Commit->new($request, $self->{_key});

				# Simply print the results to STDOUT and the bot will say them within the channel
				foreach ($commit->parse) { print; }
			}
			elsif ($method eq 'GET') {

				my $log = DevBot::Log::log_path('r');

				if (-s $log) {
					$connection->send_file_response($log);
				}
				else {
					$connection->send_response(HTTP::Response->new(200, 'OK', undef, 'No revisions committed today.'));
				}
			}
			else {
				$connection->send_error(RC_FORBIDDEN);
			}
		}	

		$connection->close;
		undef($connection);
	}	
}

1;
