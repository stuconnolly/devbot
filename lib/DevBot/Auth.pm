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

package DevBot::Auth;

use strict;
use warnings;

use Digest::HMAC_MD5;

our $VERSION = '1.0';

#
# DevBot message hash header
#
use constant DEVBOT_MESSAGE_HASH_HEADER => 'DevBot-Message-Hash';

#
# Google Code HMAC header
#
use constant GC_POST_COMMIT_HMAC_HEADER => 'Google-Code-Project-Hosting-Hook-Hmac';

#
# Authenticates the supplied message request against the supplied key.
#
sub authenticate_message_request
{
	my ($request, $key) = @_;
	
	if (defined($request->header(DEVBOT_MESSAGE_HASH_HEADER))) {
		return _authenticate_string($request->content, $key, $request->header(DEVBOT_MESSAGE_HASH_HEADER));
	}
}

#
# Authenticates the supplied commit request against the supplied key.
#
sub authenticate_commit_request
{
	my ($request, $key) = @_;
	
	if (defined($request->header(GC_POST_COMMIT_HMAC_HEADER))) {
		return _authenticate_string($request->content, $key, $request->header(GC_POST_COMMIT_HMAC_HEADER));
	}
}

#
# Authenticates the supplied string using the supplied details.
#
sub _authenticate_string
{
	my ($string, $key, $hash) = @_;
	
	my $hmac = Digest::HMAC_MD5->new($key);

	$hmac->add($string);

	return ($hmac->hexdigest eq $hash);
}

1;
