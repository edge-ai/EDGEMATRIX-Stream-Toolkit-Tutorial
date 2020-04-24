Tutorials
=====================

#. Preparing a simple Detector project
#. Using your own events and callback function
    #. Write your own callback function
    #. Use your own event
    #. Test your application
#. Using your own input source
    #. Preparing your movie file for a streaming
    #. Use your own stream ready movie file
#. Using your own trained model binary
    #. Place your trained model binary and related files
    #. Change property configurations
#. Using your own trained Yolo model binary with IPlugin
    #. Follow the Yolo tutorial on DeepStream SDK
    #. Place your trained Yolo model binary and related files
    #. Change property configurations
#. Making a submission package
    #. What is a submission package?
    #. How to make a submission package?

--------------------------------------------------------
Preparing a simple Detector project
--------------------------------------------------------

In this tutorials, a simple vehicle detector will be customized.
So, please create one as follows.

At first, create a simple vehicle detector from a vehicle template.

    .. image:: images/tutorials/mydetector.png
       :align: center

Then, modify the application name to reflect this application.

    .. image:: images/tutorials/mydetector_overview_editted.png
       :align: center

And change the resolution for the primary inference.

    .. image:: images/tutorials/mydetector_input.png
       :align: center

The template has a tracker and a secondary model inference as well as a primary inference.
So, let's remove all the properties related to a tracker and a secondary inference by selecting each property followed by ``Remove``.

    .. image:: images/tutorials/mydetector_removed_tracker_props.png
       :align: center

    .. image:: images/tutorials/mydetector_removed_secondary_props.png
       :align: center

Then, modify event items for a detector as follows.

    .. image:: images/tutorials/mydetector_events.png
       :align: center

Please note that now this application raises events about a location of a detected object,
instead of properties of each identified object by a tracker.

Now, it's time to save these changes. Click ``Save`` button, then the sdk will reload applications.

    .. image:: images/tutorials/mydetector_save.png
       :align: center

--------------------------------------------------------
Using your own events and callback function
--------------------------------------------------------

In the last section, event items are modified for the detector.

So, you need to update the callback function as well.

The python file that defines a callback function exists as ``emi_signal_callback.py`` in an application folder as follows.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l applications/
  total 4
  drwxr-xr-x 3 nvidia nvidia 4096 Apr 24 11:41 'My Vehicle Detector'
  /mnt/nvme/toolkit_home$ ls -l applications/My\ Vehicle\ Detector/
  total 36
  -rw-r--r-- 1 nvidia nvidia  6905 Feb 26 00:53 emi_signal_callback.py
  -rw-r--r-- 1 nvidia nvidia  1317 Apr 24 11:41 emi_stream_config.json
  -rw-r--r-- 1 nvidia nvidia  1543 Apr 24 11:41 emi_stream_config.json.bak
  -rw-r--r-- 1 nvidia nvidia 13271 Dec 24 23:42 icon.png
  drwxr-xr-x 3 nvidia nvidia  4096 Apr 10 14:36 resource

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Write your own callback function
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Copy the following content to the ``emi_signal_callback.py``.

.. code-block:: python

  from datetime import datetime

  ISO_FORMAT = '%Y-%m-%dT%H:%M:%S.%f%z'

  '''
  Vehicle Detector

  Keys:
      detected_datetime (string): The datetime when this object was detected
      left (number): The left coordinate of this object
      top (number): The top coordinate of this object
      width (number): The width of this object
      height (number): The height of this object
  '''

  class Car:

      def __init__(self, detected_timestamp, left, top, width, height, class_id, confidence):
          self.detected_timestamp = detected_timestamp
          self.left = left
          self.top = top
          self.width = width
          self.height = height
          self.class_id = class_id
          self.confidence = confidence

      def to_event_item(self):
          event_item = {
              'detected_timestamp': self.detected_timestamp,
              'left': self.left,
              'top': self.top,
              'width': self.width,
              'height': self.height,
              'class_id': self.class_id,
              'confidence': self.confidence
          }
          return event_item

      def iso_timestamp_to_datetime(timestamp):
          return datetime.strptime(timestamp, ISO_FORMAT)

  def update_tracking(signal):
      """ a signal callback function """
      debug_string = ''
      detected_cars = []
      frame_list = signal["frame"]
      for frame in frame_list:
          timestamp = frame['timestamp']
          objects = frame["object"]
          debug_string = debug_string + 'signal@' + timestamp + ':' + str(len(objects)) + 'objects\n'
          for obj in objects:
              class_id = obj['class_id']
              confidence = obj['confidence']
              rect_params = obj['rect_params']
              left = rect_params['left']
              top = rect_params['top']
              width = rect_params['width']
              height = rect_params['height']
              car = Car(timestamp, left, top, width, height, class_id, confidence)
              detected_cars.append(car.to_event_item())

      return detected_cars, debug_string

The callback function name was left as ``update_tracking``, but the whole content was replaced.

Let's go back to the Toolkit, and check if this callback works correctly by pressing ``Spell Check``.

    .. image:: images/tutorials/mydetector_failed.png
       :align: center

Oops, failed. If you look at your console, you'll see an output like this.

    .. image:: images/tutorials/mydetector_keyerror.png
       :align: center

It says "confidence" does not exist in the produced event, which is based on a template.
So, let's create our own event and use it for this check.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Use your own event
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Copy the following content to ``detector_signal.json`` in the signals folder under the Toolkit root folder.
If you happen to place such a file in an application folder, it wouldn't work correctly.

.. code-block:: javascript

  {
      "frame": [
          {
              "frame": 1,
              "pts": 1,
              "timestamp": "2000-01-01T00:00:00.000000+0900",
              "object": [
                  {
                      "class_id": 0,
                      "confidence": 0.0,
                      "rect_params": {
                          "left": 0,
                          "top": 0,
                          "width": 0,
                          "height": 0
                      }
                  }
              ]
          }
      ]
  }

Note that another missing key, ``rect_params``, was also added.

Then, try again ``Spell Check``. This time, make sure to choose ``detector_signal.json``.
By pressing ``Execute``, you'll see your application pass the check.

    .. image:: images/tutorials/mydetector_passed.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Test your application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

So, finally, let's test your application.

But, you need to create a stream folder to run this application.

Copy an existing ``vehicle_stream`` folder and name it ``mydetector_stream``.

Now the folder structure should look like this.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l streams/
  total 48
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 20:42 face_net
  drwxr-xr-x 2 nvidia nvidia 4096 Feb 14 10:09 line_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 24 12:05 mydetector_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Jan 15 17:18 no_app_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 20:42 pedestrian_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_bottomleft
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_upperleft
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 pedestrian_stream_upperright
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 09:44 snmp_stream
  drwxr-xr-x 4 nvidia nvidia 4096 Apr 24 09:43 vehicle_stream
  drwxr-xr-x 4 nvidia nvidia 4096 Apr 24 06:58 yolo_stream
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 10 08:56 yolo_stream_bottomright
  /mnt/nvme/toolkit_home$ ls -l streams/mydetector_stream/
  total 4
  -rw-r--r-- 1 nvidia nvidia 1242 Jan 15 17:45 vehicle_counter_stream_configuration.json

If you find any other files or folders when you come from the quickstart,
then remove all the files except for ``vehicle_by_make_counter_stream_configuration.json``.

Rename ``vehicle_by_make_counter_stream_configuration.json`` as ``mydetector_stream_configuration.json``,
then copy the following content.

.. code-block:: javascript

  {
    "stream_id": "mydetector_stream",
    "created": "2019-07-23T09:10:29.842496+09:00",
    "last_updated": "2019-07-24T10:11:30.842496+09:00",
    "revision": 3,
    "stream_type": "rtsp",
    "location": "rtsp://127.0.0.1:8554/test",
    "mode": "sender",
    "roi": {
      "left": 0,
      "right": 0,
      "top": 0,
      "bottom": 0
    },
    "action_rules": [
      {
        "rule_name": "Vehicle Recording",
        "and": [
          {
            "key": "width",
            "operator": ">",
            "value": 100
          },
          {
            "key": "height",
            "operator": ">",
            "value": 100
          }
        ],
        "or": [],
        "action": {
          "action_name": "record",
          "duration_in_seconds": 3
        }
      },
      {
        "rule_name": "Upload to AWS Kinesis Firehose",
        "and": [
          {
            "key": "width",
            "operator": ">",
            "value": 100
          },
          {
            "key": "height",
            "operator": ">",
            "value": 100
          }
        ],
        "or": [],
        "action": {
          "action_name": "upload",
          "deliveryStreamName": "trafficStream",
          "accessKey": "",
          "secretKey": "",
          "region": ""
        }
      }
    ],
    "application_package": {
      "filename": "mydetector.zip",
      "license": "ABC01234"
    }
  }

By executing this application in the ``mydetector_stream`` folder with the sample video file,
it will be shown as follows, which correctly produces upload actions for each event only when both of an width and an height are larger than 100.

    .. image:: images/tutorials/mydetector_execute.png
       :align: center

Also, recording actions will be invoked, and leave some movie files in the recordings folder.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l streams/mydetector_stream/recordings/
  total 9136
  -rw-r--r-- 1 nvidia nvidia 4380226 Apr 24 12:32 mydetector_stream_20420_videorecord0_2020-04-24T12:31:59+0900.mp4
  -rw-r--r-- 1 nvidia nvidia 4969132 Apr 24 12:32 mydetector_stream_20420_videorecord0_2020-04-24T12:32:09+0900.mp4

--------------------------------------------------------
Using your own input source
--------------------------------------------------------

Using your own movie file is no more than choosing your own file when executing your application.

But making a movie file needs to follow some rules.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Preparing your movie file for a streaming
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A movie file chosen at an execution is used internally as a source of local RTSP server.

Such a movie file contianer needs to be mp4. Other containers may work, but not tested well.

There are some requirements for making your movie file stream ready in the Toolkit.

#. H.264 video encoding
#. faststart (MOOV atom at the beginning of a file instead of at the end)
#. constant bit rate up to 4Mbps

This can be done with ffmpeg, not on the Toolkit box, but on your any host computer, with a command as follows.

.. code-block:: bash

  $ ffmpeg -i INPUT -c:v libx264 -b:v 4m -maxrate 4m -bufsize 4m -movflags +faststart OUTPUT

--------------------------------------------------------
Using your own trained model binary
--------------------------------------------------------

TBD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Place your trained model binary and related files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TBD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Change property configurations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TBD

--------------------------------------------------------
Using your own trained Yolo model binary with IPlugin
--------------------------------------------------------

If you have your own trained Yolo model, you can refer to the following guide by NVIDIA.

`Custom YOLO Model in the DeepStream YOLO App <https://docs.nvidia.com/metropolis/deepstream/Custom_YOLO_Model_in_the_DeepStream_YOLO_App.pdf>`_ 

Here in this tutorial, you will see how to package a sample Yolo detector contained in the DeepStream.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Follow the Yolo tutorial on DeepStream Toolkit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sample files of the deepsteram are stored on ``/opt/nvidia/deepstream``.

The Yolo sample project is located at ``/opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo``. You can build the project by simply following the README file as follows.

.. code-block:: bash

  $ ./prebuild.sh
  $ export CUDA_VER=10.0
  $ make -C nvdsinfer_custom_impl_Yolo

Then, launch the deepstream-app to check if it correctly works.
Also, at this initial launch, a TensorRT engine file will be created.

.. code-block:: bash

  $ deepstream-app -c deepstream_app_config_yoloV3_tiny.txt

Note that the Tiny Yolo V3 application runs as fast as about 50 fps in FP32 mode on Jetson TX2.
You can try different Yolo versions to see their performances.

The configuration of the tiny Yolo V3 will be used here in the following sections.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Place your trained Yolo model binary and related files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now that you have a working example of your Yolo model binary and related files,
let's package them as an EAP file.

Copy the simple Detector project folder in applications folder,
then rename as ``My Yolo Detector``.

Then, remove all the text files and the so file under resource folder.
Also, drop the Secondary_CarColor folder and all the files in the Primary_Detector folder under the resource/models folder.

Old files got cleaned up. So, let's put new files.

Copy config_infer_primary_yoloV3_tiny.txt and nvdsinfer_custom_impl_Yolo/libnvdsinfer_custom_impl_Yolo.so to the resource folder.
Then, copy the following files to the resource/models/Primary_Detector folder.

* labels.txt
* model_b1_fp32.engine
* yolov3-tiny.cfg
* yolov3-tiny.weights

.. code-block:: bash

  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp config_infer_primary_yoloV3_tiny.txt /mnt/nvme/toolkit_home/applications/My\ Yolo\ Detector/resource/
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp nvdsinfer_custom_impl_Yolo/libnvdsinfer_custom_impl_Yolo.so /mnt/nvme/toolkit_home/applications/My\ Yolo\ Detector/resource/
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp labels.txt /mnt/nvme/toolkit_home/applications/My\ Yolo\ Detector/resource/models/Primary_Detector/
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp model_b1_fp32.engine /mnt/nvme/toolkit_home/applications/My\ Yolo\ Detector/resource/models/Primary_Detector/
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp yolov3
  yolov3-calibration.table.trt5.1  yolov3-tiny.cfg                  yolov3.weights
  yolov3.cfg                       yolov3-tiny.weights              
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp yolov3
  yolov3-calibration.table.trt5.1  yolov3-tiny.cfg                  yolov3.weights
  yolov3.cfg                       yolov3-tiny.weights              
  /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo$ cp yolov3-tiny.* /mnt/nvme/toolkit_home/applications/My\ Yolo\ Detector/resource/models/Primary_Detector/

The folder structure now looks like this:

.. code-block:: bash

  /mnt/nvme/toolkit_home/applications/My Yolo Detector$ ls -lR
  .:
  total 32
  -rw-r--r-- 1 nvidia nvidia  2006 Apr 24 13:40 emi_signal_callback.py
  -rw-r--r-- 1 nvidia nvidia  1317 Apr 24 13:40 emi_stream_config.json
  -rw-r--r-- 1 nvidia nvidia  1543 Apr 24 13:40 emi_stream_config.json.bak
  -rw-r--r-- 1 nvidia nvidia 13271 Apr 24 13:40 icon.png
  drwxr-xr-x 3 nvidia nvidia  4096 Apr 24 13:55 resource

  ./resource:
  total 872
  -rwxrwxr-x 1 nvidia nvidia   3163 Apr 24 13:54 config_infer_primary_yoloV3_tiny.txt
  -rwxr-xr-x 1 nvidia nvidia 882888 Apr 24 13:55 libnvdsinfer_custom_impl_Yolo.so
  drwxr-xr-x 3 nvidia nvidia   4096 Apr 24 13:47 models

  ./resource/models:
  total 4
  drwxr-xr-x 2 nvidia nvidia 4096 Apr 24 13:56 Primary_Detector

  ./resource/models/Primary_Detector:
  total 71288
  -rwxrwxr-x 1 nvidia nvidia      624 Apr 24 13:55 labels.txt
  -rw-r--r-- 1 nvidia nvidia 37548579 Apr 24 13:55 model_b1_fp32.engine
  -rw-r--r-- 1 nvidia nvidia     1915 Apr 24 13:56 yolov3-tiny.cfg
  -rw-r--r-- 1 nvidia nvidia 35434956 Apr 24 13:56 yolov3-tiny.weights

Close if you still open the Toolkit, then open to load the new application.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Change property configurations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The only property you have to change is config-file-path in the Primary.

    .. image:: images/tutorials/myyolodetector_primary.png
       :align: center

After changing the property, save the config. Then, open config_infer_primary_yoloV3_tiny.txt,
and update properties as follows.
Please make sure to remove the comment on the model-engine-file property, and add ".gpg" suffixes.

.. code-block:: bash

  /mnt/nvme/toolkit_home/applications/My Yolo Detector/resource$ diff config_infer_primary_yoloV3_tiny.txt /opt/nvidia/deepstream/deepstream-4.0/sources/objectDetector_Yolo/config_infer_primary_yoloV3_tiny.txt 
  65,68c65,68
  < custom-network-config=models/Primary_Detector/yolov3-tiny.cfg
  < model-file=models/Primary_Detector/yolov3-tiny.weights.gpg
  < model-engine-file=models/Primary_Detector/model_b1_fp32.engine.gpg
  < labelfile-path=models/Primary_Detector/labels.txt
  ---
  > custom-network-config=yolov3-tiny.cfg
  > model-file=yolov3-tiny.weights
  > #model-engine-file=model_b1_fp32.engine
  > labelfile-path=labels.txt
  76c76
  < custom-lib-path=libnvdsinfer_custom_impl_Yolo.so
  ---
  > custom-lib-path=nvdsinfer_custom_impl_Yolo/libnvdsinfer_custom_impl_Yolo.so

By following the procedures as before, your application can be launched in the mydetector_stream as below.

Actions)

    .. image:: images/tutorials/myyolodetector_actions.png
       :align: center

Debug Window)

    .. image:: images/tutorials/myyolodetector_debug.png
       :align: center

-----------------------------
Making a submission package
-----------------------------

When you become confident that you app is ready to ship, you can make a submission package.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
What is a submission package?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A submission package contains all the necessary files for EDGEMATRIX to prepare your app for sale.

This includes:

* an EAP file including encrypted model binaries
* the passphrase (used to encrpt your model binaries) encrypted with your device credential
* a stream config file used for the last test
* a movie file used for the last test

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
How to make a submission package?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After successfully running your test, the ``Network`` button placed between the ``Stop`` button and the ``Close`` button becomes active.

Press this ``Network`` button to make a submission pacakge from the last test. Then, the save thread starts, and which will ask a sudo password in order to access the device credential to encrypt your pass phrase as below.

    .. image:: images/tutorials/myyolodetector_submission_package.png
       :align: center

Then, you will find a folder that contains all the necessary files to submit as below.

.. code-block:: bash

  /mnt/nvme/toolkit_home$ ls -l submissions/My\ Yolo\ Detector/
  total 197908
  -rw-r--r-- 1 nvidia nvidia       142 Apr 24 21:17 C0210001_encrypted.json
  -rw-r--r-- 1 nvidia nvidia 129384358 Apr 24 21:17 ChuoHwy-720p-faststart.mp4
  -rw-r--r-- 1 nvidia nvidia      1297 Apr 24 21:17 mydetector_stream_configuration.json
  -rw-r--r-- 1 nvidia nvidia  73263564 Apr 24 21:17 mydetector.zip