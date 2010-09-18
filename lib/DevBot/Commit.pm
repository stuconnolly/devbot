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
use Digest::HMAC_MD5;

our $VERSION = 1.0;

#
# Constructor.
#
sub new
{
	my ($this, $request) = @_;
	
	my $class = ref($this) || $this;
				
	my $self = {
		_request => $request,
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
	
	# Authenticate the request before proceeding
	my $hmac = Digest::HMAC_MD5->new($DevBot::Daemon::COMMIT_KEY);
	
	$hmac->add($self->{_request}->content);
	
	return undef if ($hmac->hexdigest != $self->{_request}->header('Google-Code-Project-Hosting-Hook-Hmac'));
	
	my $json = JSON->new->allow_nonref;
	
	my $data = $json->decode($self->{_request}->content);
}

1;