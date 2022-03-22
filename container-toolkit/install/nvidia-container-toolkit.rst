.. Date: December 18 2020
.. Author: pramarao


First, setup the package repository and GPG key:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
                && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    .. tab:: CentOS / RHEL

        .. code-block:: console

            $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo



Now, install the NVIDIA Container Toolkit:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ sudo apt-get update \
                && sudo apt-get install -y nvidia-container-toolkit

    .. tab:: CentOS / RHEL

        .. code-block:: console

            $ sudo dnf clean expire-cache \
                && sudo dnf install -y nvidia-container-toolkit


.. note::

    For version of the NVIDIA Container Toolkit prior to ``1.6.0``, the ``nvidia-docker`` repository should be used and the ``nvidia-container-runtime`` package
    should be installed instead. This means that the package repositories should be set up as follows:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
                && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    .. tab:: CentOS / RHEL

        .. code-block:: console

            $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo


The installed packages can be confirmed by running:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ sudo apt list --installed *nvidia*
