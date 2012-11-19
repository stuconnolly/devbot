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

use Carp;
use HTTP::Daemon;
use HTTP::Status;
use DevBot::Auth;
use DevBot::Commit;
use DevBot::Project;

our $VERSION = '1.00';

#
# Constructor.
#
sub new
{
	my ($this, $host, $port, $gc_key, $m_key, $message) = @_;

	my $class = ref($this) || $this;

	my $self = {
		_host    => $host,
		_port    => $port,
		_gc_key  => $gc_key,
		_m_key   => $m_key,
		_message => $message
	};

	bless($self, $class);

	return $self;
}

#
# Starts listening for commit notifications and messages by initialising and starting the HTTP daemon.
#
sub run
{
	my $self = shift;

	my $daemon = HTTP::Daemon->new(
					ReuseAddr => 1,
					Listen    => 20,
					Proto     => 'tcp',
					LocalAddr => $self->{_host},
					LocalPort => $self->{_port}
					) || carp 'Failed to create HTTP daemon';

	while (my $connection = $daemon->accept)
	{
		while (my $request = $connection->get_request)
		{
			my $method = $request->method;
			my $path   = $request->uri->path;

			if (($method eq 'POST') && ($path eq '/commit')) {
				_handle_commit($connection, $request);
			}
			elsif (($method eq 'POST') && ($path eq '/message') && $self->{_message}) {
				_handle_message($connection, $request);
			}
			else {
				$connection->send_error(RC_FORBIDDEN);
			}
		}

		$connection->close;
		undef($connection);
	}
}

#
# Handle a commit via the supplied request and connection.
#
sub _handle_commit
{
	my ($self, $connection, $reuqest) = $_;

	$connection->send_response(HTTP::Response->new(RC_OK));

	# Announce the results to the channel
	foreach (DevBot::Commit->new($request, $self->{_gc_key})->parse)
	{
		DevBot::Bot::say($_) if (length);
	}
}

#
# Handle a message via the supplied request and connection.
#
sub _handle_message
{
	my ($self, $onnection, $request) = $_;

	if (DevBot::Auth::authenticate_message_request($request, $self->{_m_key})) {
		$connection->send_response(HTTP::Response->new(RC_OK));

		my $message = $request->content;

		# Strip leading and trailing whitespace
		$message =~ s/^\s+//;
		$message =~ s/\s+$//;

		$message =~ s/r([0-9]+)/DevBot::Project::create_revision_url($1)/gie;

		# Simply print the message to STDOUT and the bot will announce it to the channel
		DevBot::Bot::say($message) if (length($message));
	}
	else {
		$connection->send_response(HTTP::Response->new(RC_UNAUTHORIZED));
	}
}

1;
