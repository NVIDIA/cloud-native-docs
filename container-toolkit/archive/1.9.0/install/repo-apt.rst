Setup the package repository and the GPG key:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
         && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
         && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

.. note::

   To get access to ``experimental`` features and access to release candidates, you may want to add the ``experimental`` branch to the repository listing:

   .. code-block:: console

      $ curl -s -L https://nvidia.github.io/libnvidia-container/experimental/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list


.. note::
   For version of the NVIDIA Container Toolkit prior to ``1.6.0``, the ``nvidia-docker`` repository should be used instead of the
   ``libnvidia-container`` repositories above.
