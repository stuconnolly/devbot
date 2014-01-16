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

package t::Project;

use strict;
use warnings;

use Test::More;

use base 'Test::Class';

BEGIN 
{ 
	use_ok('DevBot::Project');
}

sub test_system_is_correct : Test
{
	is(DevBot::Project::system(), 'github', 'System name is correct');
}

sub test_repo_is_correct : Test
{
	is(DevBot::Project::name(), 'test_repo', 'Repo name is correct');
}

sub test_username_is_correct : Test
{
	is(DevBot::Project::username(), 'test_username', 'Username is correct');
}

sub test_passowrd_is_correct : Test
{
	is(DevBot::Project::password(), 'test_password', 'Password is correct');
}

sub test_issue_url_is_correct : Test
{
	is(DevBot::Project::issue_url(), 'http://example.com/issues/%d/%d', 'Issue URL is correct');
}

sub test_revision_url_is_correct : Test
{
	is(DevBot::Project::revision_url(), 'http://example.com/commits/%d', 'Revision URL is correct');
}

sub test_create_issue_url_with_comment : Test
{
	is(DevBot::Project::create_issue_url(1234, 10), 'http://example.com/issues/1234/10', 'Issue URL with comment is correct');
}

sub test_create_issue_url_with_no_comment : Test
{
	is(DevBot::Project::create_issue_url(1234, 0), 'http://example.com/issues/1234', 'Issue URL with without comment is correct');
}

sub test_create_revision_url : Test
{
	is(DevBot::Project::create_revision_url(1234), 'http://example.com/commits/1234', 'Revision URL is correct');
}

1;
