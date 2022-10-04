Templates
====================

#. DeepStream templates

    #. EMI Pedestrian DCF Counter
    #. EMI Pedestrian IOU Counter
    #. EMI Pedestrian KLT Counter
    #. EMI Vehicle Counter
    #. EMI Vehicle DCF Counter By Color
    #. EMI Vehicle IOU Counter By Make
    #. EMI Vehicle Multiple Secondaries
    #. Yolo V3 Detector
    #. Yolo V3 Tiny Detector
    #. EMI Semantic Segmentation

#. Custom templates

    #. (Double EAPs) EMI Vehicle EMCustom
    #. (Double EAPs) EMI Vehicle Color Watcher
    #. EMI Vehicle PrePost EMCustom
    #. EMI EMCustom CPP
    #. EMI Torch 3DCNN
    #. EMI Torch Imagenet Yolo IOU Counter
    #. Facenet

#. IoT templates

    #. EMI IoT Sensor Monitor
    #. EMI Simple UDP
    #. EMI Simple Recorder

============================================================
DeepStream samples
============================================================

These templates simply demonstrate how to make an EAP package from various DeepStream samples.

The following three primary models are used in these samples.

* primary detector
    * `/opt/nvidia/deepstream/deepstream-5.0/samples/models/Primary_Detector`
* yolo v3 and tiny yolo v3
    * `/opt/nvidia/deepstream/deepstream-5.0/sources/objectDetector_Yolo`
* semantic segmentation
    * `/opt/nvidia/deepstream/deepstream-5.0/samples/models/Segmentation/semantic`

And the following two models for secondaries.

* car color
    * `/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_CarColor`
* car make
    * `/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_CarMake`
* vehicle type
    * `/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_VehicleTypes`

=================================== =============================== =============================
template name                       signal                          stream                    
=================================== =============================== =============================
EMI Pedestrian DCF Counter          pedestrial_signal.json          pedestrian_stream
EMI Pedestrian IOU Counter          pedestrial_signal.json          pedestrian_stream
EMI Pedestrian KLT Counter          pedestrial_signal.json          pedestrian_stream
EMI Vehicle Counter                 my_signal.json                  vehicle_stream
EMI Vehicle DCF Counter By Color    my_signal.json                  vehicle_stream
EMI Vehicle IOU Counter By Make     my_signal.json                  vehicle_stream
EMI Vehicle Multiple Secondaries    my_signal.json                  vehicle_stream
Yolo V3 Detector                    yolo_signal.json                yolo_stream
Yolo V3 Tiny Detector               yolo_signal.json                yolo_stream
EMI Semantic Segmentation           segmentation_signal.json        segmentation_stream
=================================== =============================== =============================

--------------------------------
EMI Pedestrian DCF Counter
--------------------------------

This is a template to count the number of pedestrians that uses the primary detector model of DeepStream with a `DCF <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#nvdcf-low-level-tracker>`_ tracker. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "tracker_config.yml",
            "ll-lib-file": "libnvds_nvdcf.so"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Pedestrian IOU Counter
--------------------------------

This is a template to count the number of pedestrians that uses the primary detector model of DeepStream with an `IOU <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#iou-low-level-tracker>`_ tracker. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "iou_config.txt",
            "ll-lib-file": "libnvds_mot_iou.so"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Pedestrian KLT Counter
--------------------------------

This is a template to count the number of pedestrians that uses the primary detector model of DeepStream with an `KLT <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#klt-low-level-tracker>`_ tracker. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "klt_config.txt",
            "ll-lib-file": "libnvds_mot_klt.so"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Vehicle Counter
--------------------------------

This is a template to count the number of vehicles that uses the primary detector model of DeepStream with a `DCF <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#nvdcf-low-level-tracker>`_ tracker. This pipeline consists of the same one as the one of EMI Pedestrian DCF Counter. The difference of these two apps comes from the implementation of callback function. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "meta-source-id": "emi_vehicle_dcf",
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "tracker_config.yml",
            "ll-lib-file": "libnvds_nvdcf.so"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Vehicle DCF Counter By Color
--------------------------------

This is a template to count the number of vehicles by color that uses the primary detector model of DeepStream with a `DCF <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#nvdcf-low-level-tracker>`_ tracker. It also uses the car color model of DeepStream for secondary inference. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "tracker_config.yml",
            "ll-lib-file": "libnvds_nvdcf.so"
        },
        "secondary": {
            "process-mode": 2,
            "config-file-path": "dstest2_sgie1_config.txt"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Vehicle IOU Counter By Make
--------------------------------

This is a template to count the number of vehicles by make that uses the primary detector model of DeepStream with an `IOU <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#iou-low-level-tracker>`_ tracker. It also uses the car make model of DeepStream for secondary inference. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest1_pgie_config.txt"
        },
        "tracker": {
            "ll-config-file": "iou_config.txt",
            "ll-lib-file": "libnvds_mot_iou.so"
        },
        "secondary": {
            "process-mode": 2,
            "config-file-path": "dstest2_sgie2_config.txt"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Vehicle Multiple Secondaries
--------------------------------

This is a template to count the number of vehicles by color, make, and type that uses the primary detector model of DeepStream with an `IOU <https://docs.nvidia.com/metropolis/deepstream/5.0.1/dev-guide/text/DS_plugin_gst-nvtracker.html#iou-low-level-tracker>`_ tracker. It also uses the car color model, the car make model, and the vehicle type model of DeepStream for secondary inference. The pipeline of this template consists of:

.. code-block:: json

  "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 640,
      "height": 368
    },
    "primary": {
      "process-mode": 1,
      "config-file-path": "pgie_config.txt"
    },
    "tracker": {
      "ll-config-file": "iou_config.txt",
      "ll-lib-file": "libnvds_mot_iou.so"
    },
    "secondary": [
      {
        "nvinfer": {
          "process-mode": 2,
          "config-file-path": "sgie_carcolor_config.txt"
        }
      },
      {
        "nvinfer": {
          "process-mode": 2,
          "config-file-path": "sgie_carmake_config.txt"
        }
      },
      {
        "nvinfer": {
          "process-mode": 2,
          "config-file-path": "sgie_vehicletypes_config.txt"
        }
      }
    ],
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 10
    }
  }

--------------------------------
Yolo V3 Detector
--------------------------------

This is a template to detect objects that uses the Yolo v3 model. Note that this won't run on an AI Box Light (Nano). The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 608,
            "height": 608
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "config_infer_primary_yoloV3.txt"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
Yolo V3 Tiny Detector
--------------------------------

This is a template to detect objects that uses the tiny Yolo v3 model. The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 416,
            "height": 416
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "config_infer_primary_yoloV3_tiny.txt"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Semantic Segmentation
--------------------------------

This is a template to show the way to access to an instance of NvDsUserMeta in EMCustom that uses the semantic segmentation model.

The C program executed in an EMCustom is located at `libs/gst-emcustom/examples/segmentation.c`.

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 512,
            "height": 512,
            "enable-padding": 1
        },
        "primary": {
            "process-mode": 1,
            "config-file-path": "dstest_segmentation_config_semantic.txt",
            "interval": 10
        },
        "emcustom": {
            "custom-lib": "models/Segmentation/libsegmentation.so",
            "process-interval": 10
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

============================================================
Custom templates
============================================================

=================================== =============================== =============================
template name                       signal                          stream                    
=================================== =============================== =============================
EMI Vehicle EMCustom                my_signal.json                  vehicle_emcustom_stream
EMI Vehicle Color Watcher           my_signal.json                  vehicle_colorwatcher_stream
EMI EMCustom CPP                    my_signal.json                  emcustom_cpp_stream
EMI Vehicle PrePost EMCustom        my_signal.json                  vehicle_prepost_stream
EMI Torch 3DCNN                     my_signal.json                  torch_3dcnn_stream
EMI Torch Imagenet Yolo IOU Counter my_signal.json                  torch_imagenet_stream
Facenet                             face_signal.json                face_net
=================================== =============================== =============================

--------------------------------
EMI Vehicle EMCustom
--------------------------------

This is a child EAP that has to be used with its parent app, EMI Vehicle Counter. For more information about such a pair of EAPs, please refer to the Double EAPs chapter.

This app demonstrates some features of EMCustom as below.

* the usage of third party dynamic libraries (the `libraries` property)
* the usage of emcustom options

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "dsmetatransfer": {
            "listen-to": "emi_vehicle_dcf"
        },
        "tracker": {
            "ll-config-file": "tracker_config.yml",
            "ll-lib-file": "libnvds_nvdcf.so"
        },
        "emcustom": {
            "custom-lib": "models/Secondary_AverageIntensity/libaverage_intensity.so",
            "libraries": ["models/Secondary_AverageIntensity/libmultiply.so"],
            "process-interval": 10,
            "options": {"vehicle_class_id": 0}
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Vehicle Color Watcher
--------------------------------

This is a child EAP that has to be used with its parent app, EMI Vehicle Counter. For more information about such a pair of EAPs, please refer to the Double EAPs.

This app is thoroughly explained in the Examples section of the Double EAPs chapter.

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 640,
            "height": 368
        },
        "primary": {},
        "dsmetatransfer": {
            "listen-to": "emi_vehicle_dcf"
        },
        "tracker": {
            "ll-config-file": "tracker_config.yml",
            "ll-lib-file": "libnvds_nvdcf.so"
        },
        "secondary": {
            "process-mode": 2,
            "config-file-path": "dstest2_sgie1_config.txt"
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI EMCustom CPP
--------------------------------

This is a template to show how to call a C++ library from an implementation of EMCustom. In this template, the timer object from `the dlib library <http://dlib.net/>`_ is called as an example. This is not practical, but you can clearly see that the pipeline sleeps at intervals, which means the timer object is correctly called. For more infomration about the timer object, please refer to `this page <http://dlib.net/timer_ex.cpp.html>`_.

In order to try this template, please follow the follwing instructions.

1. install libdlib-dev

.. code-block:: bash

  $ sudo apt install libdlib-dev

This will install libdlib.so, in /usr/lib. So, the linker flag is -ldlib.

2. run `prepare_resource.sh`

.. code-block:: bash

  $ cd templates/EMI\ EMCustom\ CPP/resource/
  $ ./prepare_resource.sh

Now you have built required libraries and copied them to the `resource/models/Secondary_Dlib/` directory.

3. check those built libraries

.. code-block:: bash

  $ ls -l models/Secondary_Dlib/
  total 1216
  -rwxrwxr-x 1 nvidia nvidia   19664 May 17 16:14 libdlibcall.so
  -rw-r--r-- 1 nvidia nvidia 1122056 May 17 16:14 libdlib.so.18
  -rwxrwxr-x 1 nvidia nvidia  101976 May 17 16:14 libdlibwrapper.so

Note that `libdlib.so.18` was included to distribute this EAP, where dlib is not installed.

4. you can find the actual name linked from your custom library as below

.. code-block:: bash

  $ ldd build/emcustom_sources/libdlibwrapper.so 
      linux-vdso.so.1 (0x0000007f8912f000)
      libdlib.so.18 => /usr/lib/libdlib.so.18 (0x0000007f88fa7000)
      libstdc++.so.6 => /usr/lib/aarch64-linux-gnu/libstdc++.so.6 (0x0000007f88e13000)
      libgcc_s.so.1 => /lib/aarch64-linux-gnu/libgcc_s.so.1 (0x0000007f88def000)
      libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000007f88c96000)
      /lib/ld-linux-aarch64.so.1 (0x0000007f89104000)
      libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000007f88c6a000)
      libpng16.so.16 => /usr/lib/aarch64-linux-gnu/libpng16.so.16 (0x0000007f88c2f000)
      libjpeg.so.8 => /usr/lib/aarch64-linux-gnu/libjpeg.so.8 (0x0000007f88be5000)
      libm.so.6 => /lib/aarch64-linux-gnu/libm.so.6 (0x0000007f88b2b000)
      libz.so.1 => /lib/aarch64-linux-gnu/libz.so.1 (0x0000007f88afe000)

5. this template is ready
6. uninstall libdlib-dev as needed

The pipeline of this template consists of:

.. code-block:: json

  "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 1920,
      "height": 1080
    },
    "primary": {
      "process-mode": 1,
      "config-file-path": "dstest1_pgie_config.txt"
    },
    "emcustom": {
      "custom-lib": "models/Secondary_Dlib/libdlibcall.so",
      "in-place": "true",
      "format": "RGBA",
      "process-interval": 10,
      "libraries": ["models/Secondary_Dlib/libdlibwrapper.so","models/Secondary_Dlib/libdlib.so.18"]
    },
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 10
    }
  }

--------------------------------
EMI Vehicle PrePost EMCustom
--------------------------------

This is a template to show one of Custom AI Pipelines. Both of pre and post processings for both of primary and secondary inferences are used.

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 640,
      "height": 368
    },
    "primary": [
      {
        "nvinfer": {
          "process-mode": 1,
          "config-file-path": "dstest1_pgie_config.txt"
        }
      },
      {
        "emcustom": {
          "custom-lib": "models/Primary_Postprocess/libpassthrough.so",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10
        }
      }
    ],
    "tracker": {
      "ll-config-file": "iou_config.txt",
      "ll-lib-file": "libnvds_mot_iou.so"
    },
    "secondary": [
      {
        "emcustom": {
          "custom-lib": "models/Secondary_Preprocess/libpassthrough.so",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10
        }
      },
      {
        "nvinfer": {
          "process-mode": 2,
          "config-file-path": "dstest2_sgie2_config.txt"
        }
      },
      {
        "emcustom": {
          "custom-lib": "models/Secondary_Postprocess/libpassthrough.so",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10
        }
      }
    ],
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 10
    }
  }

--------------------------------
EMI Torch 3DCNN
--------------------------------

This is a template to demonstrate the usage of an advanced deep leraning model of PyTorch with EMPyCustom. For more infomration about EMPyCustom, please refer to the EMPyCustom chapter.

The advanced model is a pre-trained `ResNet 3D 18` of `the video classification <http://pytorch.org/vision/main/models.html#video-classification>`_.

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
          "batch-size": 1,
          "width": 640,
          "height": 360
        },
        "empycustom": {
          "custom-lib": "video_classification.py",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10,
          "options": {
            "labels": [
              "abseiling",
              "air_drumming",
              "answering_questions",
              "applauding",
              "applying_cream",
              "archery",
              "arm_wrestling",
              "arranging_flowers",
              "assembling_computer",
              "auctioning",
              "=======",
              "water_skiing",
              "water_sliding",
              "watering_plants",
              "waxing_back",
              "waxing_chest",
              "waxing_eyebrows",
              "waxing_legs",
              "weaving_basket",
              "welding",
              "whistling",
              "windsurfing",
              "wrapping_present",
              "wrestling",
              "writing",
              "yawning",
              "yoga",
              "zumba"
            ]
          }
        },
        "overlay": {
          "display-clock": 1
        },
        "aimeta": {
          "signal-interval": 10
        }
    }

-----------------------------------
EMI Torch Imagenet Yolo IOU Counter
-----------------------------------

This is a template to demonstrate the usage of an advanced deep leraning model of PyTorch with EMPyCustom as a secondary inference together with deepstream elements. For more infomration about EMPyCustom, please refer to the EMPyCustom chapter.

The PyTorch model is a pre-trained `SqueezeNet` of `the classification <http://pytorch.org/vision/main/models.html#classification>`_. It works as a secondary inference with the Yolo v3 primary inference and an iou tracker.

The pipeline of this template consists of:

.. code-block:: json

  "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 360,
      "height": 360
    },
    "primary": {
      "process-mode": 1,
      "config-file-path": "config_infer_primary_yoloV3.txt",
      "interval": 10
    },
    "tracker": {
      "ll-config-file": "iou_config.txt",
      "ll-lib-file": "libnvds_mot_iou.so"
    },
    "empycustom": {
      "custom-lib": "classification.py",
      "in-place": "true",
      "format": "RGBA",
      "process-interval": 10,
      "options": {
        "labels": [
          "tench",
          "goldfish",
          "great_white_shark",
          "tiger_shark",
          "hammerhead_shark",
          "electric_ray",
          "stingray",
          "cock",
          "=========",
          "agaric",
          "gyromitra",
          "stinkhorn_mushroom",
          "earth_star",
          "hen-of-the-woods",
          "bolete",
          "ear",
          "toilet_paper"

        ]
      }
    },
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 1
    }
  }

--------------------------------
Facenet
--------------------------------

This template is to demonstrate the usage of the lagendary detection model called `detectnet <https://developer.nvidia.com/blog/detectnet-deep-neural-network-object-detection-digits/>`_ desgined by NVIDIA.

A custom output parser function is provided as a custom library as below. It is configured in the dstest1_pgie_config.txt.

.. code-block:: bash


    custom-lib-path=nvdsinfer_custom_lib/libnvdsinfer_custom_impl.so
    parse-bbox-func-name=NvDsInferParseDetectNet


The pipeline of this template consists of:

.. code-block:: json

  "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 1920,
      "height": 1080
    },
    "primary": {
      "process-mode": 1,
      "config-file-path": "dstest1_pgie_config.txt"
    },
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 10
    }
  }

============================================================
IoT templates
============================================================

=================================== =============================== =============================
template name                       signal                          stream                    
=================================== =============================== =============================
EMI IoT Sensor Monitor              iot.json                        sensor_stream
EMI Simple UDP                      iot.json                        udp_stream
EMI Simple Recorder                 iot.json                        simple_recorder_stream
=================================== =============================== =============================

--------------------------------
EMI IoT Sensor Monitor
--------------------------------

This template is one of CPU apps that demonstrates the usage of an IoT sensor processing. A sensor reading from a supported cdcacm device arrives at a pre-configured udp port of an EDGEMATRIX Stream. This template assumes a river monitoring sensor. Futher details are not covered here because it is beyond the scope of this tutorial.

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 1920,
            "height": 1080
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Simple UDP
--------------------------------

This template is one of CPU apps that demonstrates the usage of a simple UDP input processing. In addition to an RTSP stream, an udp source can be added to inputs of an EDGEMATRIX Stream by configuring the `udp_location` of a stream config as below. In this case, any data arrived through a udp port, 3333, of a loopback address, is passed to an EDGEMATRIX Stream for further processings.

.. code-block:: bash

    $ grep udp_location streams/udp_stream/udp_stream_configuration.json 
    "udp_location": "127.0.0.1:3333",

The pipeline of this template consists of:

.. code-block:: json

    "pipeline_configuration": {
        "input": {
            "batch-size": 1,
            "width": 1920,
            "height": 1080
        },
        "overlay": {
            "display-clock": 1
        },
        "aimeta": {
            "signal-interval": 10
        }
    }

--------------------------------
EMI Simple Recorder
--------------------------------

This template is one of CPU apps that allows an end user to record by some simple but rich features.

The pipeline of this template consists of:

.. code-block:: json

  "pipeline_configuration": {
    "input": {
      "batch-size": 1,
      "width": 1920,
      "height": 1080
    },
    "overlay": {
      "display-clock": 1
    },
    "aimeta": {
      "signal-interval": 30
    }
  }