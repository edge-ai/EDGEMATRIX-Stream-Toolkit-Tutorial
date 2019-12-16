Configurations
====================

#. SDK Directory Structure
#. Configurations
    #. Overview
    #. Input
    #. Primary
    #. Tracker
    #. Secondary
    #. Overlay
    #. AI Meta
    #. Callback and Events
    #. Action

============================================================
SDK Directory Structure
============================================================

The directory structure of the EdgeStream SDK looks like this:

    .. image:: images/sdk_directories.png
       :align: center

============================================================
Configurations
============================================================

----------------
Overview
----------------

This is a configuration about an overview of an EAP.

    .. image:: images/overview.png
       :align: center

----------------
Input
----------------

This is a configuration about an input of a pipeline.

The GStreamer used for this is nvstreammux.

Please refer to the DeepStream Plugin Manual for details.

    .. image:: images/input.png
       :align: center

Please note that an end user is allowed to configure their own ROI over their RTSP stream.

----------------
Primary
----------------

This is a configuration about a primary inference of a pipeline.

The GStreamer used for this is nvinfer.

Please refer to the DeepStream Plugin Manual for details.

    .. image:: images/primary.png
       :align: center

----------------
Tracker
----------------

This is a configuration about a tracker of a pipeline.

The GStreamer used for this is nvtracker.

Please refer to the DeepStream Plugin Manual for details.

    .. image:: images/tracker.png
       :align: center

----------------
Secondary
----------------

This is a configuration about a secondary inference of a pipeline.

The GStreamer used for this is nvinfer.

Please refer to the DeepStream Plugin Manual for details.

    .. image:: images/secondary.png
       :align: center

----------------
Overlay
----------------

This is a configuration about an overlay of a pipeline.

The GStreamer used for this is nvdsosd.

Please refer to the DeepStream Plugin Manual for details.

    .. image:: images/overlay.png
       :align: center

----------------------
Callback and Events
----------------------

This is a configuration about the callback function name and event definitions.

    .. image:: images/callback_and_events.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Callback
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The callback function defined as the callback function name must exists in a python file "called emi_signal_callback.py".

This is a python file in which source code represents a signal callback function to be activated if the conditions defined in the stream-configuration file are satisfied.

The signal callback file mus at minimum comply with the following conditions:

* The file must be named emi_signal_callback.py
* Must define a method with the name defined in the emi_stream_config.json signal_callback_function_name field
* The method must return a dictionary array where each element of the array contains at least the fields defined in the emi_stream_config.json event_item_keys field. This array can also be empty.
* The python file will be compiled and executed in a sandbox environment based on Restricted Python. The allowed and restricted Python functionalities are documented below.

Allowed::

    Secure exceptions are allowed. But the signal callback handler will fail if an exception is raised in the callback function. Here is a list of the allowed exceptions:
        ArithmeticError
        AssertionError
        AttributeError
        BaseException
        BufferError
        BytesWarning
        DeprecationWarning
        EnvironmentError
        EOFError
        Exception
        FloatingPointError
        FutureWarning
        GeneratorExit
        ImportError
        ImportWarning
        IndentationError
        IndexError
        IOError
        KeyboardInterrupt
        KeyError
        LookupError
        MemoryError
        NameError
        NotImplementedError
        OSError
        OverflowError
        PendingDeprecationWarning
        ReferenceError
        RuntimeError
        RuntimeWarning
        StopIteration
        SyntaxError
        SyntaxWarning
        SystemError
        SystemExit
        TabError
        TypeError
        UnboundLocalError
        UnicodeError
        UnicodeWarning
        UserWarning
        ValueError
        Warning
        ZeroDivisionError
    For loops are allowed when iterating over lists, tuples or strings.
    Flow control statements are allowed:, break, continue, pass
    Using format() on a str is not safe but it is allowed
    The following built-in functions are allowed:
        abs()
        callable()
        chr()
        divmod()
        hash()
        hex()
        id()
        isinstance()
        issubclass()
        len()
        oct()
        ord()
        pow()
        range()
        repr()
        round()
        zip()
    Module imports are potentially dangerous but the datetime package and all its sub-modules are allowed.
    New classes, parameters, and methods are allowed
    The following data types are allowed:
        bool
        complex
        float
        int
        slice
        str
        tuple
    Only in-place operators are restricted. This is the list of allowed operators:
        +
        -
        *
        /
        %
        **
        //
        &
        |
        ^
        ~
        <<
        >>
        ==
        !=
        >
        <
        >=
        <=
        and
        or
        not
        is
        is not
        in
        not in
        =
    The following builtin values are allowed:
        False
        None
        True
    While loops are allowed

Restricted::

    Attribute manipulation with builtin functions is restricted:
        setattr()
        getattr()
        delattr()
        hasattr()
    Attribute names that start with "_" are restricted
    compile() is restricted because it can be used to produce new unrestricted code
    For loops are restricted when iterating over dict
    dir() is restricted because it returns all properties and methods of an object
    Direct IO is restricted:
        execfile()
        file()
        input()
        open()
        raw_input()
    eval() calls are restricted
    The following exceptions are restricted:
        BlockingIOError
        BrokenPipeError
        ChildProcessError
        ConnectionAbortedError
        ConnectionError
        ConnectionRefusedError
        ConnectionResetError
        FileExistsError
        FileNotFoundError
        InterruptedError
        IsADirectoryError
        ModuleNotFoundError
        NotADirectoryError
        PermissionError
        ProcessLookupError
        RecursionError
        ResourceWarning
        StandardError
        StopAsyncIteration
        TimeoutError
        UnicodeDecodeError
        UnicodeEncodeError
        UnicodeTranslateError
        WindowsError
    exec() calls are restricted because it can be used to execute unrestricted code
    The following built-in functions are restricted:
        all()
        any()
        apply()
        bin()
        buffer()
        classmethod()
        cmp()
        coerce()
        enumerate()
        filter()
        intern()
        iter()
        map()
        max()
        memoryview()
        min()
        sorted()
        staticmethod()
        sum()
        super()
        type()
        unichr()
    Global built-ins access is restricted
    All imports are restricted except the ones mentioned before
    Namespace access is restricted:
        globals()
        locals()
        vars()
    In-place operators are restricted:
        +=
        -=
        *=
        /=
        %=
        //=
        **=
        &=
        |=
        ^=
        >>=
        <<=
    Prints are restricted
    Strings that describe Python are restricted, there's no point to including these:
        copyright()
        credits()
        exit()
        help()
        license()
        quit()
    Some data types alias are restricted:
        bytearray
        dict
        file
        list
        long
        unicode
        xrange
        basestring
        object
        property

----------------
Action
----------------

An action is executed when an event matchs a user defined action rule.

The following actions are available on the EMI's Edge AI Platform.

#. Recording
#. Upload to Amazon Kinesis Firehorse
#. Send a notification email

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Recording
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The EdgeStream application implements the video recording module which records videos for each incoming event, this module is configured according to established actions into the stream configuration file.

The actions determine the video duration for:

Pre-recording: recorded video before triggering an event.
Post-recording: recorded video after triggering an event.

    .. image:: images/prerecording.png
       :align: center

The videos for both recording processes will have the same duration.

Record action

This action establishes the duration of videos for pre-recording and post-recording equivalently. It must define as integer value.

.. code-block:: json

    "action":{
        "action_name": "record", "duration_in_seconds": 15
    }

Video prolongation for post-recording

This recording module performs a video prolongation in post-recording for incoming events during the recording process. The video prolongation depends on the record time, defined in actions, and the time for each incoming event. The next figure shows how the video prolongation works.

    .. image:: images/recording_processing_rules.png
       :align: center

* Tr = Record time
* T0 = Initial post-record by first event
* T1 = Arrival time for second event
* T2 = Arrival time for third event
* Tr - T1 = video prolongation by second event
* Tr - T2 = video prolongation by third event

Format name for recorded video::

    stream_id_%ID_%Y-%m-%dT%H:%M:%S%z.mp4

* ID = Identifier
* Y = year
* m = month
* d = day
* H = hour
* M = minute
* S = seconds
* z = numeric time zone

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Upload to Amazon Kinesis Firehorse
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is one of delegate actions executed by a Device Agent.

It will upload an event to a user defined location of the Amazon Kinesis Firehorse.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Send a notification email
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is one of delegate actions executed by a Device Agent.

It will send an event to a user defined email address.