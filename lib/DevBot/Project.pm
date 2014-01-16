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

package DevBot::Project;

use strict;
use warnings;

use DevBot::Config;

our $VERSION = '1.00';

#
# Project system constants
#
our $GC_SYSTEM = 'google';
our $GH_SYSTEM = 'github';

#
# Default project issues URLs
#
our $GC_ISSUE_URL = "http://code.google.com/p/%s/issues/detail?id=%d#c%d";
our $GH_ISSUE_URL = "https://github.com/%s/%s/issues/%d";

#
# Default project revision URLs
#
our $GC_REVISION_URL = "http://code.google.com/p/%s/source/detail?r=%d";
our $GH_REVISION_URL = "https://github.com/%s/%s/commit/%s";

#
# The system we are integrating with.
#
sub system
{
	return _get_config()->{SYSTEM};
}

#
# Returns the project's name.
#
sub name
{	
	return _get_config()->{REPO};
}

#
# The username to access the project system (if any).
#
sub username
{
	return _get_config()->{USERNAME};
}

#
# The password to access the project system (if any).
#
sub password
{
	return _get_config()->{PASSWORD};
}

#
# Returns the project's issue tracker URL.
#
sub issue_url
{
	return _get_config()->{ISSUE_URL};
}

#
# Returns the project's revision URL.
#
sub revision_url
{	
	return _get_config()->{REVISION_URL};
}

#
# Creates the URL for the supplied issue details.
#
sub create_issue_url
{
	my ($issue_id, $comment_id) = @_;
	
	my $issue_url = issue_url();
	
	my $url = $issue_url ? $issue_url : _default_issue_url();
	
	# If there's no comment ID then remove the placeholder from the URL
	$url = substr($url, 0, -3) if $comment_id == 0;
	
	return sprintf($url, $issue_id, $comment_id ? $comment_id : '');
} 

#
# Creates the URL for the supplied revision details.
#
sub create_revision_url
{	
	my $revision_url = revision_url();
	
	my $url = $revision_url ? $revision_url : _default_revision_url();
	
	return sprintf($url, shift);
}

#
# Load the project configuration file.
#
sub _get_config
{
	return DevBot::Config::get('proj');
}

#
# Returns the default issue URL depending on the project system.
#
sub _default_issue_url
{
	return &system() eq $GC_SYSTEM ? sprintf($GC_ISSUE_URL, name()) : sprintf($GH_ISSUE_URL, username(), name());
}

#
# Returns the default revision URL depending on the project system.
#
sub _default_revision_url
{
	return &system() eq $GC_SYSTEM ? sprintf($GC_REVISION_URL, name()) : sprintf($GH_REVISION_URL, username(), name());
}

1;
