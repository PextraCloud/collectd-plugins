#!/usr/bin/perl
# Copyright (C) 2025 Pextra Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
use strict;
use warnings;

my $hostname = $ENV{COLLECTD_HOSTNAME} // `hostname --fqdn`;
chomp $hostname;
my $interval = $ENV{COLLECTD_INTERVAL} // 10;

sub error {
	print STDERR "@_\n";
}

my $virsh_check = `which virsh`;
if ($? != 0) {
	error("virsh unusable");
	exit 1;
}

my @pools = split /\n/, `virsh -c qemu:///system pool-list --name`;
foreach my $pool (@pools) {
	$pool =~ s/\s+//g;

	my $info = `virsh  -c qemu:///system pool-info --bytes $pool`;
	my ($capacity) = $info =~ /Capacity:\s+(\S+)/;
	my ($allocation) = $info =~ /Allocation:\s+(\S+)/;
	my ($available) = $info =~ /Available:\s+(\S+)/;

	if (!defined($capacity) || !defined($allocation) || !defined($available)) {
		error("Failed to get pool info for $pool");
		next;
	}

	my $percent_used = sprintf("%.2f", $allocation / $capacity * 100);
	my $percent_free = sprintf("%.2f", $available / $capacity * 100);

	print "PUTVAL $hostname/libvirt-pools-$pool/gauge-capacity interval=$interval N:$capacity\n";
	print "PUTVAL $hostname/libvirt-pools-$pool/gauge-used interval=$interval N:$allocation\n";
	print "PUTVAL $hostname/libvirt-pools-$pool/gauge-free interval=$interval N:$available\n";
	print "PUTVAL $hostname/libvirt-pools-$pool/percent-used interval=$interval N:$percent_used\n";
	print "PUTVAL $hostname/libvirt-pools-$pool/percent-free interval=$interval N:$percent_free\n";
}
