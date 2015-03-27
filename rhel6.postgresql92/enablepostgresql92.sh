#!/bin/bash
source /opt/rh/postgresql92/enable
export X_SCLS="`scl enable postgresql92 'echo $X_SCLS'`"
