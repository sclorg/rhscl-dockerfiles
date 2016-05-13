Perl Docker image
=================

This repository contains the source for building various versions of
the Perl application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
Users can choose between RHEL and CentOS based builder images.
The resulting image can be run using [Docker](http://docker.io).

Usage
---------------------
To build a simple [perl-sample-app](https://github.com/openshift/sti-perl/tree/master/5.16/test/sample-test-app) application,
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

*  **For RHEL based image**
    ```
    $ s2i build https://github.com/openshift/sti-perl.git --context-dir=5.16/test/sample-test-app/ openshift/perl-516-rhel7 perl-sample-app
    $ docker run -p 8080:8080 perl-sample-app
    ```

*  **For CentOS based image**
    ```
    $ s2i build https://github.com/openshift/sti-perl.git --context-dir=5.16/test/sample-test-app/ openshift/perl-516-centos7 perl-sample-app
    $ docker run -p 8080:8080 perl-sample-app
    ```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```


Repository organization
------------------------
* **`<perl-version>`**

    * **Dockerfile**

        CentOS based Dockerfile.

    * **Dockerfile.rhel7**

        RHEL based Dockerfile. In order to perform build or test actions on this
        Dockerfile you need to run the action on a properly subscribed RHEL machine.

    * **`s2i/bin/`**

        This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

        *   **assemble**

            Used to install the sources into a location where the application
            will be run and prepare the application for deployment (eg. installing
            modules, etc.).
            In order to install application dependencies, the application must contain a
            `cpanfile` file, in which the user specifies the modules and their versions.
            An example of a [cpanfile](https://github.com/openshift/sti-perl/blob/master/5.16/test/sample-test-app/cpanfile) is available within our test application.

        *   **run**

            This script is responsible for running the application, using the
            Apache web server.

        *   **usage***

            This script prints the usage of this image.

    * **`contrib/`**

        This folder contains a file with commonly used modules.

    * **`test/`**

        This folder contains the [S2I](https://github.com/openshift/source-to-image)
        test framework.

        * **`sample-test-app/`**

            A simple Perl application used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

        * **run**

            This script runs the [S2I](https://github.com/openshift/source-to-image) test framework.


Environment variables
---------------------

To set environment variables, you can place them as a key value pair into a `.sti/environment`
file inside your source code repository.

* **ENABLE_CPAN_TEST**

    Allow the installation of all specified cpan packages and the running of their tests. The default value is `false`.

* **CPAN_MIRROR**

    This variable specifies a mirror URL which will used by cpanminus to install dependencies.
    By default the URL is not specified.

* **PERL_APACHE2_RELOAD**

    Set this to "true" to enable automatic reloading of modified Perl modules.
