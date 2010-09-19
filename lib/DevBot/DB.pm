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

package DevBot::DB;

use strict;
use warnings;

use DBI;
use DevBot::Config;

use base 'Exporter';

our @EXPORT = qw(db_connection query);

our $VERSION = 1.00;

our $DB;

#
# Returns the database connection.
#
sub db_connection
{
	return $DB if $DB;
	
	my $conf = DevBot:::Config::get_config('db');
	
	my $dbs = $conf->{DSN} || 'mysql';
	my $db_name = $conf->{DATABASE} || 'devbot';
	my $db_host = $conf->{HOST} || 'localhost';
	my $db_port = $conf->{PORT} || '3306';
	my $db_user = $conf->{USER} || 'root';
	my $db_password = $conf->{PASSWORD} || '';

	my $db_dsn = "DBI:${dbs}:database=${db_name};host=${db_host};port=${db_port}" || die $DBI::errstr;
	
	$DB = DBI->connect($db_dsn, $db_user, $db_password, {RaiseError => 1, AutoCommit => 1});
    
	return $DB;
}

#
# Convenience mentod for getting the results of the supplied query.
#
sub query
{
	my $query = shift;
	my @args = @_;
	
	my $db = db_connection;

	my $result = $db->prepare($query) || die $db->errstr;

	$result->execute(@args) || die $result->errstr;

	return $result;
}

1;
