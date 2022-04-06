Setup the repository and the GPG key:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

.. note::

   To get access to ``experimental`` features and access to release candidates, you may want to add the ``experimental`` branch to the repository listing:

   .. code-block:: console

      $ yum-config-manager --enable libnvidia-container-experimental


.. note::
   For version of the NVIDIA Container Toolkit prior to ``1.6.0``, the ``nvidia-docker`` repository should be used instead of the
   ``libnvidia-container`` repositories above.
