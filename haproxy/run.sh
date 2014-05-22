#!/bin/bash

/usr/sbin/incrond

exec supervisord -n
