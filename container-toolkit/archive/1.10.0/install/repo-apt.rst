Setup the package repository and the GPG key:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
         && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
         && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
               sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
               sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

.. note::

   To get access to ``experimental`` features and access to release candidates, you may want to add the ``experimental`` branch to the repository listing:

   .. code-block:: console

      $  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
            && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
            && curl -s -L https://nvidia.github.io/libnvidia-container/experimental/$distribution/libnvidia-container.list | \
               sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
               sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

.. note::
   For version of the NVIDIA Container Toolkit prior to ``1.6.0``, the ``nvidia-docker`` repository should be used instead of the
   ``libnvidia-container`` repositories above.

.. note::
   Note that in some cases the downloaded list file may contain URLs that do not seem to match the expected value of ``distribution`` which is expected
   as packages may be used for all compatible distributions.
   As an examples:

      * For ``distribution`` values of ``ubuntu20.04`` or ``ubuntu22.04`` the file will contain ``ubuntu18.04`` URLs
      * For a ``distribution`` value of ``debian11`` the file will contain ``debian10`` URLs

.. note::
   If running ``apt update`` after configuring repositories raises an error regarding a conflict in the Signed-By option, see the :ref:`relevant troubleshooting section<conflicting_signed_by-1.10.0>`.
