#!C:\Python27\python.exe
# -*- coding: utf-8 -*-
#
# Copyright (C)2008-2009 Edgewall Software
# Copyright (C) 2008 Noah Kantrowitz <noah@coderanger.net>
# All rights reserved.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at http://trac.edgewall.org/wiki/TracLicense.
#
# This software consists of voluntary contributions made by many
# individuals. For the exact contribution history, see the revision
# history and logs, available at http://trac.edgewall.org/log/.
#
# Author: Noah Kantrowitz <noah@coderanger.net>


import os
import os.path
from trac.web.main import dispatch_request

def application(environ, start_request):
    
    environ.setdefault('trac.env_path', os.path.join(os.environ['APPL_PHYSICAL_PATH'], 'trac'))
    # or
    # os.environ['TRAC_ENV'] = os.path.join(os.environ['APPL_PHYSICAL_PATH'], 'trac')
    
    os.environ['PYTHON_EGG_CACHE'] = os.path.join(os.environ['APPL_PHYSICAL_PATH'], 'python_modules', 'eggs')
    
    # fix SCRIPT_NAME & PATH_INFO
    app_virt_path = os.environ.get('APPL_VIRTUAL_PATH')
    path_info = environ.get('PATH_INFO')
    if app_virt_path and path_info:
        if path_info.startswith(app_virt_path):
            environ['PATH_INFO'] = path_info[len(app_virt_path):]
        environ['SCRIPT_NAME'] = app_virt_path

    return dispatch_request(environ, start_request)

