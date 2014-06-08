#!/usr/bin/env python

import json, sys, argparse
from argparse import RawTextHelpFormatter

description="""Description:
  A simple script to extract a port from docker inspect

  This script takes an 'internal' docker port and the results of 
  `docker inspect $CID` and outputs the corresponding port on the host"""

epilog="""Examples:
  sudo docker inspect <container> | {name} 8080
  sudo docker inspect <container> | {name} 8080/udp""".format(name=sys.argv[0])

parser = argparse.ArgumentParser(description=description, epilog=epilog, formatter_class=RawTextHelpFormatter)
parser.add_argument('port', help="Port number within container; defaults to tcp")
args = parser.parse_args()
target_port = args.port if '/' in args.port else "%s/tcp" % args.port

docker_details=json.loads(sys.stdin.read())[0]
port_details=docker_details.get('HostConfig').get('PortBindings')
requested_port=port_details.get(target_port)[0].get('HostPort')
print requested_port
