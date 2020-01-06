Quick Start
=====================

#. Update to the latest version
    #. Check the current version
    #. Run an update script
#. Create a new EAP by copying from a template EAP
    #. runedgestreamsdk and sdk_home
    #. Launch the EdgeStream SDK application
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

  nvidia@nvidia-desktop:/mnt/nvme/sdk_home$ pip3 show edgestreamsdk
  Name: edgestreamsdk
  Version: 0.9.8
  Summary: edgestreamsdk allows an AI model developer to build, test, upload an Edge Stream Application Package.
  Home-page: https://github.com/edge-ai/EdgeStreamSDK
  Author: Takenori Sato
  Author-email: tsato@edgematrix.com
  License: Proprietary
  Location: /home/nvidia/.local/lib/python3.6/site-packages
  Requires: pycairo, PyGObject

In the example above, the version is 0.9.8.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Run an update script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the following command to try updating to the latest version.

.. code-block:: bash

  nvidia@nvidia-desktop:/mnt/nvme/sdk_home$ bin/update_sdk.sh 
  Collecting edgestreamsdk
    Downloading http://54.250.165.6/packages/edgestreamsdk-0.9.9-py3-none-any.whl (42kB)
      100% |████████████████████████████████| 51kB 2.3MB/s 
  Collecting pycairo (from edgestreamsdk)
  Collecting PyGObject (from edgestreamsdk)
  Installing collected packages: pycairo, PyGObject, edgestreamsdk
  Successfully installed PyGObject-3.34.0 edgestreamsdk-0.9.9 pycairo-1.18.2
  Name: edgestreamsdk
  Version: 0.9.9
  Summary: edgestreamsdk allows an AI model developer to build, test, upload an Edge Stream Application Package.
  Home-page: https://github.com/edge-ai/EdgeStreamSDK
  Author: Takenori Sato
  Author-email: tsato@edgematrix.com
  License: Proprietary
  Location: /home/nvidia/.local/lib/python3.6/site-packages
  Requires: PyGObject, pycairo

In the example above, the sdk was updated to 0.9.9.

--------------------------------------------------------
Create a new EAP by copying from a template EAP
--------------------------------------------------------

At first, let's explore a command line program and the main directory you work on.
Then, launch the EdgeStream SDK application, then create a new EAP application from one of templates.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
runedgestreamsdk and sdk_home
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The command line program to launch the sdk application is runedgestreamsdk.

And the main directory you work on is sdk_home, which is mounted on a secondary drive.

    .. image:: images/quickstart/edgestreamsdk_help.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Launch the EdgeStream SDK application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Launch the EdgeStreamSDK application by executing the edgestreamsdk program, 
then, the following window will be shown.

    .. image:: images/quickstart/edgestreamsdk_launched.png
       :align: center

By clicking "About" button, you can check the version, v0.9.9.

    .. image:: images/quickstart/about.png
       :align: center

Now this time, let's create a new applicatoin that counts a vehicle with its car make.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Create a new EAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Press New, then you will see a dialog below.

    .. image:: images/quickstart/new_eap_dialog.png
       :align: center

Then, enter "My First Vehicle Counter", select "vehicle_counter_by_make_template", then click OK.

    .. image:: images/quickstart/new_eap_dialog_filled.png
       :align: center

This will copy the template to create your application. Now the SDK window shows your application as follows.

    .. image:: images/quickstart/edgestreamsdk_new_eap_created.png
       :align: center

As below, your application folder contains exactly the same structure of the copied template folder.

    .. image:: images/quickstart/edgestreamsdk_new_eap_terminal.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Select a new EAP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now let's select the newly created EAP application in the sidebar.

    .. image:: images/quickstart/edgestreamsdk_new_eap_selected.png
       :align: center

Then, it will show you all the configurations.
By clicking each of configuration groups, you can see its detail.
For example, you can see the followings when you click "Events & Callback".

    .. image:: images/quickstart/edgestreamsdk_new_eap_selected_callbackevents.png
       :align: center

Let's check what's inside the new application folder.

    .. image:: images/quickstart/edgestreamsdk_new_eap_terminal_app_structure.png
       :align: center

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

Press "Spell Check" button, which sounds odd, but was chosen among options available only for now.
Then, you will see a dialog as below.

    .. image:: images/quickstart/validate_eap_dialog.png
       :align: center

This shows two results, now yet shown, and the sample signal json to test the callback function.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Run a validation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Press "Execute", and see the result.

    .. image:: images/quickstart/validate_eap_dialog_passed.png
       :align: center

Nothing is customized yet, so it should pass as above.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Use your own sample siginal to validate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

But, if you have customized your callback, then, you are likely to test a different sample json.
In such a case, you can write your own sample, then use for this validation.

Press the file chooser, select your file, then, you are ready to validate with your own sample as below.

    .. image:: images/quickstart/validate_eap_dialog_sample_siginal.png
       :align: center

In this case, the value of "unique_component_id" was changed.

--------------------------------------------------------
Test the new EAP
--------------------------------------------------------

If you pass the validation, "Execute" button becomes active for you to run your application.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Execute, Choose a stream and Create an EAP package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By clicking the "Execute" button, it will show you an execution dialog.

    .. image:: images/quickstart/test_eap_dialog.png
       :align: center

At first, you need to choose a stream where your application will run.
By default, "streams" folrder of the sdk home directory is chosen.
Click the file chooser, open "vehicle_stream" folder, then select "vehicle_by_make_counter_stream_configuration.json".

The "streams" folder and the "movies" folder looks as below.

    .. image:: images/quickstart/test_eap_dialog_terminal_streams.png
       :align: center

Next, choose a movie file to use as a local RTSP streaming as below.

    .. image:: images/quickstart/test_eap_dialog_selected.png
       :align: center

Now, "Convert" button becomes active for you to make an EAP package in the chosen stream folder.

Press "Convert", then the packaging task will run for a while as a spinner is shown.
The dialog window will looks as below once completes.

    .. image:: images/quickstart/test_eap_dialog_ready_to_play.png
       :align: center

Let's check the EAP package built.

    .. image:: images/quickstart/test_eap_dialog_ready_to_play_terminal.png
       :align: center

An agent process is already up and running, so has already extracted the EAP package in the "uncompressed_files" folder.

The folder structure exactly the same as the one of the application folder as you have seen.
But there are a couple of exceptions. All the trained binaries and related files are encrypted.
You can tell by a file extention. Files with ".gpg" are encrypted with `GnuPG <https://gnupg.org/>`_.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Play a pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now you are ready to run your application in the stream.
Click "Play" button, and wait for a few seconds, you'll see events are getting generated and passed as actions.

    .. image:: images/quickstart/test_eap_playing.png
       :align: center

Note that "Show Debug Window" is checked. The debug window is shown, too.

So, how are those encrypted files treated while playing? Let's check the folder, again.

    .. image:: images/quickstart/test_eap_dialog_playing_terminal.png
       :align: center

No changes. No decrypted files on a disk. They are decrypted and processed in memory.
So even if an AI Box is stolen, your precious trained model binaries won't be exploited immediately.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stop a pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your test gets done, press "Stop" to terminate the EAP application process.

    .. image:: images/quickstart/test_eap_dialog_stopped.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Movie files made by record actions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At last, let's check movie files left, which were made by record action events.
Go to $SDK_HOME/streams/vehicle_stream/recordings folder, then you'll see some files as follows.

    .. image:: images/quickstart/test_eap_recordings.png
       :align: center