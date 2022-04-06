.. Date: August 10 2020
.. Author: pramarao

.. _migration-1.0-1.9.0:

Migration from ``nvidia-docker`` 1.0
`````````````````````````````````````

If you had never been using ``nvidia-docker`` 1.0, then you may skip this section and proceed to getting started below for your Linux distribution. 

Version 1.0 of ``nvidia-docker`` must be cleanly removed before continuing. You must stop and remove all containers started with ``nvidia-docker`` 1.0.

On Ubuntu distributions:

.. code-block:: console

    $ docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f

 .. code-block:: console
    
    $ sudo apt-get purge nvidia-docker

On CentOS distributions:

.. code-block:: console

    $ docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f

 .. code-block:: console
    
    $ sudo yum remove nvidia-docker
