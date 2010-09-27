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
use HTTP::Request;
use DevBot::Log;
use DevBot::Issues;
use DevBot::Config;
use Digest::HMAC_MD5;

our $VERSION = '1.0';

use constant GC_POST_COMMIT_HMAC_HEADER => 'Google-Code-Project-Hosting-Hook-Hmac';

#
# Constructor.
#
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
		my $hmac = Digest::HMAC_MD5->new($DevBot::Daemon::COMMIT_KEY);
	
		$hmac->add($self->{_request}->content);

		return undef if ($hmac->hexdigest != $self->{_request}->header(GC_POST_COMMIT_HMAC_HEADER));
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
		
	foreach (@{$data->{revisions}})
	{			
		my $url = DevBot::Project::create_revision_url($_->{revision});
		
		my $word = ($_->{path_count} > 1) ? 'files' : 'file';
		
		my $message = sprintf("( %s ): r%d committed by %s (%d %s modified)", $url, $_->{revision}, $_->{author}, $_->{path_count}, $word);
		
		log_m($message, 'r');
								
		push(@messages, "${message}\n");
	}
	
	return @messages;
}

1;