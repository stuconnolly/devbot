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

use vars qw($GC_HOSTING_DOMAIN);

our $VERSION = '1.00';

#
# Google Code hosting domain
#
our $GC_HOSTING_DOMAIN = 'code.google.com';

#
# Returns the project's name.
#
sub name
{
	my $conf = DevBot::Config::get('gc');
	
	return $conf->{GC_PROJECT};
}

#
# Returns the project's issue tracker URL.
#
sub issue_url
{
	my $conf = DevBot::Config::get('gc');
	
	return $conf->{GC_ISSUE_URL};
}

#
# Returns the project's revision URL.
#
sub revision_url
{
	my $conf = DevBot::Config::get('gc');
	
	return $conf->{GC_REVISION_URL};
}

#
# Creates the URL for the supplied issue details.
#
sub create_issue_url
{
	my ($issue_id, $comment_id) = @_;
	
	my $project = name;
	my $issue_tracker = issue_url;
	
	my $url = ($issue_tracker) ? $issue_tracker : "http://${GC_HOSTING_DOMAIN}/p/${project}/issues/detail?id=%d#c%d";
	
	# If there's no comment ID then remove the placeholder from the URL
	if ($comment_id == 0) {
		$url = substr($url, 0, -3);
	}
	
	return sprintf($url, $issue_id, ($comment_id) ? $comment_id : '');
} 

#
# Creates the URL for the supplied revision details.
#
sub create_revision_url
{
	my $issue_id = shift;
	
	my $project = name;
	my $revision_url = revision_url;
	
	my $url = ($revision_url) ? $revision_url : "http://${GC_HOSTING_DOMAIN}/p/${project}/source/detail?r=%d";
	
	return sprintf($url, $issue_id);
}

1;
