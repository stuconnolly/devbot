#! /usr/bin/perl

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

use strict;
use warnings;

use lib '../lib';

use Cwd;
use Carp;
use File::Spec;
use Test::More tests => 19;
use Test::Class::Load '../t';

our $TEST_CONFIG = 
"SYSTEM                = github
 REPO                  = test_repo
 ISSUE_UPDATE_INTERVAL = 60
 USERNAME              = test_username
 PASSWORD              = test_password
 ISSUE_URL             = http://example.com/issues/%d/%d
 REVISION_URL          = http://example.com/commits/%d
 COMMIT_KEY            = 12345678910";

$DevBot::Utils::ROOT_DIR = substr(getcwd, 0, rindex(getcwd, '/'));

diag('Root directory = ' . $DevBot::Utils::ROOT_DIR);	

my $conf_path = File::Spec->catfile($DevBot::Utils::ROOT_DIR, 'conf', 'proj.test.conf');

_create_test_config_file($conf_path);

Test::Class->runtests();

_delete_test_config_file($conf_path);

sub _create_test_config_file
{
	my $file = shift;

	if (!-e $file) {
		diag('Creating test config file = ' . $file);

		open(my $fh, '>', $file) || croak $!;
		
		print $fh "$TEST_CONFIG\n";
		
		close($fh);
	}
}

sub _delete_test_config_file
{
	my $file = shift;

	diag('Removing test config file = ' . $file);

	unlink $file if -e $file;
}
