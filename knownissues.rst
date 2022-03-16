Known Issues
====================

=======
v2.3
=======

----------------------------------------------------------------------------------
Known Memory Leaks
----------------------------------------------------------------------------------

1. Text overlay

  The more text overlay items you use, the more memory leak is observed. One source of this leak is `font_name` of `NdOSD_FontParams`. So, please do not use it unless you really need to. We are investigating possible sources related to NvDsBatchMeta due to timings. But please note that `font_name` was mandatory until v2.2. So, a new app without `font_name` won't run on an older versions due to such a validation failure.

2. Pipeline Start/Stop

  Every time a pipeline, including a sub pipeline, is stopped, memory leak is observed. This has been known that this is cleared if `nvdsosd` is not used. As a part of our cross platform effort, we have a plan to replace `nvdsosd` with our own `emoverlay` to get rid of this leaks.

=======
v1.6.2
=======

----------------------------------------------------------------------------------
Pre processing of a primary nvinfer of a custom pipeline prevents it from running
----------------------------------------------------------------------------------

If you add an emcustom as a pre-processing of primary nvinfer, such a pipeline won't run.

It won't leave any exceptions and errors in your log.

So, until this issue is fixed, please avoid using a pre processing of a primary nvinfer 

=======
v1.1
=======

----------------------------------------------------------------------------------
A record action could hang a GStreamer daemon process if a debug window is shown
----------------------------------------------------------------------------------

When you start an EAP package with a debug window, a GStreamer Daemon process could hang when you try to stop it.
This is known that it could happen if a record action is invoked and in progress.

This would lead to some error logs and could hang an entire SDK application process.

To avoid this, you can do the followings.

    #. launch an EAP without a debug window
    #. remove a record action from a stream config

In case when an entire SDK application stops to respond, you can do the following to kill the GStreamer Daemon process.

.. code-block:: bash

  $ killall -9 -r gstd
