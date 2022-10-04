EDGEMATRIX Stream CLI
======================

#. edgestream_app
#. EDGEMATRIX Stream State Diagram
#. CLI Commands
#. CLI Result Messages

============================================================
edgestream_app
============================================================

`edgestream_app` is a CLI program of EDGEMATRIX Stream. You can use a CLI program instead of the GUI program when:

* you need to run your app remotely via ssh
* you want to try a long run test with a real IP camera
* you want to try a webrtc available on a service box
* you don't need to test actions (CLI does not come with any EDGEMATRIX Stream agent, which means no action is invoked based on callback events)

Here's the steps to launch a CLI program.

1. successfully launch your app with a GUI program with **the default passphrase** in order to create your EAP in your stream folder
2. cd to the stream folder used at 1
3. modify the location of the stream config so that it would get launched without a local RTSP server

    * e.g. `"location": "file:///mnt/nvme/toolkit_home/movies/ChuoHwy-720p-faststart.mp4"`
4. run gstd (if you use any external libraries, please make sure that /tmp/lib exists and is added to LD_LIBRARY_PATH before launching gstd)
5. run `edgestream-app` with the stream config used at 1 in your stream folder
6. for now, enter 9 to terminate your app
7. kill gstd

.. code-block:: bash

	$ cd your_successfully_tested_stream_folder
	$ gstd --daemon
	$ edgestream_app.py udp_stream_configuration.json 
	Commands Menu
		0) Toggle Debug
		1) Start Pipeline
		2) Stop Pipeline
		3) List Recordings
		4) Remove Recordings
		5) Get Status
		6) Get Stats
		7) Start Webrtc
		8) Stop Webrtc
		9) Terminate
		10) Seek Time

	Enter command: 9
	Received message from Edgestream:{'msg_id': 9, 'cmd_name': 'terminate', 'return_code': 0, 'result': 'Success'}
	$ gstd --kill

============================================================
EDGEMATRIX Stream State Diagram
============================================================

Before showing each command, you need to understand the state diagram of EDGEMATRIX Stream.

    .. image:: images/cli/EDGEMATRIX_Stream_state_diagram.png
       :align: center

Here is the description of each state:

* NULL: EDGEMATRIX Stream entities are created and configured, but there are no pipelines created in GstD.
* RUNNING: In this state, pipeline is playing and outputting buffers. Entering this state starts the MediaMonitor for each entity
* FAILLED: This state is reached by a Python error in the signal_callback or a GStreamer Error. Only the affected entities will stop running. The user must manually call stop_pipeline and then play_pipeline in order to recover the missing EdgeStream functionalities.
* TERMINATED: All entities are cleared and the application terminates.

============================================================
CLI Commands
============================================================

Commands and their availability depending on the state machine's current state are shown in the next table:

======================== ===================================================
Command                  Availability                                                       
======================== ===================================================
toggle_debug	         NULL(except for the debug display)*, RUNNING
start_pipeline	         NULL
stop_pipeline	         RUNNING, FAILED
list_recordings	         ANY
remove_recordings	     ANY
status	                 ANY
stats	                 ANY
start_webrtc	         RUNNING
start_webrtc (from file) ANY
stop_webrtc	             RUNNING
stop_webrtc (from file)  ANY
terminate	             ANY
seek_time	             ANY (EXPERIMENTAL)
======================== ===================================================

If a command is requested in a state where it isn't available, the application will return an error message specifying the reason why that command can't be executed.

--------------------------------
start_webrtc
--------------------------------

You can use this `PubNub Demo Page <https://www.pubnub.com/developers/demos/webrtc/launch/>`_ for a webrtc communication. The number shown as `your phone number` is the `PubNub Demo ID` you are going to connect to from your EDGEMATRIX Stream. In the case below, it is 223. You can choose Device ID as you like.

    .. image:: images/cli/pubnub_demo.png
       :align: center

If you want to try a P2P connection beyond your local network, then, you need to fill out xirsys related fields. Go to the `Xirsys website <https://xirsys.com/>`_, then sign up, and log in to find your API credentials. You can use the Development plan for free.

There is one know restriction. You can not access from a mobile browser because the demo website is old.

============================================================
CLI Result Messages
============================================================

This section shows the message management used by EDGEMATRIX Stream CLI to notify execution results or behavior notification.

--------------------------------
Command result message
--------------------------------

This result message is returned after sending a command to EDGEMATRIX Stream.

.. code-block:: python

	{'msg_id': MSG_ID, 'cmd_name': CMD_NAME', 'return_code': RETURN_CODE, 'result': MESSAGE}

* MSG_ID: Message ID passed to EDGEMATRIX Stream as a part of a command to identify each one
* CMD_NAME: Command name by which was generated the result message.
* RETURN_CODE: Return state of command execution.

	* 0: Success
	* -1: Failure MESSAGE: Custom returned message after executing the Command.

--------------------------------
Result message available
--------------------------------

`edgestream_app` generates each message_id according to each command type.

* Toggle Debug

.. code-block:: python

	{'msg_id': 0, 'cmd_name': 'toggle_debug', 'return_code': 0, 'result': 'Success'}

* Start Pipeline

.. code-block:: python

	{'msg_id': 1, 'cmd_name': 'start_pipeline', 'return_code': 0, 'result': 'Success'}

* Stop Pipeline

.. code-block:: python

	{'msg_id': 2, 'cmd_name': 'stop_pipeline', 'return_code': 0, 'result': 'Success'}

* List Recordings

.. code-block:: python

	{'msg_id': 3, 'cmd_name': 'list_recordings', 'return_code': 0, 'result': ['video_name.mp4']}

* Remove Recordings

.. code-block:: python

	{'msg_id': 4, 'cmd_name': 'remove_recordings', 'return_code': 0, 'result': 'Success'}

* Get Status

.. code-block:: python

	{'msg_id': 5, 'cmd_name': 'status', 'return_code': 0, 'result': {'edgestream': 'RUNNING', 'webrtc': []}}

* Get Stats

.. code-block:: python

	{'msg_id': 6, 'cmd_name': 'stats', 'return_code': 0, 'result': {'rtspt___170.93.143.139_rtplive_1701519c02510075004d823633235daa': {'fps': 15.953, 'bps': 8168.025, 'latency_stats': 18020653681}, 'userid_deviceid_stream0_encodeh264': {'fps': 15.9, 'bps': 1552418.29}, 'userid_deviceid_stream0_encodevp8': {'fps': 14.886, 'bps': 704613.184}, 'userid_deviceid_stream0_encodevp9': {'fps': 15.959, 'bps': 788095.017}, 'CPU': {'n_cores': 6, 'general_cpu_usage': 6.4, 'memory_usage': 15.5, 'disk_usage': 83.6, 'cores_usage': [{'core_name': 'Core 0', 'core_usage': 4.0}, {'core_name': 'Core 1', 'core_usage': 15.7}, {'core_name': 'Core 2', 'core_usage': 13.0}, {'core_name': 'Core 3', 'core_usage': 0.0}, {'core_name': 'Core 4', 'core_usage': 4.0}, {'core_name': 'Core 5', 'core_usage': 1.0}], 'temperature_celsius': []}, 'JETSON': {}}}

* Start Webrtc

.. code-block:: python

	{'msg_id': 7, 'cmd_name': 'start_webrtc', 'return_code': 0, 'result': 'Success'}

* Stop Webrtc

.. code-block:: python

	{'msg_id': 8, 'cmd_name': 'stop_webrtc', 'return_code': 0, 'result': 'Success'}

* Terminate

.. code-block:: python

	{'msg_id': 9, 'cmd_name': 'terminate', 'return_code': 0, 'result': 'Success'}

* Seek Time (EXPERIMENTAL)

.. code-block:: python

	{'msg_id': 10, 'cmd_name': 'seek_time', 'return_code': 0, 'result': 'Success'}

--------------------------------
Result Error Messages
--------------------------------

* Unplayable video

.. code-block:: python

	{'msg_id': 7, 'cmd_name': 'start_webrtc', 'return_code': -1, 'result': "Error: The file 'video.mp4' is not playable file"}

* No Internet access and reconnection disabled

.. code-block:: python

	{'msg_id': -1, 'cmd_name': 'error', 'return_code': -1, 'result': "Closing Webrtc entity {ID} , it does not access network and reconnection is disabled"}

* No Internet access and reconnection lineal

.. code-block:: python

	{'msg_id': -1, 'cmd_name': 'error', 'return_code': -1, 'result': "Webrtc entity {ID} does not access network, it tries to reconnect lineally"}

* No Internet access and reconnection exponentially

.. code-block:: python

	{'msg_id': -1, 'cmd_name': 'error', 'return_code': -1, 'result': "Webrtc entity {ID} does not access network, it tries to reconnect exponentially"}

* WebRTC pipeline already exists

.. code-block:: python

	{'msg_id': 7, 'cmd_name': 'start_webrtc', 'return_code': -1, 'result': 'Error: There is already a Webrtc pipeline with client ID XYZ'}

* Invalid bitrate in WebRTC params

.. code-block:: python

	{'msg_id': 7, 'cmd_name': 'start_webrtc', "return_code": -1, "result": "Error: Invalid bitrate: 'bitrate' must be numeric and positive."}

* Invalid value error in signal callback

.. code-block:: python

	{'msg_id': -1, 'cmd_name': 'error', 'return_code': -1, 'result': {'error_message': 'SignalCB Fatal Error: app-specific-message'}}
