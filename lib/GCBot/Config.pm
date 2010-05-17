#
#  $Id$
#  
#  devbot
#  http://dev.stuconnolly.com/svn/serveadmin/
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

package GCBot::Config;

use strict;
use warnings;

use Config::File;

use base 'Exporter';

our @EXPORT = qw(get_config);

our $VERSION = '1.0';

#
# Returns the config hash for the supplied config filename.
#
sub get_config
{
	my $filename = shift;
	my $config_file = undef;
	
	opendir(CONFIG_DIR, '../conf');
	
	my @files = grep(/${filename}.*\.conf$/, readdir(CONFIG_DIR));
	
	closedir(CONFIG_DIR);
	
	die 'No config files found' unless (@files > 0);
	
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
		
	return Config::File::read_config_file("../conf/${config_file}");
}

1;
