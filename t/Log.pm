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

use Cwd;
use Test::More;

use base 'Test::Class';

BEGIN 
{ 
	use_ok('DevBot::Log');
	use_ok('DevBot::Utils');
	use_ok('File::Spec');
	use_ok('File::Path');
	use_ok('Carp');
}

sub startup : Test(startup)
{
	my $self = shift;

	$DevBot::Log::LOGGING = 1;

	my $log_path = File::Spec->catfile($DevBot::Utils::ROOT_DIR, 'logs');

    $self->{log_path} = $log_path;

	if (!-d $log_path) {

		mkdir($log_path);

		diag('Creating log directory = ' . $log_path);
	}
}

sub test_logging_issue_message : Test
{
	log_m('Test issue message', 'i');

	my $file_content = _get_log_file_content('i');

	isnt(index($file_content, 'Test issue message'), -1, 'Issues log file contains test message');
}

sub test_logging_revision_message : Test
{
	log_m('Test revision message', 'r');

	my $file_content = _get_log_file_content('r');

	isnt(index($file_content, 'Test revision message'), -1, 'Revision log file contains test message');
}

sub _get_log_file_content
{
	my $content;

	my $log_file = DevBot::Log::log_path(shift);

	open(my $file, $log_file) || croak $!;

	chomp($content = <$file>);
	
	close($file);

	return $content;
}

sub shutdown : Test(shutdown)
{
	my $log_path = shift->{log_path};

	if (-e $log_path) {
		File::Path::remove_tree($log_path);

		diag('Removing log directory = ' . $log_path);
	}
}

1;
