Overview
==================================

EdgeStream SDK is a software development kit released by `EdgeMatrix, Inc <https://edgematrix.com/>`_ (EMI),
and which is defined as folows::

    An EdgeStream SDK is a tool installed on an SDK Box that allows an AI model developer 
        to make an EdgeStream Application Package (EAP)
        to run it locally for testing purposes
        to submit a tested EAP to sell on the EMI's market place

This would make you wonder about many questions. 
What is an SDK Box? EAP? The EMI's market place?

They will be covered later in details, but more importantly, please note that this tool is designed for an AI model developer.

Until when deploying a trained model binary on an edge, it has to be built as an application and integrated with a service for the monitoring. 
Especially, EMI focuses on an IVA (Intelligent Video Analytics) task that inevitably requires video streaming technologies.
For example, `GStreamer <https://gstreamer.freedesktop.org/>`_ is the most proven library of such a streaming technology,
but which is a completely different beast from an AI model development.

Yet, the most competitive intellectual property likely remains around such a trained model binary.

So, EMI provides an Edge AI Service so that an AI model developer could focus on an AI model development.
Such an invaluable asset is wrapped by an EAP that can be integrated dynamically with the service for an end user.
And EMI will take care of various interactions between end users.

The overal look of the EMI's Edge AI service is as follows.

    .. image:: images/edge_ai_service.png
       :align: center

==========================================
SDK Box
==========================================

EMI provides an end-to-end service including an edge device called `AI Box <https://edgematrix.com/business/box/>`_.

A SDK Box is a type of AI Box built for an AI Model Developer, which comes with the EdgeStream SDK.

For more information, please contact our sales.

==========================================
EdgeStream
==========================================

The EdgeStream is the EMI's core streaming engine that:

#. works on the NVIDIA's DeepStream GStreamer plugins
#. is integrated with the EMI's Edge AI Service

Here's the picture of the EdgeStream's concept.

    .. image:: images/edgestream_concept.png
       :align: center

As you can see, the EdgeStream relies on the NVIDIA's DeepStream about performance.
Then, on top of it, the EdgeStream provides both of performance and efficiency over an Edge AI development.

Next, here's the technical overview of the EdgeStream.

    .. image:: images/edgestream_component.png
       :align: center

A single EdgeStream instance consists of three components.

#. EdgeStream Application Package
#. EdgeStream Controller
#. EdgeStream Pipeline

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EdgeStream Application Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An EdgeStream Application Package is a encrypted file with a public key of a licensed device that consists of the followings.

* A config file
* A Python file that contains a user defined callback function
* A resource folder that contains any other files like an AI model binary

A stream config file contains not only various information about this application package, but also does event item definitions.

A callback function in a Python file is called back when a signal is generated from an EdgeStream pipeline, then generates events as defined in the event definitions.

An EdgeSteam pipeline is constructed based on the information defined in a config file, by referring to files in a resource folder.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EdgeStream Controller
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An EdgeStream Controller is a controller class that create an EdgeStream pipeline by reading a config file.
Whenever a signal is generated, it calls a callback function, receive events, then execute an action if such an event matches to an event.

What kind of event is generated is up to an application, but what action is executed is up to an end user.

So, an end user is allowed to define an action rule by using those events defined in a config file.


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EdgeStream Pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An EdgeStream pipeline is a GStreamer pipeline running inside a GStremaer server process.

By running multiple pipelines inside a server process, it can efficiently share common elements like RTSP, decoder, and encoder.

You will find this architecture is critical when multiple webrtc clients connect to the same stream.

Also, we have two visionary pipelines as our goals.

1. A single EdgeStream pipeline consists of multiple AI model developers

    .. image:: images/multiple_ai_vendors.png
       :align: center

2. A single 4K RTSP stream shared among several EdgeStream pipelines

    .. image:: images/4K_multiple_edgestreams.png
       :align: center
