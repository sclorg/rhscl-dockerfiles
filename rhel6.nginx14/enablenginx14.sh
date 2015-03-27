#!/bin/bash
source /opt/rh/nginx14/enable
export X_SCLS="`scl enable nginx14 'echo $X_SCLS'`"
