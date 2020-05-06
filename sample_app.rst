Sample App - Parking Violation Detector
=========================================

#. The problem that this sample app solves

#. Design Parking Violation Detector

    #. What actions should be taken under what conditions?
    #. How to let an end user to customize an action?

#. Prepare the pipeline

    #. AI model binaries and engine files
    #. Other elements
    #. DeepStream config
    #. Test the pipeline

#. Write a callback

    #. Define the structure of an event
    #. Generate an event
    #. Implementation

#. Write some action definitions to test

    #. SNMP Action
    #. LINE Action
    #. Recording Action
    #. HTTPS Action

This simple example will show a major use case of an edge AI that works as follows:

#. detects a danger or a violation
#. immediatelly notifies people around the scene of such a danger or a violation
#. sends an alert to a person in charge
#. upload an incident to the cloud for analysis

Then, such a person in charge will check the scene by a record or a live streaming with the EdgeView from anywhere.

--------------------------------------------------------
The problem that this sample app solves
--------------------------------------------------------

A vehicle illegally parks in a restricted area often causes various issues in neighbors.

But if someone watches, such a vehicle would simply pass such an area.

The problem is that such a "someone" is not always there.

--------------------------------------------------------
Design Parking Violation Detector
--------------------------------------------------------

This app tries to play the role of the "someone" by detecting a vehicle staying around and sending some alerts that tells "you are watched".

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
What actions should be taken under what conditions?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Action A)** immediatelly notifies people around the scene of such a danger or a violation

The first thing we have to define is a condition when a vehicle is detected as the one attempting a parking violation.
You could write a very complex algorithm for this, but for the simplicity, it is defined here that:

* a vehicle is detected as the one if it is tracked for more than a particular amount of time in seconds

The next thing to define is how to send an alert to such a vehicle.
Here, it is sent by a light as well as a sound by using a signal.

A SNMP action is available for this purpose to trigger such an alert locally on site.

As an example, we use the following product by Patlite.

https://www.patlite.com/product/detail0000021465.html

**Action B)** sends an alert to a person in charge

We will use a LINE Action that sends a message on the popular chat service called LINE.

If the condition for the above Action A persists, that likely means a vehicle is attempting to park.

So its threshold is usually larger than the one for a detection, but such a configuration can be done by the same way as the Action A.

* an alert will be sent if a vehicle is tracked for more than a particular amount of time in seconds

**Action C)** such a person in charge will check the scene by a record

We will use a Record Action that records a scene from X seconds before an event until X secnds after the event.

This threshold needs to be smaller than or equal to the one by Action B.

* a scene will be recorded if a vehicle is tracked for more than a particular amount of time in seconds

**Action D)** upload an incident to the cloud for analysis

We will use a HTTPS Action to upload to the cloud.

If every event is uploaded to the cloud in a similar way as above, the number of requests could be too many.
This is because an event is raised at each callback execution after a vehicle is tracked for more than a particular amount of time.

For an analysis, an event for each vehicle is enough.
So, instead of using such an amount of time being tracked, an event for each vehicle after a tracking is done is required.

* an event for each vehicle will be uploaded when a tracking of a vehicle is done

To remove some noise by a wrong detection, we may add an additional condition by an amount of time by tracking.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
How to let an end user to customize an action?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Action A)**

Depending on an end user (each deployment), the followings need to be customized.

a. how much amount of time in seconds a vehicle has been tracked for to be detected as the one attempting a parking violation
b. how to send a SNMP trap
c. what kind of light pattern to send as an alert
d. what kind of sound pattern to send as an alert
e. when to disarm an alert

With the said product by Patlite, a pre-defined set of light and sound can be triggered by a particular SNMP Trap.
So, we will define two pre-defined sets as follows.

- ON)  c + d
- OFF) e (no light and no sound)

Then, under the condition ``a``, a SNMP Trap of ``ON`` is triggered.
After a while, when the condition ``a`` is not met anymore, a SNMP Trap of ``Off`` is triggered to disarm an alert. 

**Action B)**

Depending on an end user (each deployment), the followings need to be customized.

f. how much amount of time in seconds a vehicle has been tracked for to send an alert to a person in charge
g. a LINE token of a particular chat room to send an alert
h. a text message as an alert
i. a stamp to send as an alert

**Action C)**

Depending on an end user (each deployment), the followings need to be customized.

j. how much amount of time in seconds a vehicle has been tracked for to record the scene
k. how much amount of tiem in seconds to record both in before and after at the event of ``i``

For example, a record is being made if a vehicle has been tracked for more than 3 seconds.
And such a record begins 5 seconds before the event until 5 seconds later of it.

**Action D)**

Depending on an end user (each deployment), the followings need to be customized.

l. how much amount of time in seconds a vehicle has been tracked for to upload an event if its tracking is done
m. url
n. user name
o. password


Note that in any case above, a Tracker could lose a vehicle time to time.
Then, a tracking is reset, and will be started over.

--------------------------------------------------------
Prepare your pipeline
--------------------------------------------------------

The pipeline of this app consists of the following elements:

* Primary Inference that detects a vehicle
* Tracker that identifies a vehicle

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AI model binaries and engine files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the primary inference, the AI model of the DeepStream reference app can be used.

That detects the following types of objects.

0. Car
1. Bicycle
2. Person
3. Roadsign

The eingine file can be generated by using the ``launch_dsconfig.sh`` script.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Other elements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the tracker, the DCF Tracker from the DeepStream reference app can be used.

We don't use a Secondary inference.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DeepStream config
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We can reuse the DeepStream config file of the reference app.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Test the pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At this point, we have everything we need to run a simple pipeline as a DeepStream app.
It can be done again by using the ``launch_dsconfig.sh`` script.

If there is any issue, it has to be fixed before moving next.

--------------------------------------------------------
Write a callback
--------------------------------------------------------

The main goal of a callback is to generate an event from an inference result 
so that expected actions can be triggered by an end user.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Define the structure of an event
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For all of the Actions, the length that a vehicle has been tracked for must be known by an event.

Also an event is generated on each car for an analysis in case events are analyzed in the cloud.

So, such an event is structured as follows:

* car_id
* tracking_duration
* tracking_ended_time

Also, for Action A, a special event when a vehicle has gone must be generated to trigger an ``OFF`` trap.

To achieve this, it is defined as follows.

* car_id == -1
* tracking_duration == -1
* tracking_ended_time == "N/A"

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Generate an event
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is very straightforward to generate an event from an inference reuslt when a vehicle is tracked.
If no vehicle is tracked, an empty list of events is generated.

When a state changes from the one at least one vehicle is tracked to another no vehicle is tracked,
a special event with ``car_id == -1`` defined as above is generated.

One consideration here is that a callback does not know if an action is invoked or not.
While an action is evaluated by a simple condition like ``car_id >= 0 and tracking_duration > 5``.
So, an action will be keep being trigerred as long as the condition is met, which could be too many number of action invocations.

To solve this issue, some actions have a property called ``interval`` to invoke an action only at an interval of the ``interval`` seconds.

Both of SNMP Action and LINE Action have this property.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Implementation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python

  from datetime import datetime

  ISO_FORMAT = '%Y-%m-%dT%H:%M:%S.%f%z'

  ''' 
  Parking Violation Detector

  Keys:
      tracking_duration (number): the number of seconds this car has been tracked
      car_id (number): the id of a car
      tracking_ended_time (string): the timestamp when a tracking of this car is done

  '''
  debug_string = ''

  # key, value = car_id, Car instance
  tracking_dict = {}

  class Car:

      def __init__(self, tracking_id, started):
          self.car_id = tracking_id

          # datetime
          self.tracking_started = started

          # datetime
          self.last_updated = started
          # iso formatted string
          self.tracking_ended = None
          self.debug ="car"

      def last_updated(self):
          return self.last_updated

      def tracking_duration_in_seconds(self):
          return (self.last_updated - self.tracking_started).total_seconds()

      def tracking_ended_time(self):
          return self.tracking_ended

      def update(self, updated):
          self.last_updated = Car.iso_timestamp_to_datetime(updated)

      def tracking_done(self):
          self.tracking_ended = self.last_updated

      def to_event_item(self):
          event_item = {}
          event_item['car_id'] = self.car_id
          event_item['tracking_duration'] = self.tracking_duration_in_seconds()
          if self.tracking_ended_time() is None:
              event_item['tracking_ended_time'] = 'N/A'
          else:
              event_item['tracking_ended_time'] = self.tracking_ended_time().strftime("%H:%M:%S")
          return event_item

      def new_car(tracking_id, timestamp):
          ''' returns a new car with the given tracking_id starting at the given timestamp
          
          Args:
              tracking_id (str): the unique id to identify this car
              timestamp (str): the ISO formatted timestamp (YYYY-MM-DDTHH:MM:SS.mmmmmm+HH:MM) 
                  when the tracker started to track this car 

          Returns:
              a new Car instance

          Raises:
              ValueError: if the given timestamp can not be formatted correctly
          '''

          started = Car.iso_timestamp_to_datetime(timestamp)

          return Car(tracking_id, started)


      def iso_timestamp_to_datetime(timestamp):
          return datetime.strptime(timestamp, ISO_FORMAT)

  def update_tracking(signal):
      """ a signal callback function """
      global debug_string
      detected_cars = []
      last_timestamp = None
      frame_list = signal["frame"]
      for frame in frame_list:
          timestamp = frame['timestamp']
          debug_string = debug_string + 'timestamp: ' + timestamp + '\n'
          for obj in frame["object"]:
              class_id = obj['class_id']
              object_id = obj['object_id']
              # Detect a car with class_id = 0
              if class_id != 0:
                  # this is not a car
                  continue
              if object_id in tracking_dict.keys():
                  # this is a known object
                  car = tracking_dict[object_id]
                  car.update(timestamp)
              else:
                  # this is a new object
                  car = Car.new_car(object_id, timestamp)
                  tracking_dict[object_id] = car
              detected_cars.append(object_id)
          last_timestamp = timestamp

      cars_to_remove = []
      events = generate_events(detected_cars, cars_to_remove)
      cleanup_cars(cars_to_remove)
      debug_string = debug_string + str(events)

      if len(events) == len(cars_to_remove):
          # special event
          events.append({
              'car_id': -1,
              'tracking_duration': -1,
              'tracking_ended_time': 'N/A'
          })

      return events, debug_string

  def generate_events(detected_cars, cars_to_remove):
      events = []
      for car in tracking_dict.values():
          if not car.car_id in detected_cars:
              # tracking is done
              car.tracking_done()
              cars_to_remove.append(car.car_id)
          events.append(car.to_event_item())
      return events

  def cleanup_cars(cars_to_remove):
      for car_id in cars_to_remove:
          del tracking_dict[car_id]


---------------------------------------
Write some action definitions to test
---------------------------------------

Here're some examples to define such actions explained above.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
SNMP Action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    {
      "rule_name": "Alarm ON",
      "and": [
        {
          "key": "car_id",
          "operator": ">",
          "value": -1
        },
        {
          "key": "tracking_duration",
          "operator": ">",
          "value": 3
        }
      ],
      "or": [
      ],
      "action": {
        "action_name": "snmp",
        "oid": "1.3.6.1.4.1.55412.1",
        "ipaddress": "192.168.1.134",
        "port": 162,
        "var_bind_key": "1.3.6.1.4.1.55412.1.1",
        "var_bind_value": 1,
        "community": "public",
        "interval": 5
      }
    },
    {
      "rule_name": "Alarm OFF",
      "and": [
        {
          "key": "car_id",
          "operator": "=",
          "value": -1
        }
      ],
      "or": [
      ],
      "action": {
        "action_name": "snmp",
        "oid": "1.3.6.1.4.1.55412.1",
        "ipaddress": "192.168.1.134",
        "port": 162,
        "var_bind_key": "1.3.6.1.4.1.55412.1.1",
        "var_bind_value": 0,
        "community": "public",
        "interval": 0
      }
    },

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
LINE Action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    {
      "rule_name": "Send a LINE message",
      "and": [
        {
          "key": "car_id",
          "operator": ">",
          "value": 0
        },
        {
          "key": "tracking_duration",
          "operator": ">",
          "value": 7
        }
      ],
      "or": [
      ],
      "action": {
        "action_name": "line",
        "token_id": "MY_TOKEN",
        "message": "Test Message",
        "stickerId": 302,
        "stickerPackageId": 4,
        "interval": 60
      }
    }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Recording Action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    {
      "rule_name": "Record",
      "and": [
        {
          "key": "car_id",
          "operator": ">",
          "value": 0
        }
      ],
      "or": [],
      "action": {
        "action_name": "record",
        "duration_in_seconds": 5
      }
    }

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
HTTPS Action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    {
      "rule_name": "HTTPS",
      "and": [
        {
          "key": "tracking_ended_time",
          "operator": "!=",
          "value": "N/A"
        },
        {
          "key": "tracking_duration",
          "operator": ">",
          "value": 1
        }
      ],
      "or": [],
      "action": {
        "action_name": "https",
        "url": "https://MY_HTTP_OR_HTTPS_SERVER/path",
        "user": "userA",
        "password": "password_userA"
      }
    }
