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

package DevBot::Commit;

use strict;
use warnings;

use JSON;
use Text::Wrap;
use HTTP::Request;
use DevBot::Log;
use DevBot::Auth;
use DevBot::Issues;
use DevBot::Config;
use DevBot::Project;

our $VERSION = '1.0';

#
# Truncate commit messages at x lines
#
use constant MESSAGE_TRUNCATE => 4;

sub new
{
	my ($this, $request, $key) = @_;

	my $class = ref($this) || $this;

	my $self = {
		_request => $request,
		_key     => $key
	};

	bless($self, $class);

	return $self;
}

#
# Parses this instances JSON data.
#
sub parse
{
	my $self = shift;

	# If required authenticate the request before proceeding
	if ($self->{_key}) {
		return undef if (!DevBot::Auth::authenticate_commit_request($self->{_request}, $self->{_key}));
	}

	my $json = JSON->new->allow_nonref;

	return $self->_format($json->decode($self->{_request}->content));
}

#
# Formats the supplied data into a readable commit message.
#
sub _format
{
	my ($self, $data) = @_;

	my @messages = ();
	my @new_lines = ();
	my @final_lines = ();

	foreach (@{$data->{revisions}})
	{
		my $url = DevBot::Project::create_revision_url($_->{revision});

		my $message = sprintf("( %s ): r%d committed by %s (%d %s modified)", $url, $_->{revision}, $_->{author}, $_->{path_count}, $_->{path_count} > 1 ? 'files' : 'file');

		log_m($message, 'r');

		push(@messages, "${message}:");

		# Replace occurrences of #XXX with a URL to the issue
		$_->{message} =~ s/#([0-9]+)/DevBot::Project::create_issue_url($1) . ' '/gie;

		# Replace occurrences of issue [#] with a URL to the issue
		$_->{message} =~ s/issue[\s+#]([0-9]+s)/DevBot::Project::create_issue_url($1) . ' '/gie;

		# Replace occurrences of rXXXX with a URL to the revision
		$_->{message} =~ s/r([0-9]+)/DevBot::Project::create_revision_url($1) . ' '/gie;

		my @lines = split(/\n+/, $_->{message});

		foreach (@lines)
		{
			# Trim leading and trailing whitespace
			s/^\s+//;
			s/\s+$//;

			# Only include non-blank lines
			push(@new_lines, $_) if (length($_));
		}

		# Wrap lines at 128 chars
		$Text::Wrap::columns = 128;

		foreach (@new_lines)
		{
			my @lines = split('\n', wrap('', '', $_));

			push(@final_lines, $_) foreach (@lines);
		}

		# Truncate commit messages
		if (@final_lines > MESSAGE_TRUNCATE) {

			for (my $i = 0; $i < MESSAGE_TRUNCATE; $i++)
			{
				my $line = $final_lines[$i];

				$line .= ' ...[truncated]' if ($i == (MESSAGE_TRUNCATE - 1));

				push(@messages, $line);
			}
		}
		else {
			push(@messages, @final_lines);
		}
	}

	return @messages;
}

1;
