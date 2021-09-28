EMCustom
=====================

============================================================
Description
============================================================

The GstEMCustom is a GStreamer element that allows a user to perform an arbritrary operation on a buffer and its metadata.

Functions can be implemented either in-place on a single io buffer, or with both an input and an output buffer. In both cases an input and output metadata is provided, the input one contains the information from the primary detector and the output one contains the user data.

The format and video resolution can be queried from the video_data structure. This structure also contains up to 3 pointers to the actual data depending on the format, e.g. RGBA has a single plane, therefore, a single pointer and I420 has 3 planes and 3 pointers.

The output metadata should be allocated by the custom function, and it will be freed by the element.

Both of the process and the in-place process can be implemented but only one of these will be executed at the time, this is controlled by a parameter in the configuration file.

============================================================
Properties and Signals
============================================================

.. code-block:: javascript

  Element Properties:
    name                : The name of the object
                          flags: readable, writable
                          String. Default: "emcustom0"
    parent              : The parent of the object
                          flags: readable, writable
                          Object of type "GstObject"
    qos                 : Handle Quality-of-Service events
                          flags: readable, writable
                          Boolean. Default: true
    silent              : Enable/Disable signal emission
                          flags: readable, writable
                          Boolean. Default: false
    last-meta           : Last Meta available to read
                          flags: readable
                          String. Default: null
    process-interval    : Interval (in buffers) to process
                          flags: readable, writable
                          Integer. Range: 1 - 2147483647 Default: 1 
    custom-lib          : custom library where the function will be found
                          flags: readable, writable
                          String. Default: "(null)"
    in-place            : Process buffer in place or not
                          flags: readable, writable
                          Boolean. Default: true
    options             : JSON string containing options to be passed to the custom library
                          flags: readable, writable
                          String. Default: null
    events              : JSON string containing events to be passed to the custom library,
                          updated, and added to the emcustom meta
                          flags: readable, writable
                          String. Default: null

  Element Signals:
    "emcustom" :  void user_function (GstElement* object,
                                      gpointer user_data);

============================================================
Usage and Examples
============================================================

.. code-block:: bash

  gst-launch-1.0 uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream/samples/streams/sample_1080p_h264.mp4" ! queue  ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 batched-push-timeout=40000 width=1280 height=720 live-source=TRUE ! queue ! nvvideoconvert ! queue ! \
  nvinfer config-file-path="/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_infer_primary_nano.txt" model-engine-file="/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_fp16.engine" ! queue ! nvvidconv ! \
  emcustom custom-lib=/mnt/nvme/toolkit_home/libs/gst-emcustom/build/examples/libaverage_intensity.so  ! fakesink

============================================================
Debugging
============================================================

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Visualizing output frame
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Replace `fakesink` in the pipeline above by `videoconvert ! xvimagesink`.

.. code-block:: bash

  $ gst-launch-1.0 uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream/samples/streams/sample_1080p_h264.mp4" ! queue  ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 batched-push-timeout=40000 width=1280 height=720 live-source=TRUE ! queue ! nvvideoconvert ! queue ! \
  nvinfer config-file-path="/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_infer_primary_nano.txt" model-engine-file="/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_fp16.engine" ! queue ! nvvidconv ! \
  emcustom custom-lib=/mnt/nvme/toolkit_home/libs/gst-emcustom/build/examples/libaverage_intensity.so  ! videoconvert ! xvimagesink

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Print output meta to console
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Add `GST_DEBUG=*emcustom*:6` before the `gst-launch-1.0` command
* Set the `silent` property to false.

.. code-block:: bash

  $ GST_DEBUG=*emcustom*:6 gst-launch-1.0 uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream/samples/streams/sample_1080p_h264.mp4" ! queue  ! nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 batched-push-timeout=40000 width=1280 height=720 live-source=TRUE ! queue ! nvvideoconvert ! queue ! nvinfer config-file-path="/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_infer_primary_nano.txt" model-engine-file="/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_fp16.engine" ! queue ! nvvidconv ! emcustom name=emcustom custom-lib=/mnt/nvme/toolkit_home/libs/gst-emcustom/build/examples/libaverage_intensity.so silent=false  ! fakesink

* You will see the metas in the console like this:

.. code-block:: javascript

  0:00:05.009899485  9240   0x55b8829370 DEBUG               emcustom gstemcustom.c:403:gst_emcustom_add_meta:<emcustom> New Meta: [
    {
    },
    {
    },
    {
    },
    {
      "average_intensity" : 72
    },
    {
      "average_intensity" : 106
    },
    {
      "average_intensity" : 91
    }
  ]

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Reading the output meta from the property
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The element exposes the last meta through the `last-meta` property:

.. code-block:: bash

  $ gstd

  # Launch pipeline
  $ gstd-client pipeline_create pipe uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream/samples/streams/sample_1080p_h264.mp4" ! queue  ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 batched-push-timeout=40000 width=1280 height=720 live-source=TRUE ! queue ! nvvideoconvert ! queue ! \
  nvinfer config-file-path="/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_infer_primary_nano.txt" model-engine-file="/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_fp16.engine" ! queue ! nvvidconv ! \
  emcustom name=emcustom custom-lib=/mnt/nvme/toolkit_home/libs/gst-emcustom/build/examples/libaverage_intensity.so silent=false  ! fakesink

  # Play pipeline
  $ gstd-client pipeline_play pipe

  # You can ask for the last-meta property in the emcustom to check if there is a new value
  $ gstd-client element_get pipe emcustom last-meta

  # Stop pipeline
  $ gstd-client pipeline_delete pipe

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Wait for signal before reading last meta property
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The EMCustom element can signal that a frame has been processed, this avoids having to add an sleep in the instructions:

.. code-block:: bash

  $ gstd

  # Launch pipeline
  $ gstd-client pipeline_create pipe uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream/samples/streams/sample_1080p_h264.mp4" ! queue  ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 batched-push-timeout=40000 width=1280 height=720 live-source=TRUE ! queue ! nvvideoconvert ! queue ! \
  nvinfer config-file-path="/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_infer_primary_nano.txt" model-engine-file="/opt/nvidia/deepstream/deepstream/samples/models/Primary_Detector_Nano/resnet10.caffemodel_b8_fp16.engine" ! queue ! nvvidconv ! \
  emcustom name=emcustom custom-lib=/mnt/nvme/toolkit_home/libs/gst-emcustom/build/examples/libaverage_intensity.so silent=false  ! fakesink

  # Play pipeline
  $ gstd-client pipeline_play pipe

  # Wait for notify signal
  $ gstd-client signal_connect pipe emcustom emcustom

  # Reads last produced meta
  $ gstd-client element_get pipe emcustom last-meta

  # Stop pipeline
  $ gstd-client pipeline_delete pipe


============================================================
Interface
============================================================

.. code-block:: cpp

  #define MAX_N_PLANES 3
  #include "gstnvdsmeta.h"

  /**
   * List of supported formats
   */
  enum video_format {
    VIDEO_FORMAT_I420,
    VIDEO_FORMAT_RGBA,
    VIDEO_FORMAT_UNKNOWN,
    VIDEO_FORMATS_LENGHT,
  };

  /**
   * Information for a video channel
   *
   * @param data Pointer to the video data
   * @param stride Stride for the the current video channel
   */
  struct video_channel {
    void *data;
    int stride;
  };

  /**
   * Information for a frame's data
   *
   * @param video_format Video format for the current frame
   * @param width Width of the current frame
   * @param height Height of the current frame
   * @param channels Channels for the current frame, up to MAX_N_PLANES can be included
   */
  struct video_data {
    int video_format;
    int width;
    int height;
    struct video_channel channels[MAX_N_PLANES];
  };

  /**
   * This function allows a custom function to be applied to a video stream
   *
   * @param in_buffer Input buffer.
   *
   * @param in_meta Input meta in a JSON format.
   *
   * @param out_buffer Output buffer, if no data is copied over here the
   * output frame will be empty.
   *
   * @param out_meta Output meta in a JSON format. The input metadata
   * is moved over by the gstemcustom element so this should only
   * contain the custom metadata. This buffer can have an arbitrary size
   * and its memory will be freed by the gstemcustom element.
   *
   * @param options JSON string containing custom configurable options
   *
   * @param events JSON string containing external events that can be used
   * to share variables with emcustom upstream
   *
   * @param batch_meta DeepStream batch meta pointer.
   *
   */
  void process (const struct video_data *in_buffer, const char *in_meta,
          struct video_data *out_buffer, char **out_meta, const char *options,
    const char *events, NvDsBatchMeta *batch_meta);

  /**
   * This function allows a custom function to be applied to an in-place video stream
   *
   * @param io_buffer Input/Output buffer
   *
   * @param io_meta Input meta in a json format
   *
   * @param out_meta Output meta in a json format. The input meta data
   * is moved over by the gstemcustom element so this should only
   * contain the custom metadata. This buffer can have an arbitrary size
   * and its memory will be freed by the gstemcustom element.
   *
   * @param options JSON string containing custom configurable options
   *
   * @param events JSON string containing external events that can be used
   * to share variables with emcustom upstream
   *
   * @param batch_meta DeepStream batch meta pointer.
   *
   */
  void process_ip (struct video_data *io_buffer, const char *in_meta,
       char **out_meta, const char *options, const char *events,
    NvDsBatchMeta *batch_meta);

============================================================
How to add a custom library
============================================================

Following steps are required in case you want to compile and use your own custom library:

1. Create your custom library implementing the process and process_ip functions. You would need to place both functions, but it is not required to fill both, you can fill the one you will use. I will create a simple in-place library returning the same sample output meta for every buffer, so create a file called `new_lib.c`, and copy the following code:

.. code-block:: cpp

  /* 
   * Copyright (C) 2020 EDGEMATRIX, Inc.
   */

  #include "emcustom.h"

  #include <json-glib/json-glib.h>
  #include <stdio.h>


  void
  process (const struct video_data *in_buffer, const char *in_meta,
      struct video_data *out_buffer, char **out_meta, const char *options, 
      const char *events, NvDsBatchMeta *batch_meta)
  {
  }

  void
  process_ip (struct video_data *io_buffer, const char *in_meta, char **out_meta, 
    const char *options, const char *events, NvDsBatchMeta *batch_meta)
  {
    /* Create sample JSON */
    JsonBuilder *builder = json_builder_new ();
    JsonNode *node;

    builder = json_builder_begin_object (builder);
    json_builder_set_member_name (builder, "sample_int_output");
    json_builder_add_int_value (builder, 100);
    json_builder_end_object (builder);
    
    node = json_builder_get_root (builder);

    /* Transfer meta, this memory will be freed by the plugin */
    *out_meta = json_to_string (node, TRUE);

    /* Cleanup JSON resources */
    json_node_unref (node);
    g_object_unref (builder);
  }

* Any library can be used in this code for your processing, just ensure that the inputs and outputs match the provided interface.

This sample library generates the following sample meta:

.. code-block:: javascript

  {
    "sample_int_output" : 100
  }

2. Move the `new_lib.c` file to the `TOOLKIT_HOME/libs/gst-emcustom/examples` directory.

3. Add new lib to the meson build. Open the `examples/meson.build` file and add the following:

.. code-block:: python

  # Add new library
  new_lib_sources = [
      'new_lib.c'
  ]

  library('new_lib',
        new_lib_sources,
        c_args: c_args,
        dependencies : example_deps,
        include_directories: includes
  )

In case your library has a different name, just change `new_lib` by your library name in the above entry.

4. Compile gst-emcustom.

5. If the build was successful, you can find the compiled library at `gst-emcustom/build/examples/libnew_lib.so` and you can now use it in your pipeline through the custom-lib property in the EMCustom plugin.

============================================================
EMCustom Meta
============================================================

The EMCustom element uses the GstEMCustomMeta structure to move its data along the meta. Which can be seen in the following code snippets:

.. code-block:: cpp

  struct GstEMCustomMeta
  {
    GstMeta meta;

    gchar *custom;
  };

The custom structure contains custom data from the user represented with a JSON string with a particular structure. There are currently 2 structures supported for this field: Array (old) and object (new).


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Array structure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The array structure was designed initially to make adding metadata to the detected objects easy. The structure is composed by a single object array where every object corresponds to a detected object and the last element can be used to add metadata for the corresponding frame. For example, given 3 detected objects:

.. code-block:: javascript

  [
    {
      "custom_old": "object 0 meta"
    },
    {
      "custom_old": "object 1 meta"
    },
    {
      "custom_old": "object 2 meta"
    },
    {
      "custom_old": "frame 0 meta"
    }
  ]

The fields can be of any type supported by JSON and have any arbitrary name.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Object structure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The object structure was added to give developers more control over the meta they want to add without needing to worry about detected objects. It follows a structure similar to DeepStream meta, where a batch has a list frames and each frame has a list of objects. This structure allows several cases that are imposible with the array structure:

* Add batch meta
* Add frame meta without adding objects
* Add frame and object meta for frames other than the first one

Here is an example of this structure:

.. code-block:: javascript

  {
    "meta": {
      "custom_new": "batch meta"
    },
    "frame": [
      {
        "meta": {
          "custom_new": "frame 0 meta"
        },
        "object": [
          {
            "custom_new": "object 0 meta"
          },
          {
            "custom_new": "object 1 meta"
          },
          {
            "custom_new": "object 2 meta"
          }
        ]
      },
      {
        "meta": {
          "custom_new": "frame 1 meta"
        },
        "object": [
          {
            "custom_new": "object 0 meta"
          },
          {
            "custom_new": "object 1 meta"
          },
          {
            "custom_new": "object 2 meta"
          }
        ]
      }
    ]
  }

The root of the object is considered batch meta. It can have any of the following fields:

* frame: Array of frame objects
* meta: Object containing any arbitrary fields that represent meta linked to the whole batch

Each frame object represent meta for a given frame. It can have any of the following fields:

* object: Array of object objects
* meta: Object containing any arbitrary fields that represent meta linked to the frame

Each object object can contain any arbitrary fields that represent meta linked to the object

============================================================
EMCustom Integration
============================================================

Although any arbitrary JSON can be given as an output, integration into the EDGEMATRIX Stream is done on a per object basis. The input buffer will have a structure similar to the following:

.. code-block:: javascript

  {
    "frame": [
      {
        "frame_num": 1363,
        "buf_pts": 47119953884,
        "timestamp": "2020-05-13T12:18:47.323-0600",
        "object": [
          {
            "Info for object 1": ""
          },
          {
            "Info for object 2": ""
          },
          ...
          {
            "Info for final object": ""
          }
        ]
      }
    ]
  }

The output should consist of an array with information for each of the input objects:

.. code-block:: javascript

  [
    {
      "Arbitrary JSON for object 1"
    },
    {
      "Arbitrary JSON for object 2"
    },
    ...
    {
      "Arbitrary JSON for final object"
    },
  ]

The resulting JSON that will be received by the signal callback will have the following structure

.. code-block:: javascript

  {
    "frame": [
      {
        "frame_num": 1363,
        "buf_pts": 47119953884,
        "timestamp": "2020-05-13T12:18:47.323-0600",
        "object": [
          {
            "Info for object 1": ""
            "emcustom": "Arbitrary JSON for object 1"
          },
          {
            "Info for object 2": ""
            "emcustom": "Arbitrary JSON for object 2"
          },
          ...
          {
            "Info for final object": ""
            "emcustom": "Arbitrary JSON for final object"
          }
        ]
      }
    ]
  }

If not all objects have a corresponding JSON, the aimeta element will assign the elements it can in sequential order. Empty JSON strings: `{}` are valid and should be used for values where no data is to be passed to Edgestream.

Note that aimeta and emcustom only support batches of one frame. If the application is using batching greater than one, only the first frame (frame 0) will be processed.

============================================================
Examples
============================================================

These examples use the `JsonGlib <https://wiki.gnome.org/Projects/JsonGlib>`_ parser.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Passthrough
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example shows how to parse the data for `I420` and `RGBA` formatted buffers.

The following function performs a passthrough operation on the buffer and counts the average intensity of this buffer. The average intensity of the whole frame is added as the single parameter to the output metadata. This example doesn't represent an integration into EDGESTREAM. Check the Average Intensity example for the relevant example.

.. code-block:: cpp

  /* This line adds the definitions for the functions and structure declarations */
  #include "emcustom.h"

  /* Any library can be added here in order to perform the processing */
  #include <json-glib/json-glib.h>
  #include <stdio.h>

  #define RGBA_PIXEL_WIDTH 4
  #define I420_N_PLANES 3

  void
  process (const struct video_data *in_buffer, const char *in_meta,
      struct video_data *out_buffer, char **out_meta, const char *options,
      const char *events, NvDsBatchMeta *batch_meta)
  {
    JsonBuilder *builder = json_builder_new ();
    JsonNode *node;
    GError *error = NULL;
    unsigned char *in_data, *out_data;
    int plane_width, plane_height;
    int total_intensity = 0;
    int total_count = 0;
    int i, j, k;

    if (in_buffer->video_format == VIDEO_FORMAT_RGBA) {
      in_data = (unsigned char *) in_buffer->channels[0].data;
      out_data = (unsigned char *) out_buffer->channels[0].data;

      plane_height = in_buffer->height;
      plane_width = in_buffer->width;

      for (j = 0; j < plane_height; j++) {
        for (k = 0; k < plane_width; k++) {
          for (i = 0; i < RGBA_PIXEL_WIDTH; i++) {
            out_data[j * out_buffer->channels[0].stride + k * RGBA_PIXEL_WIDTH +
                i] =
                in_data[j * in_buffer->channels[0].stride + k * RGBA_PIXEL_WIDTH +
                i];

            total_intensity +=
                in_data[j * in_buffer->channels[0].stride + k * RGBA_PIXEL_WIDTH +
                i];
            total_count++;
          }
        }
      }
    } else if (in_buffer->video_format == VIDEO_FORMAT_I420) {

      for (i = 0; i < I420_N_PLANES; i++) {
        in_data = (unsigned char *) in_buffer->channels[i].data;
        out_data = (unsigned char *) out_buffer->channels[i].data;

        if (i == 0) {
          plane_height = in_buffer->height;
          plane_width = in_buffer->width;
        } else {
          plane_height = in_buffer->height / 2;
          plane_width = in_buffer->width / 2;
        }

        for (j = 0; j < plane_height; j++) {
          for (k = 0; k < plane_width; k++) {
            out_data[j * out_buffer->channels[i].stride + k] =
                in_data[j * in_buffer->channels[i].stride + k];

            total_intensity += in_data[j * in_buffer->channels[i].stride + k];
            total_count++;
          }
        }
      }
    }

    node = json_from_string (in_meta, &error);

    builder = json_builder_begin_object (builder);

    builder = json_builder_set_member_name (builder, "total_intensity");
    builder = json_builder_add_int_value (builder, total_intensity / total_count);

    builder = json_builder_end_object (builder);

    node = json_builder_get_root (builder);

    *out_meta = json_to_string (node, TRUE);

    json_node_unref (node);
    g_object_unref (builder);

  }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Average Intensity in a person ROI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example parses the input meta to determine the ROI for a primary engine person. Then for each of the ROIs it determines the average intensity.

.. code-block:: cpp

  /**
   * Sample Input Meta from a primary detector
   *{
   *  "frame": [
   *    {
   *      "frame_num": 10,
   *      "buf_pts": 1205528297,
   *      "ntp_timestamp": 0,
   *      "object": [
   *        {
   *          "class_id": 0,
   *          "object_id": -1,
   *          "confidence": 2.129973665773722e-43,
   *          "rect_params": {
   *            "left": 925,
   *            "top": 386,
   *            "width": 74,
   *            "height": 47
   *          },
   *          "text_params": {
   *            "display_text": "Car"
   *          },
   *          "classifier": []
   *        },
   *        {
   *          "class_id": 2,
   *          "object_id": -1,
   *          "confidence": 2.0318827732709848e-43,
   *          "rect_params": {
   *            "left": 840,
   *            "top": 405,
   *            "width": 66,
   *            "height": 42
   *          },
   *          "text_params": {
   *            "display_text": "Person"
   *          },
   *          "classifier": []
   *        }
   *      ]
   *    }
   *  ]
   *}
   */

  /**
   * Output must have the following structure
   *  [
   *    {
   *      Info for first object
   *    },
   *    {
   *      Info for second object
   *    },
   *    ...
   *    {
   *      Info for last object
   *    }
   *  ]
   *
   * Each object in the input json should have a matching element in
   * the output array.
   */

  void
  process_ip (struct video_data *io_buffer, const char *in_meta, char **out_meta, 
              const char *options, const char *events, NvDsBatchMeta *batch_meta)
  {
    GError *error = NULL;
    unsigned char *in_data;
    int i, j, k;

    JsonBuilder *builder = json_builder_new ();
    JsonNode *input_node, *output_node;
    JsonArray *in_array, *out_array;
    JsonObject *in_object, *out_object;

    GList *l, *object_list;
    int intensity = 0, count = 0;
    int left, top, width, height, class_id;

    /* Extract the input data, this assumes RGBA data */
    in_data = (unsigned char *) io_buffer->channels[0].data;

    /* Parsing input Meta */
    /* Frame node */
    input_node = json_from_string (in_meta, &error);

    if (error) {
      printf ("ERROR in JSON parsing: %s", error->message);
      g_error_free (error);
      goto out;
    }
    /* Frame Array */
    in_array =
        json_object_get_array_member (json_node_get_object (input_node), "frame");

    /* First Element in frame array */
    in_object = json_array_get_object_element (in_array, 0);

    /* Get object array */
    in_array = json_object_get_array_member (in_object, "object");

    /* Get object list, this is a list of JsonNode */
    object_list = json_array_get_elements (in_array);

    /* Prepare output array */

    /* Writing output to meta */
    builder = json_builder_begin_object (builder);

    out_array = json_array_new ();

    for (l = object_list; l != NULL; l = l->next) {
      in_object = json_node_get_object (l->data);
      out_object = json_object_new ();

      class_id =
          json_node_get_int (json_object_get_member (in_object, "class_id"));
      /* Filter people only */
      if (class_id == 2) {
        in_object = json_object_get_object_member (in_object, "rect_params");

        left = json_node_get_int (json_object_get_member (in_object, "left"));
        top = json_node_get_int (json_object_get_member (in_object, "top"));
        width = json_node_get_int (json_object_get_member (in_object, "width"));
        height = json_node_get_int (json_object_get_member (in_object, "height"));

        /**
         * Running custom processing
         *
         * This function will get the average intensity for each of the
         * input rectangles.
         */
        intensity = 0;
        count = 0;
        for (j = top; j < (top + width); j++) {
          for (k = left; k < (left + height); k++) {
            for (i = 0; i < RGBA_PIXEL_WIDTH; i++) {
              intensity +=
                  in_data[j * io_buffer->channels[0].stride +
                  k * RGBA_PIXEL_WIDTH + i];
              count++;
            }
          }
        }
        json_object_set_int_member (out_object,
            "average_intensity", (intensity / count));
      }

      json_array_add_object_element (out_array, out_object);
    }

    output_node = json_node_init_array (json_node_alloc (), out_array);

    *out_meta = json_to_string (output_node, TRUE);

    g_list_free (object_list);
    json_node_unref (output_node);
  out:
    json_node_unref (input_node);
  }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EmCustom options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Additional options can be passed to the custom library using the `options` property. This property is a string that contains a serialized JSON object and is passed as a parameter from the EDGEMATRIX Stream to the custom library process method.

The JSON that will be passed is defined in a similar way to the emcustom element properties in the `emi_stream_config.json`:

.. code-block:: javascript

    "emcustom": {
      "custom-lib": "models/Secondary_AverageIntensity/libaverage_intensity.so",
      "in-place": "true",
      "format": "RGBA",
      "process-interval": 10,
      "options": {
        "person_class_id": 2
      }

The options field can contain any data type available in the JSON format but it is the user's responsibility to parse the JSON correctly in the custom library.

The options are received in the custom library as a parameter in both process functions:

.. code-block:: cpp

  void
  process_ip (struct video_data *io_buffer, const char *in_meta, char **out_meta, 
      const char *options, const char *events, NvDsBatchMeta *batch_meta)
  ...
  void
  process (const struct video_data *in_buffer, const char *in_meta,
      struct video_data *out_buffer, char **out_meta, const char *options,
      const char *events, NvDsBatchMeta *batch_meta)

And can be parsed using any JSON library:

.. code-block:: cpp

  /* Parsing Options */
  person_class_id = 2;
  if (options) {
    error = NULL;
    options_node = json_from_string (options, &error);
    if (error) {
      printf ("ERROR in JSON parsing: %s", error->message);
      g_error_free (error);
      goto out;
    } else {
      person_class_id =
          json_object_get_int_member (json_node_get_object (options_node),
          "person_class_id");
    }
  }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Batch meta from custom library
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The custom library receives batch_meta as a parameter, which is a DeepStream batch meta pointer (NvDsBatchMeta). This pointer can be used to access all the meta fields defined in NvDsBatchMeta:

.. code-block:: 

  ├── batch_user_meta_list
  ├── frame_meta_list
  │   ├── display_meta_list
  │   ├── frame_user_meta_list
  │   └── obj_meta_list
  │       ├── classifier_meta_list
  │       └── obj_user_meta_list
  ├── max_frames_in_batch
  └── num_frames_in_batch

  The following example describes how to access the batch_user_meta_list

.. code-block:: c

  #include "gstnvdsmeta.h"

  ...

  NvDsUserMetaList *batch_user_meta_list;
  NvDsUserMeta *user_meta;
  batch_user_meta_list = batch_meta->batch_user_meta_list;
  while (batch_user_meta_list != NULL) {
    user_meta = (NvDsUserMeta *) batch_user_meta_list->data;
    // Cast user meta to the specific type
  }

Access NvDsInferSegmentationMeta

.. code-block:: c

  NvDsFrameMetaList *frame_meta_list;
  NvDsFrameMeta *frame_meta;
  NvDsUserMetaList *frame_user_meta_list;
  NvDsInferSegmentationMeta *segmentation_meta;

  frame_user_meta_list = batch_meta->frame_user_meta_list;
  while (frame_meta_list != NULL) {
    frame_meta = (NvDsFrameMeta *) frame_meta_list->data;
    frame_user_meta_list = frame_meta->frame_user_meta_list;
    while (frame_user_meta_list != NULL) {
      segmentation_meta = (NvDsInferSegmentationMeta *) frame_user_meta_list->data;
      // Use segmentation_meta
      frame_user_meta_list = frame_user_meta_list->next;
    }
    frame_meta_list = frame_meta_list->next;
  }

  ...