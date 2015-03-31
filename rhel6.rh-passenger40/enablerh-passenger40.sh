#!/bin/bash
source /opt/rh/rh-passenger40/enable
source /opt/rh/rh-ruby22/enable
export X_SCLS="`scl enable rh-passenger40 rh-ruby22 'echo $X_SCLS'`"
