#!/bin/bash
source /opt/rh/httpd24/enable
export X_SCLS="`scl enable httpd24 'echo $X_SCLS'`"
