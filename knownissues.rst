Known Issues
====================

#. A record action could hang a GStreamer daemon process if a debug window is shown

==================================================================================
A record action could hang a GStreamer daemon process if a debug window is shown
==================================================================================

When you start an EAP package with a debug window, a GStreamer Daemon process could hang when you try to stop it.
This is known that it could happen if a record action is invoked and in progress.

This would lead to some error logs and could hang an entire SDK application process.

To avoid this, you can do the followings.

    #. launch an EAP without a debug window
    #. remove a record action from a stream config

In case when an entire SDK application stops to respond, you can do the following to kill the GStreamer Daemon process.

.. code-block:: bash

  $ killall -9 -r gstd
