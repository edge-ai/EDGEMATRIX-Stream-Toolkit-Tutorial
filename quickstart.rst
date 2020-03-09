クイックスタート
=====================

#. 最新バージョンにアップデート
    #. 現在のバージョンを確認
    #. アップデートスクリプトの実行
#. テンプレートEAPをコピーし、新しいEAPを作成
    #. `runedgestreamsdk` と `sdk_home`
    #. EdgeStream SDKアプリケーションを起動
    #. 新しいEAPを作成
    #. EAPを選択
#. 新しいEAPを検証
    #. 検証ダイアログを開く
    #. 検証を実行
    #. サンプルシグナルを使用し、検証
#. 新しいEAPをテスト
    #. 実行、ストリームの選択、EAPパッケージの生成
    #. パイプラインの実行
    #. パイプラインの終了
    #. レコードアクションによって生成された動画ファイル

--------------------------------------------------------
最新バージョンにアップデート
--------------------------------------------------------

始める前に、最新バージョンにアップデートしましょう。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
現在のバージョンを確認
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

以下のコマンドを実行し、現在インストールされているバージョンを確認します。

.. code-block:: bash

  nvidia@nvidia-desktop:~/projects/EdgeStreamSDK$ pip3 show edgestreamsdk
  Name: edgestreamsdk
  Version: 1.1.0
  Summary: edgestreamsdk allows an AI model developer to build, test, upload an Edge Stream Application Package.
  Home-page: https://github.com/edge-ai/EdgeStreamSDK
  Author: Takenori Sato
  Author-email: tsato@edgematrix.com
  License: Proprietary
  Location: /home/nvidia/.local/lib/python3.6/site-packages
  Requires: requests, boto3, PyGObject, qtfaststart, pycairo, edgestream
  Required-by:

この場合、バージョンは1.1.0です。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
アップデートスクリプトの実行
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

以下のコマンドを実行し、最新バージョンにアップデートします。

.. code-block:: bash

  nvidia@nvidia-desktop:/mnt/nvme/sdk_home$ bin/update_sdk.sh
  Looking in indexes: http://54.250.165.6:80/
  Requirement already satisfied: edgestreamsdk in /home/nvidia/.local/lib/python3.6/site-packages (1.1.0)
  Requirement already satisfied: edgestream in /home/nvidia/.local/lib/python3.6/site-packages (from edgestreamsdk) (1.4.4)
  Requirement already satisfied: qtfaststart in /home/nvidia/.local/lib/python3.6/site-packages (from edgestreamsdk) (1.8)
  Requirement already satisfied: PyGObject in /usr/lib/python3/dist-packages (from edgestreamsdk) (3.26.1)
  Requirement already satisfied: requests in /usr/local/lib/python3.6/dist-packages (from edgestreamsdk) (2.22.0)
  Requirement already satisfied: pycairo in /usr/lib/python3/dist-packages (from edgestreamsdk) (1.16.2)
  Requirement already satisfied: boto3 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestreamsdk) (1.12.2)
  Requirement already satisfied: gpustat>=0.6.0 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (0.6.0)
  Requirement already satisfied: restrictedpython>=5.0 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (5.0)
  Requirement already satisfied: jsonschema>=3.0.0 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (3.2.0)
  Requirement already satisfied: pynput>=1.1 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (1.6.7)
  Requirement already satisfied: click>=7.0 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (7.0)
  Requirement already satisfied: xlib>=0.10 in /home/nvidia/.local/lib/python3.6/site-packages (from edgestream->edgestreamsdk) (0.21)
  Requirement already satisfied: psutil>=3.0 in /usr/local/lib/python3.6/dist-packages (from edgestream->edgestreamsdk) (5.7.0)
  Requirement already satisfied: chardet<3.1.0,>=3.0.2 in /usr/lib/python3/dist-packages (from requests->edgestreamsdk) (3.0.4)
  Requirement already satisfied: urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1 in /usr/lib/python3/dist-packages (from requests->edgestreamsdk) (1.22)
  Requirement already satisfied: idna<2.9,>=2.5 in /usr/lib/python3/dist-packages (from requests->edgestreamsdk) (2.6)
  Requirement already satisfied: certifi>=2017.4.17 in /usr/lib/python3/dist-packages (from requests->edgestreamsdk) (2018.1.18)
  Requirement already satisfied: jmespath<1.0.0,>=0.7.1 in /home/nvidia/.local/lib/python3.6/site-packages (from boto3->edgestreamsdk) (0.9.4)
  Requirement already satisfied: s3transfer<0.4.0,>=0.3.0 in /home/nvidia/.local/lib/python3.6/site-packages (from boto3->edgestreamsdk) (0.3.3)
  Requirement already satisfied: botocore<1.16.0,>=1.15.2 in /home/nvidia/.local/lib/python3.6/site-packages (from boto3->edgestreamsdk) (1.15.2)
  Requirement already satisfied: blessings>=1.6 in /home/nvidia/.local/lib/python3.6/site-packages (from gpustat>=0.6.0->edgestream->edgestreamsdk) (1.7)
  Requirement already satisfied: six>=1.7 in /usr/local/lib/python3.6/dist-packages (from gpustat>=0.6.0->edgestream->edgestreamsdk) (1.14.0)
  Requirement already satisfied: nvidia-ml-py3>=7.352.0 in /home/nvidia/.local/lib/python3.6/site-packages (from gpustat>=0.6.0->edgestream->edgestreamsdk) (7.352.0)
  Requirement already satisfied: setuptools in /usr/lib/python3/dist-packages (from restrictedpython>=5.0->edgestream->edgestreamsdk) (39.0.1)
  Requirement already satisfied: attrs>=17.4.0 in /home/nvidia/.local/lib/python3.6/site-packages (from jsonschema>=3.0.0->edgestream->edgestreamsdk) (19.3.0)
  Requirement already satisfied: pyrsistent>=0.14.0 in /home/nvidia/.local/lib/python3.6/site-packages (from jsonschema>=3.0.0->edgestream->edgestreamsdk) (0.15.7)
  Requirement already satisfied: importlib-metadata; python_version < "3.8" in /home/nvidia/.local/lib/python3.6/site-packages (from jsonschema>=3.0.0->edgestream->edgestreamsdk) (1.5.0)
  Requirement already satisfied: python-xlib>=0.17; "linux" in sys_platform in /home/nvidia/.local/lib/python3.6/site-packages (from pynput>=1.1->edgestream->edgestreamsdk) (0.26)
  Requirement already satisfied: python-dateutil<3.0.0,>=2.1 in /usr/lib/python3/dist-packages (from botocore<1.16.0,>=1.15.2->boto3->edgestreamsdk) (2.6.1)
  Requirement already satisfied: docutils<0.16,>=0.10 in /home/nvidia/.local/lib/python3.6/site-packages (from botocore<1.16.0,>=1.15.2->boto3->edgestreamsdk) (0.15.2)
  Requirement already satisfied: zipp>=0.5 in /home/nvidia/.local/lib/python3.6/site-packages (from importlib-metadata; python_version < "3.8"->jsonschema>=3.0.0->edgestream->edgestreamsdk) (3.0.0)
  Name: edgestreamsdk
  Version: 1.1.0
  Summary: edgestreamsdk allows an AI model developer to build, test, upload an Edge Stream Application Package.
  Home-page: https://github.com/edge-ai/EdgeStreamSDK
  Author: Takenori Sato
  Author-email: tsato@edgematrix.com
  License: Proprietary
  Location: /home/nvidia/.local/lib/python3.6/site-packages
  Requires: requests, boto3, qtfaststart, pycairo, edgestream, PyGObject
  Required-by: 

これでSDKは最新バージョンになりました。

--------------------------------------------------------
テンプレートEAPをコピーし、新しいEAPを作成
--------------------------------------------------------

初めに、コマンドラインプログラムとメインディレクトリを調べてみましょう。
その後、EdgeStream SDKアプリケーションを起動し、テンプレートから新しいEAPアプリケーションを作成します。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
`runedgestreamsdk` と `sdk_home`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

`runedgestreamsdk` は、SDKアプリケーションを起動するコマンドです。

メインディレクトリは `sdk_home` です。これは、セカンダリドライブにマウントされています。

    .. image:: images/quickstart/edgestreamsdk_help.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EdgeStream SDKアプリケーションを起動
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

edgestreamsdkプログラムを実行し、EdgeStreamSDKアプリケーションを起動します。

.. code-block:: bash

  nvidia@nvidia-desktop:/mnt/nvme/sdk_home$ runedgestreamsdk ./

そうすると、次のようなウィンドウが表示されます。

    .. image:: images/quickstart/edgestreamsdk_launched.png
       :align: center

"About"ボタンをクリックすると、現在のバージョンを確認できます。
この例では、v1.1.0です。

    .. image:: images/quickstart/about.png
       :align: center


それでは、自動車の数をカウントする新しいアプリケーションを作成していきましょう。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
新しいEAPを作成
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

以下のようなダイアログが出たら、"New"ボタンを押下します。

    .. image:: images/quickstart/new_eap_dialog.png
       :align: center

"My First Vehicle Counter"と入力し、"EMI Vehicle DCF Counter By Color"を選択後、"OK"をクリックします。

    .. image:: images/quickstart/new_eap_dialog_filled.png
       :align: center

テンプレートがコピーされ、新しいアプリケーションが作成されました。SDKウィンドウには、以下のようにアプリケーションが表示されます。

    .. image:: images/quickstart/edgestreamsdk_new_eap_created.png
       :align: center

以下のように、アプリケーションフォルダは、コピーしたテンプレートフォルダとまったく同じ構造で構成されています。

    .. image:: images/quickstart/edgestreamsdk_new_eap_terminal.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
EAPを選択
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

サイドバーから、先ほど作成した新しいEAPアプリケーションを選択します。

    .. image:: images/quickstart/edgestreamsdk_new_eap_selected.png
       :align: center

すべてのコンフィグレーションが表示されます。
それぞれのコンフィグレーショングループをクリックすると、詳細を確認できます。
例えば、"Callback&Events"とクリックすると、以下のように表示されます。

    .. image:: images/quickstart/edgestreamsdk_new_eap_selected_callbackevents.png
       :align: center

新しいアプリケーションフォルダの中身を確認してみましょう。

    .. image:: images/quickstart/edgestreamsdk_new_eap_terminal_app_structure.png
       :align: center

このアプリケーションでは、学習済モデルバイナリをそのまま使用することに今一度注意してください。
学習済モデルバイナリをEAPパッケージとして保護する方法は後ほど確認します。

--------------------------------------------------------
新しいEAPを検証
--------------------------------------------------------

実際のプロジェクトでは、必要に応じてこのアプリケーションをカスタマイズできます。
準備ができたら、作成したアプリケーションが有効かどうか検証してみましょう。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
検証ダイアログを開く
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

"Spell Check"ボタンを押してください。
すると、以下のようなダイアログが表示されます。

    .. image:: images/quickstart/validate_eap_dialog.png
       :align: center

これは、まだ表示されていない2つのチェック結果と、コールバック関数をテストするためのサンプルシグナルJSONを表示しています。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
検証を実行
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

"Execute"を押し、結果を表示しましょう。

    .. image:: images/quickstart/validate_eap_dialog_passed.png
       :align: center

まだ何もカスタマイズされていないので、上記のように検証を通過するはずです。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
サンプルシグナルを使用し、検証
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

コールバックをカスタマイズしている場合、別のサンプルJSONをテストしたい場合があります。
この場合、自分でサンプルを書き、それを用いて検証してください。

ファイル選択ボタンを押し、対象のファイルを選択します。
そうすると、以下のように独自のサンプルによる検証の準備ができます。

    .. image:: images/quickstart/validate_eap_dialog_sample_siginal.png
       :align: center

この場合、"unique_component_id"の値が変更されていました。

--------------------------------------------------------
新しいEAPをテスト
--------------------------------------------------------

検証を通過したら、アプリケーションを実行するための"Execute"ボタンがアクティブになります。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
実行、ストリームの選択、EAPパッケージの生成
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

"Execute"ボタンとクリックすると、実行ダイアログが表示されます。

    .. image:: images/quickstart/test_eap_dialog.png
       :align: center

初めに、アプリケーションを実行するストリームを選択する必要があります。
デフォルトでは、SDKホームディレクトリの"streams"フォルダが選択されています。
ファイル選択ボタンを押し、"vehicle_stream"フォルダを開き、"vehicle_counter_stream_configuration.json"を選択します。

"streams"フォルダと"movies"フォルダは以下のようになっています。

    .. image:: images/quickstart/test_eap_dialog_terminal_streams.png
       :align: center

次に、ローカルRTSPストリーミングとして使用する動画ファイルを選択します。

    .. image:: images/quickstart/test_eap_dialog_selected.png
       :align: center

ここで、選択したストリームフォルダの中にEAPパッケージを作成する"Convert"ボタンがアクティブになりました。

"Convert"を押すと、スピナが表示されている間、しばらくパッケージタスクが実行されます。
ダイアログウィンドウは、完了すると次のようになります。

    .. image:: images/quickstart/test_eap_dialog_ready_to_play.png
       :align: center

ビルドされたEAPパッケージを確認しましょう。

    .. image:: images/quickstart/test_eap_dialog_ready_to_play_terminal.png
       :align: center

すでにエージェントプロセスが実行されているので、EAPパッケージは"uncompressed_files"フォルダに展開されています。

フォルダ構成は、先ほど見たアプリケーションフォルダとまったく同じです。
しかし、いくつか例外があります。すべての学習済バイナリとその関連ファイルは暗号化されています。
暗号化されたファイルは、拡張子で確認できます。".gpg"のファイルは、`GnuPG <https://gnupg.org/>`_ で暗号化されています。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
パイプラインの実行
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ここで、アプリケーションを実行する準備が整いました。
"Play"ボタンを押し、数秒待てば、発生したイベントを見ることができます。

    .. image:: images/quickstart/test_eap_playing.png
       :align: center

"Show Debug Window"にチェックがついていることを確認してください。デバッグウィンドウが表示されます。

    .. image:: images/quickstart/test_eap_playing_debug.png
       :align: center

また、実行中のパイプラインに関するいくつかの統計を確認できます。

    .. image:: images/quickstart/test_eap_dialog_stats.png
       :align: center

では、これらの暗号化されたファイルは、再生中どのようになっているでしょうか？
もう一度フォルダを確認してみましょう。

    .. image:: images/quickstart/test_eap_dialog_playing_terminal.png
       :align: center

何も変わっていませんね。
ディスク上に復号化されたファイルはありません。
それらはメモリ内で復号されます。
そのため、AIボックスが盗まれた場合でも、貴重な学習済モデルバイナリがすぐに悪用されることはありません。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
パイプラインの終了
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

テストが完了したら、"Stop"ボタンを押してEAPアプリケーションを終了しましょう。

    .. image:: images/quickstart/test_eap_dialog_stopped.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
レコードアクションによって生成された動画ファイル
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

最後に、レコードアクションイベントで生成された動画ファイルを確認しましょう。
`$SDK_HOME/streams/vehicle_stream/recordings` フォルダに移動し、以下のようにファイルを確認できます。

    .. image:: images/quickstart/test_eap_recordings.png
       :align: center
