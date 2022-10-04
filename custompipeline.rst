Custom AI pipeline
=========================================

--------------------------------------------------------
Overview
--------------------------------------------------------

You can create your own ai pipelines for primary and secondary inference instead of using a simple inference network. We let the developers add their own element ordering as an array in the primary and secondary fields, to be used on the construction of this pipeline. If primary or secondary contains a dictionary, a single nvinfer element will be added to the pipeline, if instead these fields contain an array of dictionaries EdgeStream will form a pipeline with the element present in the array.

--------------------------------------------------------
Supported Elements
--------------------------------------------------------

The elements supported in this array are:

* nvinfer
* emcustom
* empycustom

--------------------------------------------------------
Considerations
--------------------------------------------------------

Some important considerations with this feature:

#. The elements will be added to the pipeline in the same order as they are specified in the array.
#. Deepstream doesn't support linking multiple primary inference elements back to back, so the primary array is limited to one nvinfer element.
#. emcustom/empycustom operates on CPU. If you add it to the pipeline this will cause an additional memory copy and a dip in performance.
#. Make sure that if you access metadata in emcustom/empycustom there is an element adding it before. For example, do not access detection meta before the primary nvinfer element.
#. You can not edit pipeline details in the GUI, which will be simply disabled for an app with a custom pipeline as below. So, you have to write such a config file by yourself. But all the features rest are available.

    .. image:: images/custompipeline/customapp_gui.png
       :align: center

--------------------------------------------------------
Possible Combinations
--------------------------------------------------------

The following examples illustrate some possible combinations available with this feature.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Basic Patterns without EMPyCustom
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These patterns can be used as basic patterns having nvinfer as main inference element.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Custom pre-processing and post-processing on the primary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This will be configured in a config as follows.

.. code-block:: javascript

    "primary": [
        {
          "emcustom": {...}
        },
        {
          "nvinfer": {...}
        },
        {
          "emcustom": {...}
        }
    ],
    "secondary": [
        {
          "nvinfer": {...}
        }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/custom_prepost.png
       :align: center

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Multiple secondaries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This will be configured in a config as follows.

.. code-block:: javascript

    "primary": [
        {
          "nvinfer": {...}
        }
    ],
    "secondary": [
        {
          "nvinfer": {...}
        },
        {
          "nvinfer": {...}
        },
        {
          "nvinfer": {...}
        }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/multisecondaries.png
       :align: center

In the templates, this is available as ``EMI Vehicle Multiple Secondaries``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Post-processing on primary and secondary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This will be configured in a config as follows.

.. code-block:: javascript

    "primary": [
        {
          "nvinfer": {...}
        },
        {
          "emcustom": {...}
        }
    ],
    "secondary": [
        {
          "nvinfer": {...}
        },
        {
          "emcustom": {...}
        }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/prepost.png
       :align: center

In the templates, this is available as ``EMI Vehicle PrePost EMCustom``.

Note that emcustom has to be used inside an array of a primary or a secondary. When you place an emcustom as an independent element, it will hide secondary.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Advanced Patterns with EMPyCustom
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These patterns can be used as advanced patterns having EMPyCustom.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMPyCustom without primary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use empycustom as the only processing element of the pipeline, without adding any other DeepStream element.

This will be configured in a config as follows.

.. code-block:: javascript

      "empycustom": {
        "custom-lib": "video_classification.py",
        "in-place": "true",
        "format": "RGBA",
        "process-interval": 10
      },

And it can be illustrated as below.

    .. image:: images/custompipeline/empycustom_without_primary.png
       :align: center

In the templates, this is available as ``EMI Torch 3DCNN``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMPyCustom as a secondary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this case, we use DeepStream (nvinfer) for the primary inference model and empycustom as a secondary (perform classification with PyTorch over the bounding boxes detected with DeepStream).

This will be configured in a config as follows.

.. code-block:: javascript

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
      },

And it can be illustrated as below.

    .. image:: images/custompipeline/empycustom_secondary.png
       :align: center

In the templates, this is available as ``EMI Torch Imagenet Yolo IOU Counter``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMPyCustom as a secondary post-process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this case, the pipeline has DeepStream elements for both primary and secondary inference and empycustom is used to perform additional operations that can be performed on a specific class.

This will be configured in a config as follows.

.. code-block:: javascript

      "primary": {
        "process-mode": 1,
        "config-file-path": "config_infer_primary_yoloV3.txt",
        "interval": 10
      },
      "tracker": {
        "ll-config-file": "iou_config.txt",
        "ll-lib-file": "libnvds_mot_iou.so"
      },
      "secondary": [
        {
          "nvinfer": {
            "process-mode": 2,
            "config-file-path": "dstest2_sgie2_config.txt"
          }
        },
        "empycustom": {
          "custom-lib": "postprocess.py",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10,
        }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/empycustom_secondary_postprocess.png
       :align: center

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMPyCustom as a part of multiple secondaries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this case, the secondary pipeline is conformed by multiple processing elements. These elements can be any combination of empycustom, emcustom, and nvinfer.

This will be configured in a config as follows.

.. code-block:: javascript

      "primary": {
        "process-mode": 1,
        "config-file-path": "config_infer_primary_yoloV3.txt",
        "interval": 10
      },
      "tracker": {
        "ll-config-file": "iou_config.txt",
        "ll-lib-file": "libnvds_mot_iou.so"
      },
      "secondary": [
        {
          "emcustom": {
            "custom-lib": "preprocess.so",
            "in-place": "true",
            "format": "RGBA",
            "process-interval": 10
        },
        {
          "nvinfer": {
            "process-mode": 2,
            "config-file-path": "dstest2_sgie2_config.txt"
          }
        },
        "empycustom": {
          "custom-lib": "postprocess.py",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10,
        }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/empycustom_multiple_secondary.png
       :align: center

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMPyCustom as a part of multiple primaries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Similar to the previous case with the restriction that emcustom and empycustom can't be used as a primary pre-process, so the primary list of elements must start with nvinfer.

This will be configured in a config as follows.

.. code-block:: javascript

      "primary": [
      {
        "nvinfer": {
          "process-mode": 1,
          "config-file-path": "dstest1_pgie_config.txt"
        }
      },
      {
        "emcustom": {
          "custom-lib": "models/Secondary_Postproccess/postprocess.so",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10
        }
      },
      {
        "empycustom": {
          "custom-lib": "models/Secondary_Postproccess/postprocess.py",
          "in-place": "true",
          "format": "RGBA",
          "process-interval": 10
        }
      }
    ]
    },
      "tracker": {
        "ll-config-file": "iou_config.txt",
        "ll-lib-file": "libnvds_mot_iou.so"
      },
      "secondary": [
      {
        "nvinfer": {
          "process-mode": 2,
          "config-file-path": "dstest2_sgie2_config.txt"
        }
      }
    ]

And it can be illustrated as below.

    .. image:: images/custompipeline/empycustom_multiple_primary.png
       :align: center
