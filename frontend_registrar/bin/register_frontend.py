#!/usr/bin/env python

import argparse
import os, re, cStringIO

parser = argparse.ArgumentParser(description="Tool for updating haproxy.cfg")
parser.add_argument('command', choices=['update'])
parser.add_argument('file')
args = parser.parse_args()

import etcd

def getEtcdClient():
  (host, port) = os.environ.get('ETCD_PEERS', ':').split(':')
  if (not host and not port):
    client = etcd.Client()
  elif ( host and port ):
    client = etcd.Client(host=host, port=int(port))
  else:
    raise ValueError("Bad parameters for etcd connection")
  return client

def getEtcdNode(key):
  client = getEtcdClient()
  return Node(**client.read(key).__dict__)

class Node(object):
  def __init__(self, createdIndex, modifiedIndex, key, nodes=None, value=None, expiration=None, ttl=None, dir=False, **kwargs):
    self.createdIndex = createdIndex
    self.modifiedIndex = modifiedIndex
    self.key = key
    self.value = value
    self.expiration = expiration
    self.ttl = ttl
    self.dir = dir
    self.nodes = map(lambda n: Node(**n), nodes) if nodes != None else []
    self.short_key = key.split('/')[-1]
  def ls(self):
    if self.dir and not self.nodes:
      client = getEtcdClient()
      self.nodes = [Node(**n) for n in client.read(self.key, recursive=True)._children]
    return self.nodes
  def __repr__(self):
    if self.value:
      return "%s => %s" % (self.key, self.value)
    else:
      return "\n".join(node.__repr__() for node in self.ls())

import yaml

def normaliseRoute(route):
  if route == None:
    return None
  elif route == '/':
    return '*'
  else:
    route, n = re.subn(r"^\/?(([^\/*]+\/)*)([^\/*]+)\/?$", r"\1\3/*", route)
  if n == 1:
    return route
  else:
    raise ValueError("Could not normalise route '%s'.  Make sure it is syntactically valid and doesn't contain '*'" % route)

class Environment(object):
  def __init__(self, name, prefix=None, header=None, services=None):
    self.name = name
    self.prefix = prefix if prefix != None else 'www-%s' % name
    services = [] if services == None else services
    self.services = [ Service(s) for s in services ]
    self.header = header if header != None else name
  def __repr__(self):
    return self.__dict__.__repr__()

class Service(object):
  def __init__(self, details):
    details = { 'name': details } if isinstance(details, str) else details
    self.name = details.get('name')
    self.version = details.get('version', 'latest')
    self.route = normaliseRoute(details.get('route', None))
  def __repr__(self):
    return self.__dict__.__repr__()

def parseEnvironmentFile(filename):
  with open(filename, 'r') as config_file:
    config=yaml.load(config_file.read())
  if isinstance(config, list):
    environments=[Environment(**e) for e in config]
  else:
    environments=[Environment(**config)]
  return environments

def updateEtcd(environments):
  client = getEtcdClient()
  for env in environments:
    # /mayfly/environments/<name>/prefix                       => www
    # /mayfly/environments/<name>/header                       => prod
    # /mayfly/environments/<name>/routes/*                     => frontend/0.0.1
    # /mayfly/environments/<name>/services/<service>/<version> => 0
    try:
      client.delete('/mayfly/environments/%s' % env.name, recursive=True)
    except KeyError:
      pass

    client.write('/mayfly/environments/%s/prefix' % env.name, env.prefix)
    client.write('/mayfly/environments/%s/header' % env.name, env.header)
    for service in env.services:
      client.write('/mayfly/environments/%s/services/%s/%s' % (env.name, service.name, service.version), 0)
      if service.route == '/':
        client.write('/mayfly/environments/%s/routes/*' % env.name, "%s/%s" % (service.name, service.version))
      elif service.route:
        client.write('/mayfly/environments/%s/routes/%s' % (env.name, service.route), "%s/%s" % (service.name, service.version)) 

if __name__ == '__main__':
  environments = parseEnvironmentFile(args.file)
  updateEtcd(environments)
