Installing Docker CE
------------------------
For installing Docker CE, follow the official `instructions <https://docs.docker.com/engine/install/>`_ for your supported Linux distribution. 
For convenience, the documentation below includes instructions on installing Docker for various Linux distributions.

Migration from ``nvidia-docker`` 1.0
`````````````````````````````````````

If you had never been using ``nvidia-docker`` 1.0, then you may skip this section and proceed to getting started below for your Linux distribution. 

Version 1.0 of ``nvidia-docker`` must be cleanly removed before continuing. You must stop and remove all containers started with ``nvidia-docker`` 1.0.

On Ubuntu distributions:

.. code-block:: bash

    docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
    
    sudo apt-get purge nvidia-docker

On CentOS distributions:

.. code-block:: bash

    docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
    
    sudo yum remove nvidia-docker

.. Ubuntu instructions

.. include:: distro/ubuntu.rst

.. CentOS 8 instructions 

.. include:: distro/centos8.rst

.. RHEL 7 instructions

.. include:: distro/rhel7.rst

.. SUSE 15 instructions

.. include:: distro/suse15.rst

.. Amazon Linux instructions

.. include:: distro/amazon-linux.rst

