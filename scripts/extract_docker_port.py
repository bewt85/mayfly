#!/usr/bin/env python

import json, sys, argparse

parser = argparse.ArgumentParser()
parser.add_argument('port')
args = parser.parse_args()
target_port = args.port if '/' in args.port else "%s/tcp" % args.port

docker_details=json.loads(sys.stdin.read())[0]
port_details=docker_details.get('HostConfig').get('PortBindings')
requested_port=port_details.get(target_port)[0].get('HostPort')
print requested_port
