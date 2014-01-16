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

package DevBot::Config;

use strict;
use warnings;

use Carp;
use File::Spec;
use Config::File;

our $VERSION = '1.00';

#
# Returns the config hash for the supplied config filename.
#
sub get
{
	my $config_file;
	my $filename = shift;
	
	my $conf_path = File::Spec->catdir($DevBot::Utils::ROOT_DIR, 'conf');
	
	# Check if we were supplied an actual filename
	return _read_config_file($conf_path, $filename) if -e File::Spec->catfile($conf_path, $filename);

	opendir(CONFIG_DIR, $conf_path);
	
	my @files = grep(/${filename}.*\.conf$/, readdir(CONFIG_DIR));
	
	closedir(CONFIG_DIR);
	
	croak 'No config files found' unless @files > 0;
	
	if (@files == 1) {
		$config_file = $files[0];
	}
	else {
		foreach (@files) 
		{
			if ($_ ne "${filename}.conf") {
				$config_file = $_;
				last;
			}
		}
	}
			
	return _read_config_file($conf_path, $config_file);
}

sub _read_config_file
{
	my ($path, $file) = @_;

	return Config::File::read_config_file(File::Spec->catfile($path, $file));
}

1;
