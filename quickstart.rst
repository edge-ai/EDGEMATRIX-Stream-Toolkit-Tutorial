Quick Start
=====================

#. Update to the latest version

    #. Check the current version
    #. Run an update script

#. Prepare a template app

#. Create a new EAP by copying from a template EAP

    #. runtoolkit and sdk_home
    #. Launch the EDGEMATRIX Stream Toolkit application
    #. Create a new EAP
    #. Select the EAP

#. Validate the new EAP

    #. Open a validation dialog
    #. Run a validation
    #. Use your own sample siginal to validate

#. Test the new EAP

    #. Execute, Choose a stream and Create an EAP package
    #. Play a pipeline
    #. Stop a pipeline
    #. Movie files made by record actions

--------------------------------------------------------
Update to the latest version
--------------------------------------------------------

Before starting, please update to the latest version.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Check the current version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the following command to check the currently installed version.

.. code-block:: bash

  $ apt show python3-edgematrix-stream-toolkit 
  Package: python3-edgematrix-stream-toolkit
  Version: 1.3.0b3-1
  Priority: optional
  Section: python
  Source: edgematrix-stream-toolkit
  Maintainer: Takenori Sato <tsato@edgematrix.com>
  Installed-Size: 272 kB
  Depends: python3-boto3, python3-gpg, python3-pycryptodome, python3-pysnmp4, python3-requests, python3:any (>= 3.3.2-2~), edgematrix-stream (>= 1.7.0), edgematrix-stream (<< 1.8.0), python3-emisecurity (>= 1.1.0), python3-emisecurity (<< 1.2.0)
  Download-Size: 40.0 kB
  APT-Manual-Installed: yes
  APT-Sources: https://apt.console.edgematrix.com/airbase/apt/debian bionic/main arm64 Packages
  Description: EDGEMATRIX Stream Toolkit allows an AI model developer to build, test, and package an EAP (EDGEMATRIX Stream Application Package).

In the example above, the version is 1.3.0b3-1.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Run an update script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the following command to try updating to the latest version.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ cd bin/
  /mnt/nvme/toolkit_home/bin$ ./update_toolkit.sh 
  [sudo] password for nvidia: 

  a local proxy is launching...
  a local proxy is launching...
  a local proxy is launching...
  Get:1 file:/var/cuda-repo-10-0-local-10.0.326  InRelease
  Ign:1 file:/var/cuda-repo-10-0-local-10.0.326  InRelease
  Get:2 file:/var/visionworks-repo  InRelease
  Ign:2 file:/var/visionworks-repo  InRelease
  Get:3 file:/var/visionworks-sfm-repo  InRelease
  Ign:3 file:/var/visionworks-sfm-repo  InRelease
  Get:4 file:/var/visionworks-tracking-repo  InRelease
  Ign:4 file:/var/visionworks-tracking-repo  InRelease
  Get:5 file:/var/cuda-repo-10-0-local-10.0.326  Release [574 B]
  Get:6 file:/var/visionworks-repo  Release [1,999 B]
  Get:7 file:/var/visionworks-sfm-repo  Release [2,003 B]
  Get:5 file:/var/cuda-repo-10-0-local-10.0.326  Release [574 B]
  Get:8 file:/var/visionworks-tracking-repo  Release [2,008 B]
  Get:6 file:/var/visionworks-repo  Release [1,999 B]                            
  Get:7 file:/var/visionworks-sfm-repo  Release [2,003 B]                        
  Get:8 file:/var/visionworks-tracking-repo  Release [2,008 B]                   
  Hit:12 http://ports.ubuntu.com/ubuntu-ports bionic InRelease                   
  Hit:15 https://repo.download.nvidia.com/jetson/common r32 InRelease            
  Get:16 http://ports.ubuntu.com/ubuntu-ports bionic-updates InRelease [88.7 kB] 
  Get:17 https://apt.console.edgematrix.com/airbase/apt/debian bionic InRelease [2,409 B]
  Get:18 https://repo.download.nvidia.com/jetson/t210 r32 InRelease [2,555 B]    
  Get:19 http://ports.ubuntu.com/ubuntu-ports bionic-backports InRelease [74.6 kB]
  Hit:14 https://packagecloud.io/github/git-lfs/ubuntu bionic InRelease              
  Get:20 http://ports.ubuntu.com/ubuntu-ports bionic-security InRelease [88.7 kB]
  Get:21 http://ports.ubuntu.com/ubuntu-ports bionic-updates/main arm64 DEP-11 Metadata [298 kB]
  Get:22 http://ports.ubuntu.com/ubuntu-ports bionic-updates/universe arm64 DEP-11 Metadata [269 kB]
  Get:23 http://ports.ubuntu.com/ubuntu-ports bionic-backports/universe arm64 DEP-11 Metadata [7,968 B]
  Get:24 http://ports.ubuntu.com/ubuntu-ports bionic-security/main arm64 DEP-11 Metadata [34.5 kB]
  Get:25 http://ports.ubuntu.com/ubuntu-ports bionic-security/universe arm64 DEP-11 Metadata [36.9 kB]
  Fetched 903 kB in 3s (286 kB/s)                                                
  Reading package lists... Done
  Building dependency tree       
  Reading state information... Done
  149 packages can be upgraded. Run 'apt list --upgradable' to see them.
  Reading package lists... Done
  Building dependency tree       
  Reading state information... Done
  python3-edgematrix-stream-toolkit is already the newest version (1.3.0b3-1).
  0 upgraded, 0 newly installed, 0 to remove and 149 not upgraded.

Note that ``Get:19 https://apt.console.edgematrix.com/airbase/apt/debian bionic InRelease`` is the private APT repository by EDGEMATRIX that can be accessed only an authorized device.

In the example above, the sdk was confirmed as the latest version.

--------------------------------------------------------
Prepare a template app
--------------------------------------------------------

Each template has prepare_resource.sh that copies and compiles libraries, and generates an engine file to setup everything needed to run a particular app on your toolkit box.

An engine file varies by a version of CUDA, TensorRT, and GPU architecture. So please make sure to run the prepare_resource.sh script whenever necessary.

--------------------------------------------------------
Create a new EAP by copying from a template EAP
--------------------------------------------------------

At first, let's explore a command line program and the main directory you work on.
Then, launch the EDGEMATRIX Stream Toolkit application, then create a new EAP application from one of templates.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
runtoolkit and toolkit_home
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The command line program to launch the toolkit application is ``runtoolkit``.

And the main directory you work on is ``toolkit_home``, which is mounted on a secondary drive.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ runtoolkit --help
  usage: EDGEMATRIX Stream Toolkit [-h] [--verbose] [-d DEVICEID] [-s SECRETKEY]
                                   toolkit_home

  positional arguments:
    toolkit_home          A folder path of the toolkit_home

  optional arguments:
    -h, --help            show this help message and exit
    --verbose, -v         if set, the logging level is set as DEBUG
    -d DEVICEID, --deviceid DEVICEID
                          use this deviceid if set
    -s SECRETKEY, --secretkey SECRETKEY
                          use this secret key if set

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Launch the EDGEMATRIX Stream Toolkit application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Launch the EDGEMATRIX Stream Toolkit application by executing ``runtoolkit``.

.. code-block:: bash

  nvidia@nvidia-desktop:/mnt/nvme/toolkit_home$ runtoolkit ./

Then, the following window will be shown.

    .. image:: images/quickstart/launched.png
       :align: center

By clicking ``About`` button, you can check the version.

    .. image:: images/quickstart/about.png
       :align: center

Now this time, let's create a new applicatoin that counts a vehicle by car color.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Create a new EAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Press ``New``, then you will see a dialog below.

    .. image:: images/quickstart/new_eap_dialog.png
       :align: center

Then, enter "My First Vehicle Counter", select ``EMI Vehicle DCF Counter By Color``, then click ``OK``.

    .. image:: images/quickstart/new_eap_dialog_filled.png
       :align: center

This will copy the template to create your application. Now the Toolkit window shows your application as follows.

    .. image:: images/quickstart/new_eap_created.png
       :align: center

As below, your application folder contains exactly the same structure as the copied template folder.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ diff applications/My\ First\ Vehicle\ Counter/ templates/EMI\ Vehicle\ DCF\ Counter\ By\ Color/
  Common subdirectories: applications/My First Vehicle Counter/resource and templates/EMI Vehicle DCF Counter By Color/resource

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Select a new EAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now let's select the newly created EAP application in the sidebar.

    .. image:: images/quickstart/new_eap_selected.png
       :align: center

Then, it will show you all the configurations.
By clicking each of configuration groups, you can see its detail.
For example, you can see the followings when you click ``Callback&Events``.

    .. image:: images/quickstart/new_eap_selected_callbackevents.png
       :align: center

Let's check what's inside the new application folder.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l applications/My\ First\ Vehicle\ Counter/
  total 32
  -rw-r--r-- 1 nvidia nvidia  6905 Feb 26 00:53 emi_signal_callback.py
  -rw-r--r-- 1 nvidia nvidia  1543 Feb  2 13:52 emi_stream_config.json
  -rw-r--r-- 1 nvidia nvidia 13271 Dec 24 23:42 icon.png
  drwxr-xr-x 3 nvidia nvidia  4096 Apr 10 14:36 resource
  /mnt/nvme/toolkit_home$ ls -lR applications/My\ First\ Vehicle\ Counter/resource/
  'applications/My First Vehicle Counter/resource/':
  total 3572
  -rw-r--r-- 1 nvidia nvidia    3240 Apr 10 14:36 dstest1_pgie_config.txt
  -rw-r--r-- 1 nvidia nvidia    3413 Feb  2 14:22 dstest2_sgie1_config.txt
  -rw-r--r-- 1 nvidia nvidia 3638560 Jan 13 08:19 libnvds_nvdcf.so
  drwxr-xr-x 4 nvidia nvidia    4096 Jan 13 13:21 models
  -rw-r--r-- 1 nvidia nvidia    1684 Jan  1 19:03 tracker_config.yml

  'applications/My First Vehicle Counter/resource/models':
  total 8
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 14:36 Primary_Detector
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 14:38 Secondary_CarColor

  'applications/My First Vehicle Counter/resource/models/Primary_Detector':
  total 13988
  -rw-r--r-- 1 nvidia nvidia    1126 Dec 12 08:14 cal_trt.bin
  -rw-r--r-- 1 nvidia nvidia      28 Dec 12 08:14 labels.txt
  -rw-r--r-- 1 nvidia nvidia 6244865 Dec 12 08:14 resnet10.caffemodel
  -rw-r--r-- 1 nvidia nvidia 8057761 Apr  9 03:01 resnet10.caffemodel_b1_fp16.engine
  -rw-r--r-- 1 nvidia nvidia    7605 Dec 12 08:14 resnet10.prototxt

  'applications/My First Vehicle Counter/resource/models/Secondary_CarColor':
  total 17228
  -rw-r--r-- 1 nvidia nvidia    2078 Dec 10 08:39 cal_trt.bin
  -rw-r--r-- 1 nvidia nvidia      71 Dec 10 08:39 labels.txt
  -rw-r--r-- 1 nvidia nvidia  150543 Dec 10 08:39 mean.ppm
  -rw-r--r-- 1 nvidia nvidia 9017648 Dec 10 08:39 resnet18.caffemodel
  -rw-r--r-- 1 nvidia nvidia 8444530 Apr  9 02:59 resnet18.caffemodel_b16_fp16.engine
  -rw-r--r-- 1 nvidia nvidia   14058 Dec 10 08:39 resnet18.prototxt

Please note for now that this application uses trained model binaries as they are.
You will see later how they are protected as an EAP package.

--------------------------------------------------------
Validate the new EAP
--------------------------------------------------------

In a real project, you will customize this app as needed. 
Then, once ready, the first thing to try is to validate if it is valid.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Open a validation dialog
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Press ``Spell Check`` button, which may sound odd, but anyway, then, you will see a dialog as below.

    .. image:: images/quickstart/validate_eap_dialog.png
       :align: center

This shows two check results not shown yet and the sample signal json to test the callback function.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Run a validation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Press ``Execute``, and see the results.

    .. image:: images/quickstart/validate_eap_dialog_passed.png
       :align: center

Nothing is customized yet, so it should pass as above.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Use your own sample siginal to validate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

But, if you have customized your callback, then, you are likely to test a different sample json.
In such a case, you can write your own sample, then use it for this validation.

Click the file chooser, select your file, then, you are ready to validate with your own sample as below.

    .. image:: images/quickstart/validate_eap_dialog_sample_signal.png
       :align: center

In this case, the value of ``unique_component_id`` was changed.

--------------------------------------------------------
Test the new EAP
--------------------------------------------------------

If you pass the validation, ``Execute`` button becomes active for you to run your application.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Execute, Choose a stream and Create an EAP package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By clicking the ``Execute`` button, it will show you an execution dialog.

    .. image:: images/quickstart/test_eap_dialog.png
       :align: center

At first, you need to choose a stream where your application will run.
By default, ``streams`` folder of the toolkit home directory is chosen.
Click the file chooser, open the ``vehicle_stream`` folder, then select ``vehicle_counter_stream_configuration.json``.

The ``streams`` folder and the ``movies`` folder look as below.

.. code-block:: bash

  nvidia@nvidia-desktop:/mnt/nvme/toolkit_home$ ls -l streams/
  total 44
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 20:42 face_net
  drwxr-xr-x 2 nvidia nvidia 4096 Feb 14 10:09 line_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Jan 15 17:18 no_app_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 20:42 pedestrian_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_bottomleft
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_upperleft
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_upperright
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 09:44 snmp_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 23 11:45 vehicle_stream
  drwxr-xr-x 4 nvidia nvidia 4096 Apr 24 06:58 yolo_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 yolo_stream_bottomright
  nvidia@nvidia-desktop:/mnt/nvme/toolkit_home$ ls -l movies/
  total 7470252
  -rw-r--r-- 1 nvidia nvidia  129384358 Jan  5 19:48 ChuoHwy-720p-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia 1494279921 Jan  1 21:29 Highway-4K@30p-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia  154023977 Jan 12 18:01 Highway-4K-4Mbs-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia  663620758 Jan 12 20:42 Park-FHD@30p-10MBs-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia  251927313 Jan 12 20:26 Park-FHD@30p-4MBs-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia 1668565295 Jan  1 21:31 Park-FHD@60p-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia  285564648 Mar  4 19:08 shinbashi_4MB.mp4
  -rw-r--r-- 1 nvidia nvidia  770571528 Jan 12 20:42 Street-FHD@30p-10MBs-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia  278477073 Jan 12 20:26 Street-FHD@30p-4MBs-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia 1953085229 Jan  1 21:32 Street-FHD@60p-faststart.mp4

Next, choose a movie file to use as a local RTSP streaming as below.

    .. image:: images/quickstart/test_eap_dialog_selected.png
       :align: center

Now, ``Convert`` button becomes active for you to make an EAP package in the chosen stream folder.

Press the ``Convert`` button, then a popup window to enter a passphrase is shown.

    .. image:: images/quickstart/test_eap_dialog_passphrase.png
       :align: center

It is the passphrase to protect your model binary. An EAP will be encrypted by the private key of each target device, and placed safely on an encrypted secondary drive of the target device, which is futher protected by a secureboot from its root and whose root user is not exposed. But, the last protection of your precious model binary is this passphrase. So, please choose carefully when you make your submission package.

Enter your passphrase, press ``OK``, then the packaging task will run for a while as a spinner is shown.
The dialog window will looks as below once completes.

    .. image:: images/quickstart/test_eap_dialog_ready_to_play.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Play a pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now you are ready to run your application in the stream.
Click ``Play`` button, and wait for a few seconds, you'll see events are getting generated and passed as actions.

    .. image:: images/quickstart/test_eap_dialog_playing.png
       :align: center

Note that ``Show Debug Window`` is checked. The debug window is shown, too.

    .. image:: images/quickstart/test_eap_dialog_playing_debug.png
       :align: center

Also, some stats about a running pipeline can be checked.

    .. image:: images/quickstart/test_eap_dialog_stats.png
       :align: center

Let's check the EAP package built. An agent process is already up and running, so has already extracted the EAP package in the ``uncompressed_files`` folder.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/
  total 50188
  -rw-r--r-- 1 nvidia nvidia        0 Apr 24 09:43 gstd.log
  drwxr-xr-x 2 nvidia nvidia     4096 Apr 24 09:44 recordings
  -rw-r--r-- 1 nvidia nvidia 18460328 Apr 24 09:46 stream.log
  drwxr-xr-x 3 nvidia nvidia     4096 Apr 24 09:43 uncompressed_files
  -rw-r--r-- 1 nvidia nvidia     1242 Jan 15 17:45 vehicle_counter_stream_configuration.json
  -rw-r--r-- 1 nvidia nvidia 32918721 Apr 24 09:41 vehicle_counter.zip
  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/uncompressed_files/vehicle_stream/
  total 32
  -rw-r--r-- 1 nvidia nvidia  6905 Apr 24 09:43 emi_signal_callback.py
  -rw-r--r-- 1 nvidia nvidia  1543 Apr 24 09:43 emi_stream_config.json
  -rw-r--r-- 1 nvidia nvidia 13271 Apr 24 09:43 icon.png
  drwxr-xr-x 3 nvidia nvidia  4096 Apr 24 09:43 resource

The folder structure exactly the same as the one of the application folder as you have seen.
But there are a couple of exceptions. All the trained binaries and related files are encrypted.
You can tell by a file extention. Files with ``.gpg`` are encrypted with `GnuPG <https://gnupg.org/>`_.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/uncompressed_files/vehicle_stream/resource/
  total 3572
  -rw-r--r-- 1 nvidia nvidia    3240 Apr 24 09:43 dstest1_pgie_config.txt
  -rw-r--r-- 1 nvidia nvidia    3413 Apr 24 09:43 dstest2_sgie1_config.txt
  -rw-r--r-- 1 nvidia nvidia 3638560 Apr 24 09:43 libnvds_nvdcf.so
  drwxr-xr-x 4 nvidia nvidia    4096 Apr 24 09:43 models
  -rw-r--r-- 1 nvidia nvidia    1684 Apr 24 09:43 tracker_config.yml
  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/uncompressed_files/vehicle_stream/resource/models/total 8
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 24 09:43 Primary_Detector
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 24 09:43 Secondary_CarColor
  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/uncompressed_files/vehicle_stream/resource/models/Primary_Detector/
  total 13992
  -rw-r--r-- 1 nvidia nvidia    1126 Apr 24 09:43 cal_trt.bin
  -rw-r--r-- 1 nvidia nvidia      28 Apr 24 09:43 labels.txt
  -rw-r--r-- 1 nvidia nvidia 8059800 Apr 24 09:43 resnet10.caffemodel_b1_fp16.engine.gpg
  -rw-r--r-- 1 nvidia nvidia 6246460 Apr 24 09:43 resnet10.caffemodel.gpg
  -rw-r--r-- 1 nvidia nvidia    7679 Apr 24 09:43 resnet10.prototxt.gpg
  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/uncompressed_files/vehicle_stream/resource/models/Secondary_CarColor/
  total 17236
  -rw-r--r-- 1 nvidia nvidia    2078 Apr 24 09:43 cal_trt.bin
  -rw-r--r-- 1 nvidia nvidia      71 Apr 24 09:43 labels.txt
  -rw-r--r-- 1 nvidia nvidia  150543 Apr 24 09:43 mean.ppm
  -rw-r--r-- 1 nvidia nvidia 8446663 Apr 24 09:43 resnet18.caffemodel_b16_fp16.engine.gpg
  -rw-r--r-- 1 nvidia nvidia 9019921 Apr 24 09:43 resnet18.caffemodel.gpg
  -rw-r--r-- 1 nvidia nvidia   14134 Apr 24 09:43 resnet18.prototxt.gpg

This shows that no decrypted files on a disk. They are decrypted and processed in memory.
So even if an AI Box is stolen, your precious trained model binaries won't be exploited immediately.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stop a pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your test gets done, press ``Stop`` to terminate the EAP application process.

    .. image:: images/quickstart/test_eap_dialog_stopped.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Movie files made by record actions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At last, let's check movie files left, which were made by record actions.
Go to ``/mnt/nvme/toolkit_home/streams/vehicle_stream/recordings`` folder, then you'll see some files as follows.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l streams/vehicle_stream/recordings/
  total 52476
  -rw-r--r-- 1 nvidia nvidia 12422309 Apr 24 09:44 vehicle_stream_7598_videorecord0_2020-04-24T09:43:45+0900.mp4
  -rw-r--r-- 1 nvidia nvidia      595 Apr 24 09:44 vehicle_stream_7598_videorecord0_2020-04-24T09:44:22+0900.mp4
  -rw-r--r-- 1 nvidia nvidia 41304112 Apr 24 09:46 vehicle_stream_7598_videorecord0_2020-04-24T09:44:31+0900.mp4