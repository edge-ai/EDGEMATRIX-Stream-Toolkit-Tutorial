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

    #. EMI Vehicle EMCustom
    #. EMI Vehicle PrePost EMCustom
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

================================== =============================== =============================
template name                      signal                          stream                    
================================== =============================== =============================
EMI Pedestrian DCF Counter         pedestrial_signal.json          pedestrian_stream
EMI Pedestrian IOU Counter         pedestrial_signal.json          pedestrian_stream
EMI Pedestrian KLT Counter         pedestrial_signal.json          pedestrian_stream
EMI Vehicle Counter                my_signal.json                  vehicle_stream
EMI Vehicle DCF Counter By Color   my_signal.json                  vehicle_stream
EMI Vehicle IOU Counter By Make    my_signal.json                  vehicle_stream
EMI Vehicle Multiple Secondaries   my_signal.json                  vehicle_stream
Yolo V3 Detector                   yolo_signal.json                yolo_stream
Yolo V3 Tiny Detector              yolo_signal.json                yolo_stream
EMI Semantic Segmentation          segmentation_signal.json        segmentation_stream
================================== =============================== =============================

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

================================== =============================== =============================
template name                      signal                          stream                    
================================== =============================== =============================
EMI Vehicle EMCustom               my_signal.json                  vehicle_emcustom_stream
================================== =============================== =============================

--------------------------------
EMI Vehicle EMCustom
--------------------------------

emcustom

--------------------------------
EMI Vehicle PrePost EMCustom
--------------------------------

emcustom prepost

--------------------------------
EMI Torch 3DCNN
--------------------------------

PyTorch 3DCNN

-----------------------------------
EMI Torch Imagenet Yolo IOU Counter
-----------------------------------

torch imagenet + yolo

--------------------------------
Facenet
--------------------------------

facenet

============================================================
IoT templates
============================================================

================================== =============================== =============================
template name                      signal                          stream                    
================================== =============================== =============================
EMI IoT Sensor Monitor             iot.json                        sensor_stream
================================== =============================== =============================

--------------------------------
EMI IoT Sensor Monitor
--------------------------------

udp + cdcacm (usb045a)

--------------------------------
EMI Simple UDP
--------------------------------

udp

--------------------------------
EMI Simple Recorder
--------------------------------

recorder
