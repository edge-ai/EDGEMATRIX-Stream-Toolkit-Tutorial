EMPyCustom
=====================

============================================================
Description
============================================================

GstEmPyCustom is a Python implementation of the GstEMCustom element. Just like its C counterpart it allows a user to perform an arbitrary operation on a buffer and its metadata but with the advantage that the operations are written in Python.

Unlike emcustom, this element doesn't provide a video data structure, instead, it passes the GstBuffer directly to the custom library. This was implemented to allow the user to use any API to map the buffer. The description of this buffer(width, height, planes, etc) is available as part of the input meta dictionary. The not-in-place method needs to allocate a new GstBuffer and return it as output to the element.

============================================================
Properties and Signals
============================================================

.. code-block:: javascript

  Element Properties:
    name                : The name of the object
                          flags: readable, writable
                          String. Default: "gstempycustom+gstempycustom0"
    parent              : The parent of the object
                          flags: readable, writable
                          Object of type "GstObject"
    qos                 : Handle Quality-of-Service events
                          flags: readable, writable
                          Boolean. Default: false
    custom-lib          : Custom python library where the function will be found
                          flags: readable, writable
                          String. Default: null
    in-place            : Process buffer in place or not
                          Boolean. Default: false
    last-meta           : Last Meta available to read
                          flags: readable
                          String. Default: null
    options             : dict string containing options to be passed to the custom library
                          flags: readable, writable
                          String. Default: null
    process-interval    : Interval (in buffers) to process
                          flags: readable, writable
                          Integer. Range: 1 - 2147483647 Default: 0 
    silent              : Enable/Disable signal emission
                          flags: readable, writable
                          Boolean. Default: false


============================================================
Element Caps
============================================================

The element can receive CPU memory (normal memory) or NVIDIA's shared CPU/GPU memory (NVMM). In theory, the output caps can be any of the input formats, but we are limited by the GObject bindings, so the input and output caps must be the same. Note that this is not enforced in the element.

.. code-block:: javascript

        video/x-raw
                   format: { (string)RGBA, (string)I420 }
                    width: [ 1, 2147483647 ]
                   height: [ 1, 2147483647 ]
                framerate: [ 0/1, 2147483647/1 ]
        video/x-raw(memory:NVMM)
                   format: { (string)RGBA, (string)NV12 }
                    width: [ 1, 2147483647 ]
                   height: [ 1, 2147483647 ]
                framerate: [ 0/1, 2147483647/1 ]

============================================================
Virtual Methods
============================================================

Due to a limitation on the GObject python bindings, the GStreamer buffer can only de mapped for read-only. This means that we can not create an output buffer and thus the process method should never be used.

* start(options): This method is called once during element start. Any computational-intensive tasks that need to be performed once should be called here. For example, loading models in memory or configuring libraries. The options JSON is passed to the method for any argument that might need to be passed to the method from the stream configuration. Implementing this method is completely optional.
* stop(options): This method is called once during element stop. It should free all the memory that the Python Garbage collector can't free. The options JSON is passed to the method for any argument that might need to be passed to the method from the stream configuration. Implementing this method is completely optional.
* process(in_buffer, in_meta, options): This method is called for every buffer received by the element. It receives an input buffer and meta and must create a new output buffer to return it alongside the output meta. The options JSON is passed to the method for any argument that might need to be passed to the method from the stream configuration. This method must be implemented if the property in-place is set to false, otherwise, the element will return an error. **Note that due to limitations in the current version of the GObject python bindings this method is useless because a GstBuffer can not be mapped for writing. Because of that, in-place should always be set to true.**
* process_ip(in_buffer, in_meta, options): This method is called for every buffer received by the element. It receives an input/output buffer to process it in place. The options JSON is passed to the method for any argument that might need to be passed to the method from the stream configuration. This method must be implemented if the property in-place is set to true, otherwise, the element will return an error. **Note that due to limitations in the current version of the GObject python bindings the buffer can be only mapped for reading.**

============================================================
Usage and Examples
============================================================

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Mapping the buffer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this section I will present an example of how to map the buffer in Python for each of the cases from the input caps:

* Normal memory, RGBA:

.. code-block:: python

  # Get the map info of the buffer
  # In the current version of the GObject python bindings the buffer can be only mapped for reading
  ret, map_info = io_buffer.map(Gst.MapFlags.READ)
  # Use the map info to map the data as a numpy array
  buffer_array = np.ndarray(shape=(h, w, 4), dtype=np.uint8,buffer=map_info.data)
  # You can convert the data to a PIL Image in RGB or RGBA

  # RGB
  # Skip the transparency (A) plane 
  buffer_array = buffer_array[:, :, 0:3]
  image = Image.fromarray(buffer_array, mode="RGB")

  # RGBA
  image = Image.fromarray(buffer_array, mode="RGBA")

* Normal memory, I420: Mapping I420 is possible but hasn´t been tested
* NVMM, RGBA:

.. code-block:: python

  # Get the map info of the buffer
  # In the current version of the GObject python bindings the buffer can be only mapped for reading
  ret, map_info = io_buffer.map(Gst.MapFlags.READ)
  # Use the map info to map the data as an NvBufSurface
  # Note: We tried using the pyds API for this step, but it is not working as expected
  source_surface = pyds.NvBufSurface(map_info)
  torch_surface = pyds.NvBufSurface(map_info)
  # Create an empty tensor
  dest_tensor = torch.zeros((h, w, 4), dtype=torch.uint8, device='cuda')
  # Copy the data in GPU to gain ownership
  torch_surface.struct_copy_from(source_surface)
  # Make torch_surface map to dest_tensor memory
  torch_surface.surfaceList[0].dataPtr = dest_tensor.data_ptr()
  # Copy decoded GPU buffer (source_surface) into Pytorch tensor (torch_surface -> dest_tensor)
  torch_surface.mem_copy_from(source_surface)

**Note: For the time being, NvBufSurface doesn't support NVMM memory, so the NVMM buffer can't be used with this mapping.**

* NVMM, NV12: Mapping NV12 is possible but hasn´t been tested

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Example pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

  $ gst-launch-1.0 \
  uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream-5.0/samples/streams/sample_720p.mp4" ! \
  queue ! \
  nvvideoconvert ! \
  'video/x-raw(memory:NVMM)' ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 width=640 height=360 live-source=true ! \
  nvvideoconvert ! 'video/x-raw,format=(string)RGBA' ! \
  empycustom custom-lib="average_intensity.py" in-place=true process-interval=10 ! \
  aimeta silent=false ! perf ! fakesink

============================================================
Debugging
============================================================

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Visualizing output frame
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Replace `fakesink` in the pipeline above with `nvvideoconvert ! nvdsosd ! nvegltransform ! nveglglessink sync=false`.

.. code-block:: bash

  $ gst-launch-1.0 \
  uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream-5.0/samples/streams/sample_720p.mp4" ! \
  queue ! \
  nvvideoconvert ! \
  'video/x-raw(memory:NVMM)' ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 width=640 height=360 live-source=true ! \
  nvvideoconvert ! 'video/x-raw,format=(string)RGBA' ! \
  empycustom custom-lib="average_intensity.py" in-place=true process-interval=10 ! \
  aimeta silent=false ! perf ! nvvideoconvert ! nvdsosd ! nvegltransform ! nveglglessink sync=false

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Print output meta to console
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Add `GST_DEBUG=*python*:6` before the `gst-launch-1.0` command
* Set the `silent` property to false.

.. code-block:: bash

  $ GST_DEBUG=*emcustom*:6 gst-launch-1.0 \
  uridecodebin3 uri="file:///opt/nvidia/deepstream/deepstream-5.0/samples/streams/sample_720p.mp4" ! \
  queue ! \
  nvvideoconvert ! \
  'video/x-raw(memory:NVMM)' ! \
  nvstreammux0.sink_0 nvstreammux name=nvstreammux0 batch-size=1 width=640 height=360 live-source=true ! \
  nvvideoconvert ! 'video/x-raw,format=(string)RGBA' ! \
  empycustom custom-lib="average_intensity.py" in-place=true process-interval=10 silent=false ! \
  aimeta silent=false ! perf ! fakesink

* You will see messages in console that indicate that the element is processing:

.. code-block:: javascript

  0:00:05.469581082 12934   0x55991d4b70 DEBUG                 python gstempycustom.py:350:do_transform_ip: transform_ip
  0:00:05.469697491 12934   0x55991d4b70 LOG                   python gstempycustom.py:354:do_transform_ip: Processing buffer

* Any print performed in average_intensity.py will be printed to console

============================================================
How to add a custom library
============================================================

Following steps are required in case you want to compile and use your own custom library:

1. Create your custom library implementing the `process_ip` function. The `process` function can also be implemented, but should never be used with EdgeStream because it is impossible to map the output buffer in python. I will create a simple in-place library returning the same sample output meta for every buffer, so create a file called `new_lib.py`, and copy the following code:

.. code-block:: python

  def process(in_buffer, in_meta, options):
      """
      Applies a custom function to a video stream

      Parameters
      ------------
      in_buffer : array
           Input buffer as a numpy array
      in_meta : dictionary
           Input meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_buffer : object
          Output buffer object of the GstBuffer type. If None is returned
          here, the output frame will be empty
      out_meta : string
          Output meta string. The input metadata is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      out_buffer = None
      out_meta = ''
      # Insert your code here
      return out_buffer, out_meta


  def process_ip(io_buffer, in_meta, options):
      """
      Applies a custom function to a video stream in-place

      Parameters
      ------------
      io_buffer : array
           Input/Output buffer as a numpy array
      in_meta : dictionary
           Input/Output meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_meta : string
          Output meta string. The input metadata is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      out_meta = ''
      # Insert your code here
      return out_meta

* The best way to create the out_meta is to fill a python dictionary array and then serialize it.

.. code-block:: python

  out_meta_array = []
  out_meta_obj = {}
  out_meta_obj["test_int"] = 10
  out_meta_array.append(out_obj)
  out_meta = str(out_meta_array)

This will produce the following meta:

.. code-block:: javascript

  [
    {
      "test_int" : 10
    }
  ]

* You can use OpenCV to map the GstBuffer as a numpy array:

.. code-block:: python

  import cv2
  import gi
  import numpy as np
  gi.require_version('Gst', '1.0')
  from gi.repository import Gst

  ...

  # Convert the buffer to numpy array
  ret, map_info = io_buffer.map(Gst.MapFlags.READ)
  w = in_meta["frame"][0]["source_frame_width"]
  h = in_meta["frame"][0]["source_frame_height"]
  buffer_numpy = np.ndarray(shape = (h, w), dtype = np.uint8, buffer = map_info.data)

- Note: Gst.MapFlags.WRITE is not working in the current version of the bindings.
- Note: Importing OpenCV `import cv2` creates an omp context that is affected by DeepStream, If you get the following error importing `cannot allocate memory in static TLS block`, preload the library as follows `export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1` to fix cv2 import error. This is done in a reference app and in a Toolkit.

============================================================
EMPyCustom Meta
============================================================

EmPyCustom does not use a custom meta-structure and instead adds the output meta as part of the DeepStream Frame User Meta. This means that the element won't be able to add the meta to the buffer unless it has a base DeepStream meta already added by `nvstreammux`.

We are using the otherAttrs field of NvDsEventMsgMeta to pass the emcustom JSON meta string downstream. We distinguish our event meta from other DeepStream events by setting the objectId field.

To parse the meta in another application following the DeepStream meta hierarchy: batch_meta -> frame_meta_list -> user_meta_list -> event_msg_meta -> otherAttrs

============================================================
EMPyCustom Integration
============================================================

Although any arbitrary JSON can be given as an output, integration into Edgestream is done on a per-object basis. The input buffer will have a structure similar to the following:

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
    {
      "Arbitrary JSON for the frame (optional)"
    }
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

If not all objects have a corresponding JSON, the `aimeta` element will assign the elements it can in sequential order. Empty JSON strings: `{}` are valid and should be used for values where no data is to be passed to Edgestream.

If the output meta string contains more elements than the objects in the current frame, the excess elements will be assigned as frame meta.

`empycustom` can be used without any `nvinfer`. In that case, the input meta will only contain frame information and the objects list will be empty:

.. code-block:: javascript

  {
    "frame": [
      {
        "frame_num": 1363,
        "buf_pts": 47119953884,
        "timestamp": "2020-05-13T12:18:47.323-0600",
        "object": []
      }
    ]
  }

In this case, the output meta must contain only one JSON object with all the fields that will be added as frame meta. If the output meta array contains more elements, they will simply be ignored:

.. code-block:: javascript

  [
    {
      "Arbitrary JSON for the frame"
    }
  ]

Note that `aimeta` and `emcustom` only support batches of one frame. If the application is using batching greater than one, only the first frame (frame 0) will be processed.

============================================================
Examples
============================================================

These examples use Numpy and PIL to map the GStreamer buffer and read it as an Image.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Average Intensity in a person ROI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example parses the input meta to determine the ROI for a primary engine person. Then for each of the ROIs, it determines the average intensity.

.. code-block:: python

  from PIL import Image
  import cv2
  import gi
  import numpy as np

  gi.require_version('Gst', '1.0')
  from gi.repository import Gst

  DEFAULT_PERSON_CLASS_ID = 2

  def process(in_buffer, in_meta, options):
      """
      Applies a custom function to a video stream

      Parameters
      ------------
      in_buffer : array
           Input buffer as a numpy array
      in_meta : dictionary
           Input meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_buffer : object
          Output buffer object of the GstBuffer type. If None is returned
          here, the output frame will be empty
      out_meta : string
          Output meta string. The input metadata is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      return None, ''


  def process_ip(io_buffer, in_meta, options):
      """
      Applies a custom function to a video stream in-place

      Parameters
      ------------
      io_buffer : array
           Input/Output buffer as a numpy array
      in_meta : dictionary
           Input/Output meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_meta : string
          Output meta string. The input meta data is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      # Convert the buffer to numpy array
      ret, map_info = io_buffer.map(Gst.MapFlags.READ)
      w = in_meta["frame"][0]["source_frame_width"]
      h = in_meta["frame"][0]["source_frame_height"]
      buffer_array = np.ndarray(
          shape=(
              h,
              w),
          dtype=np.uint8,
          buffer=map_info.data)

      # Parsing options
      # The default DeepStream class ID for person is 2
      person_class_id = 2
      if options:
          if "person_class_id" in options:
              person_class_id = int(options["person_class_id"])

      # Frame Array
      in_array = in_meta["frame"]

      # First Element in frame array
      in_object = in_array[0]

      # Get object array
      object_array = in_object["object"]

      out_meta_array = []
      for obj in object_array:
          out_obj = {}

          # Get the average intensity for person objects
          if obj["class_id"] == person_class_id:
              # Python DeepStream is filling some meta fields wrongly including
              # width, height, and display text
              obj["rect_params"]["width"] = 50
              obj["rect_params"]["height"] = 150

              left = int(obj["rect_params"]["left"])
              top = int(obj["rect_params"]["top"])
              width = int(obj["rect_params"]["width"])
              height = int(obj["rect_params"]["height"])
              rect = buffer_array[left:left + width, top:top + height]
              out_obj["average_intensity"] = rect.mean()

          out_meta_array.append(out_obj)

      return str(out_meta_array)

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Torch classification CPU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example parses the input meta to determine the ROI for each detected object. Then for each of the ROIs, it runs inference with ImageNet classification.

.. code-block:: python

  from PIL import Image
  from torchvision import models, transforms
  import gi
  import json
  import numpy as np
  import torch

  gi.require_version('Gst', '1.0')
  from gi.repository import Gst

  # Global variables
  model = None
  labels = None
  NUM_PLANES = 4
  normalize = transforms.Normalize(
      mean=[0.485, 0.456, 0.406],
      std=[0.229, 0.224, 0.225])
  data_transform = transforms.Compose(
      [transforms.Resize((224, 224)), transforms.ToTensor(), normalize])


  def start(options):
      """
      Function called when the element starts

      Parameters
      ------------
      options : dictionary
           Options dictionary containing custom configurable options
      """
      global model, labels
      labels = options["labels"]
      model = models.squeezenet1_0(pretrained=True)
      model.cuda()
      model.eval()


  def stop(options):
      """
      Function called when the element stops

      Parameters
      ------------
      options : dictionary
           Options dictionary containing custom configurable options
      """
      torch.cuda.empty_cache()


  def process(in_buffer, in_meta, options):
      """
      Applies a custom function to a video stream

      Parameters
      ------------
      in_buffer : array
           Input buffer as a numpy array
      in_meta : dictionary
           Input meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_buffer : object
          Output buffer object of the GstBuffer type. If None is returned
          here, the output frame will be empty
      out_meta : string
          Output meta string. The input meta data is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      return None, ''


  def process_ip(io_buffer, in_meta, options):
      """
      Applies a custom function to a video stream in-place

      Parameters
      ------------
      io_buffer : array
           Input/Output buffer as a numpy array
      in_meta : dictionary
           Input/Output meta dictionary
      options : dictionary
           Options dictionary containing custom configurable options

      Returns
      -------
      out_meta : string
          Output meta string. The input meta data is moved over by the
          gstemcustom element so this should only contain the custom metadata
      """
      # Convert the buffer to a numpy array
      ret, map_info = io_buffer.map(Gst.MapFlags.READ)
      w = in_meta["frame"][0]["source_frame_width"]
      h = in_meta["frame"][0]["source_frame_height"]
      buffer_array = np.ndarray(
          shape=(h, w, NUM_PLANES),
          dtype=np.uint8,
          buffer=map_info.data)

      # Get object array
      object_array = in_meta["frame"][0]["object"]

      out_meta_array = []
      for obj in object_array:
          out_obj = {}
          # Cut the object
          left = int(obj["rect_params"]["left"])
          top = int(obj["rect_params"]["top"])
          width = int(obj["rect_params"]["width"])
          height = int(obj["rect_params"]["height"])
          # Skip the transparency (A) plane since the model is RGB
          rect = buffer_array[top:top + height, left:left + width, 0:3]
          if rect.size:
              image = Image.fromarray(rect, mode="RGB")
              cuda_image = data_transform(image).unsqueeze(0).cuda()
              with torch.no_grad():
                  out = model(cuda_image)
                  out_obj["predicted_class"] = labels[out.argmax()]
                  out_obj["probability"] = out.max().item()
          out_meta_array.append(out_obj)

      io_buffer.unmap(map_info)
      return str(out_meta_array)

============================================================
EmPyCustom options
============================================================

Additional options can be passed to the custom library using the `options` property. This property is a string that contains a serialized JSON object and is passed as a parameter from EdgeStream to the custom library virtual methods.

The JSON that will be passed is defined in a similar way to the `emcustom` element properties in the `emi_stream_config.json`:

.. code-block:: javascript

      "empycustom": {
        "custom-lib": "models/Secondary_AverageIntensity/libaverage_intensity.so",
        "in-place": "true",
        "format": "RGBA",
        "process-interval": 10,
        "options": {
          "person_class_id": 2
        }

The options field is passed as a python dictionary containing the values parsed from the JSON string.

The options are received in the custom library as a parameter in all vortual methods:

.. code-block:: python

  start(options)
  stop(options)
  process_ip(io_buffer, in_meta, options)
  process(in_buffer, in_meta, options)

============================================================
Known issues
============================================================

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Gst-python
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. The buffer received by BaseTransform is read-only and can't be mapped with Gst.MapFlags.WRITE. As a result, it is impossible to write on this buffer. For this reason, only the process-in-place function is able to produce a valid GstBuffer as output.
2. `set_property` will fail unless an exception is raised:

.. code-block:: python

      def do_set_property(self, prop: GObject.GParamSpec, value):
          ...
          # For some unknown reason gst-python version 1.14.5 will fail
          # with multiple properties unless an exception is raised. This
          # exception doesn't affect execution and only prints an error
          raise Exception

3. The signal support is not working

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DeepStream python
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. DeepStream creates a `libgomp` context, which makes the OpenCV in the custom lib fail:

.. code-block:: python

  Traceback (most recent call last):
    File "/home/nvidia/EDGESTREAM/gst-emcustom/python/gstempycustom.py", line 360, in do_transform_ip
      raise exception
    File "/home/nvidia/EDGESTREAM/gst-emcustom/python/gstempycustom.py", line 357, in do_transform_ip
      buf, in_meta, self.options)
    File "/home/nvidia/custom_lib.py", line 46, in process_ip
      import cv2
  ImportError: /usr/lib/aarch64-linux-gnu/libgomp.so.1: cannot allocate memory in static TLS block

A workaround is to pleload the library:

.. code-block:: bash

  export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1 to fix cv2 import error

2. The NvBufSurface API doesn't support NVMM memory